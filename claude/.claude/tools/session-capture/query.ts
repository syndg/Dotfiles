#!/usr/bin/env bun
import { Database } from "bun:sqlite";
import { join } from "path";

const DB_PATH = join(import.meta.dir, "data", "sessions.db");

const db = new Database(DB_PATH);

const command = Bun.argv[2] || "summary";

switch (command) {
  case "sessions":
    console.log(db.query("SELECT * FROM sessions ORDER BY started_at DESC LIMIT 10").all());
    break;

  case "tools":
    console.log(
      db.query(`
        SELECT tool_name, COUNT(*) as uses
        FROM tool_calls
        GROUP BY tool_name
        ORDER BY uses DESC
      `).all()
    );
    break;

  case "recent":
    console.log(
      db.query(`
        SELECT id, tool_name, substr(tool_params, 1, 80) as params, called_at
        FROM tool_calls
        ORDER BY id DESC
        LIMIT 20
      `).all()
    );
    break;

  case "errors":
    console.log(
      db.query(`
        SELECT tool_name, tool_params, tool_result
        FROM tool_calls
        WHERE is_error = 1
        ORDER BY id DESC
        LIMIT 10
      `).all()
    );
    break;

  case "summary":
  default:
    const sessions = db.query("SELECT COUNT(*) as c FROM sessions").get() as { c: number };
    const tools = db.query("SELECT COUNT(*) as c FROM tool_calls").get() as { c: number };
    const turns = db.query("SELECT COUNT(*) as c FROM turns").get() as { c: number };
    const topTools = db.query(`
      SELECT tool_name, COUNT(*) as uses
      FROM tool_calls
      GROUP BY tool_name
      ORDER BY uses DESC
      LIMIT 5
    `).all();

    console.log(`Sessions: ${sessions.c}`);
    console.log(`Turns: ${turns.c}`);
    console.log(`Tool calls: ${tools.c}`);
    console.log(`Top tools:`, topTools);
    break;
}

db.close();
