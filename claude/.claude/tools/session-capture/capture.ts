#!/usr/bin/env bun
import { Database } from "bun:sqlite";
import { join } from "path";

const DB_PATH = join(import.meta.dir, "data", "sessions.db");
const MAX_RESULT_LENGTH = 10000; // Keep results medium

interface HookData {
  session_id?: string;
  sessionId?: string;
  cwd?: string;
  prompt?: string;
  tool_name?: string;
  tool_input?: Record<string, unknown>;
  tool_result?: unknown;
  is_error?: boolean;
}

function now(): string {
  return new Date().toISOString();
}

function getSessionId(data: HookData): string {
  return data.session_id || data.sessionId || "unknown";
}

function ensureSchema(db: Database): void {
  db.run(`
    CREATE TABLE IF NOT EXISTS sessions (
      id TEXT PRIMARY KEY,
      started_at TEXT NOT NULL,
      ended_at TEXT,
      cwd TEXT,
      first_prompt TEXT,
      last_prompt TEXT
    )
  `);

  // Add columns if they don't exist (for existing DBs)
  try {
    db.run(`ALTER TABLE sessions ADD COLUMN first_prompt TEXT`);
  } catch {}
  try {
    db.run(`ALTER TABLE sessions ADD COLUMN last_prompt TEXT`);
  } catch {}

  db.run(`
    CREATE TABLE IF NOT EXISTS user_inputs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT NOT NULL,
      prompt TEXT,
      created_at TEXT NOT NULL
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS tool_calls (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT NOT NULL,
      tool_name TEXT NOT NULL,
      tool_input TEXT,
      tool_result TEXT,
      is_error INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    )
  `);

  db.run(
    `CREATE INDEX IF NOT EXISTS idx_inputs_session ON user_inputs(session_id)`
  );
  db.run(
    `CREATE INDEX IF NOT EXISTS idx_tools_session ON tool_calls(session_id)`
  );
}

function ensureSession(db: Database, sessionId: string, cwd?: string): void {
  db.run(
    `INSERT OR IGNORE INTO sessions (id, started_at, cwd) VALUES (?, ?, ?)`,
    [sessionId, now(), cwd || null]
  );
}

function truncate(str: string, max: number): string {
  return str.length > max ? str.slice(0, max) + "...[truncated]" : str;
}

// Handlers
function handleUserPrompt(db: Database, data: HookData): void {
  const sessionId = getSessionId(data);
  ensureSession(db, sessionId, data.cwd);

  const prompt = data.prompt || null;
  const truncatedPrompt = prompt ? truncate(prompt, 100) : null;

  // Set first_prompt only if NULL, always update last_prompt
  db.run(
    `UPDATE sessions SET
      first_prompt = COALESCE(first_prompt, ?),
      last_prompt = ?
    WHERE id = ?`,
    [truncatedPrompt, truncatedPrompt, sessionId]
  );

  db.run(
    `INSERT INTO user_inputs (session_id, prompt, created_at) VALUES (?, ?, ?)`,
    [sessionId, prompt, now()]
  );
}

function handlePreTool(db: Database, data: HookData): void {
  const sessionId = getSessionId(data);
  ensureSession(db, sessionId, data.cwd);

  const toolName = data.tool_name || "unknown";
  const toolInput = data.tool_input
    ? truncate(JSON.stringify(data.tool_input), MAX_RESULT_LENGTH)
    : null;

  db.run(
    `INSERT INTO tool_calls (session_id, tool_name, tool_input, created_at) VALUES (?, ?, ?, ?)`,
    [sessionId, toolName, toolInput, now()]
  );
}

function handlePostTool(db: Database, data: HookData): void {
  const sessionId = getSessionId(data);
  const toolName = data.tool_name || "unknown";
  const isError = data.is_error ? 1 : 0;

  let result: string | null = null;
  if (data.tool_result !== undefined) {
    const raw =
      typeof data.tool_result === "string"
        ? data.tool_result
        : JSON.stringify(data.tool_result);
    result = truncate(raw, MAX_RESULT_LENGTH);
  }

  // Update most recent tool call without result
  db.run(
    `UPDATE tool_calls SET tool_result = ?, is_error = ?
     WHERE id = (
       SELECT id FROM tool_calls
       WHERE session_id = ? AND tool_name = ? AND tool_result IS NULL
       ORDER BY created_at DESC LIMIT 1
     )`,
    [result, isError, sessionId, toolName]
  );
}

function handleStop(db: Database, data: HookData): void {
  const sessionId = getSessionId(data);
  db.run(`UPDATE sessions SET ended_at = ? WHERE id = ?`, [now(), sessionId]);
}

// Main
const hookType = Bun.argv[2];
if (!hookType) process.exit(0);

const handlers: Record<string, (db: Database, data: HookData) => void> = {
  user_prompt_submit: handleUserPrompt,
  pre_tool_use: handlePreTool,
  post_tool_use: handlePostTool,
  stop: handleStop,
};

const handler = handlers[hookType];
if (!handler) process.exit(0);

let data: HookData;
try {
  data = JSON.parse(await Bun.stdin.text());
} catch {
  process.exit(0);
}

const db = new Database(DB_PATH);
try {
  ensureSchema(db);
  handler(db, data);
} catch (e) {
  // Log errors but don't block Claude
  const logPath = join(import.meta.dir, "data", "errors.log");
  const file = Bun.file(logPath);
  const existing = (await file.exists()) ? await file.text() : "";
  await Bun.write(logPath, existing + `[${now()}] ${hookType}: ${e}\n`);
} finally {
  db.close();
}
