---
description: Analyze Claude Code session data - tool usage, history, errors
allowed-tools: Bash, Read
---

# Session Analysis

Query captured Claude Code session data from SQLite.

## Database

Path: `~/.claude/tools/session-capture/data/sessions.db`

### Schema

```
sessions: id, started_at, ended_at, cwd, first_prompt, last_prompt
user_inputs: id, session_id, prompt, created_at
tool_calls: id, session_id, tool_name, tool_input, tool_result, is_error, created_at
```

## Quick Queries

```bash
# List recent sessions
bun ~/.claude/tools/session-capture/prime.ts list

# Get session details
bun ~/.claude/tools/session-capture/prime.ts get <session_id>
```

## SQL Examples

Run with: `sqlite3 ~/.claude/tools/session-capture/data/sessions.db "<query>"`

```sql
-- Tool usage frequency
SELECT tool_name, COUNT(*) as uses FROM tool_calls GROUP BY tool_name ORDER BY uses DESC;

-- Recent user prompts
SELECT substr(prompt, 1, 100), created_at FROM user_inputs ORDER BY id DESC LIMIT 10;

-- Errors
SELECT tool_name, tool_input, tool_result FROM tool_calls WHERE is_error = 1 ORDER BY id DESC;

-- Session summary
SELECT s.id, s.cwd,
  (SELECT COUNT(*) FROM user_inputs WHERE session_id = s.id) as inputs,
  (SELECT COUNT(*) FROM tool_calls WHERE session_id = s.id) as tools
FROM sessions s ORDER BY started_at DESC LIMIT 10;

-- Tools by session
SELECT s.cwd, tc.tool_name, COUNT(*) as uses
FROM tool_calls tc JOIN sessions s ON tc.session_id = s.id
GROUP BY s.id, tc.tool_name ORDER BY s.started_at DESC;
```
