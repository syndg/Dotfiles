#!/usr/bin/env bun
import { Database } from "bun:sqlite";
import { join } from "path";

const DB_PATH = join(import.meta.dir, "data", "sessions.db");

const command = Bun.argv[2] || "list";
const sessionId = Bun.argv[3];
const format = Bun.argv[4] || "text"; // "text" or "json"

const db = new Database(DB_PATH);

switch (command) {
  case "list": {
    const sessions = db.query(`
      SELECT
        s.id,
        s.started_at,
        s.cwd,
        s.first_prompt,
        s.last_prompt,
        (SELECT COUNT(*) FROM user_inputs WHERE session_id = s.id) as input_count,
        (SELECT COUNT(*) FROM tool_calls WHERE session_id = s.id) as tool_count
      FROM sessions s
      ORDER BY s.started_at DESC
      LIMIT 10
    `).all() as any[];

    if (format === "json") {
      const formatted = sessions.map(s => ({
        id: s.id.slice(0, 8),
        date: new Date(s.started_at).toLocaleString(),
        project: s.cwd?.split("/").pop() || "unknown",
        inputs: s.input_count,
        tools: s.tool_count,
        first: s.first_prompt?.replace(/\n/g, " ").trim() || "(no prompt)",
        last: s.last_prompt?.replace(/\n/g, " ").trim() || "(no prompt)",
      }));
      console.log(JSON.stringify(formatted));
      break;
    }

    console.log("Recent Sessions:\n");
    sessions.forEach((s, i) => {
      const date = new Date(s.started_at).toLocaleString();
      const project = s.cwd?.split("/").pop() || "unknown";
      const first = s.first_prompt?.replace(/\n/g, " ").trim() || "(no prompt)";
      const last = s.last_prompt?.replace(/\n/g, " ").trim() || "(no prompt)";
      console.log(`${i + 1}. [${s.id.slice(0, 8)}] ${date}`);
      console.log(`   Project: ${project} | Inputs: ${s.input_count} | Tools: ${s.tool_count}`);
      console.log(`   First: ${first}`);
      if (s.input_count > 1 && first !== last) {
        console.log(`   Last:  ${last}`);
      }
      console.log();
    });
    break;
  }

  case "get": {
    if (!sessionId) {
      console.error("Usage: prime.ts get <session_id>");
      process.exit(1);
    }

    const session = db.query(`
      SELECT * FROM sessions WHERE id LIKE ? || '%' LIMIT 1
    `).get(sessionId) as any;

    if (!session) {
      console.error(`Session not found: ${sessionId}`);
      process.exit(1);
    }

    const inputs = db.query(`
      SELECT prompt, created_at FROM user_inputs
      WHERE session_id = ? ORDER BY id
    `).all(session.id) as any[];

    const tools = db.query(`
      SELECT tool_name, tool_input, tool_result, is_error, created_at
      FROM tool_calls WHERE session_id = ? ORDER BY id
    `).all(session.id) as any[];

    const project = session.cwd?.split("/").pop() || "unknown";
    console.log(`# Session: ${session.id.slice(0, 8)}`);
    console.log(`Project: ${project}`);
    console.log(`Started: ${new Date(session.started_at).toLocaleString()}`);
    console.log(`Inputs: ${inputs.length} | Tool calls: ${tools.length}`);
    console.log("\n---\n");

    let toolIdx = 0;
    inputs.forEach((input, i) => {
      console.log(`## User Input ${i + 1}`);
      console.log(input.prompt || "(empty)");
      console.log();

      // Show tools used after this input
      while (toolIdx < tools.length && tools[toolIdx].created_at <= (inputs[i + 1]?.created_at || "9999")) {
        const t = tools[toolIdx];
        const status = t.is_error ? " [ERROR]" : "";
        console.log(`**${t.tool_name}**${status}`);
        if (t.tool_input) console.log(`Input: ${t.tool_input.slice(0, 200)}${t.tool_input.length > 200 ? "..." : ""}`);
        if (t.tool_result) console.log(`Result: ${t.tool_result.slice(0, 300)}${t.tool_result.length > 300 ? "..." : ""}`);
        console.log();
        toolIdx++;
      }
      console.log("---\n");
    });
    break;
  }

  default:
    console.log("Usage:");
    console.log("  prime.ts list       - List recent sessions");
    console.log("  prime.ts get <id>   - Get session by ID");
}

db.close();
