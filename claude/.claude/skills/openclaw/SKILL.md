---
name: openclaw
description: Talk to Synclaw/OpenClaw AI agent. Use ONLY when user explicitly asks to "talk to Synclaw", "ask OpenClaw", "message Synclaw", "check on Synclaw". For direct server operations (commands, files, git), use the synclaw-server skill instead.
---

# OpenClaw

Interact with OpenClaw server running on `synclaw` via REST API.

## Purpose: Conversation with Synclaw Only

This skill is **only** for talking to Synclaw/OpenClaw - sending messages, checking history, spawning sub-agents. Use this when the user explicitly asks to "talk to Synclaw", "ask OpenClaw", etc.

**For direct server operations** (running commands, reading/writing files), use the `synclaw-server` skill instead, which uses SSH.

## Prerequisites

Environment variables are pre-sourced and available:
- `$OPENCLAW_URL` — Base URL (e.g., `http://synclaw:18789`)
- `$OPENCLAW_TOKEN` — Bearer token for authentication

**Note:** No need to `source ~/.secrets` — variables are already in the environment.

## API Pattern

All tools use POST to `/tools/invoke`:

```bash
curl -s -X POST "$OPENCLAW_URL/tools/invoke" \
  -H "Authorization: Bearer $OPENCLAW_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tool": "<tool_name>", "args": {<args>}}'
```

## Core Tools

### Session Communication (when explicitly requested)

**Send message to Synclaw:**
```bash
curl -s -X POST "$OPENCLAW_URL/tools/invoke" \
  -H "Authorization: Bearer $OPENCLAW_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tool": "sessions_send", "args": {"sessionKey": "agent:main:main", "message": "Your message here"}}'
```

**List sessions:**
```bash
{"tool": "sessions_list", "args": {"limit": 10}}
```

**Get session history:**
```bash
{"tool": "sessions_history", "args": {"sessionKey": "agent:main:main", "limit": 20, "includeTools": true}}
```

**Spawn sub-agent:**
```bash
{"tool": "sessions_spawn", "args": {"task": "Research topic X", "model": "claude-sonnet-4-5"}}
```

### Web/Research

**Web search:**
```bash
{"tool": "web_search", "args": {"query": "search terms", "count": 5}}
```

**Fetch URL:**
```bash
{"tool": "web_fetch", "args": {"url": "https://example.com", "extractMode": "markdown"}}
```

### Memory

**Search Synclaw's memory:**
```bash
{"tool": "memory_search", "args": {"query": "topic", "maxResults": 5}}
```

**Read memory snippet:**
```bash
{"tool": "memory_get", "args": {"path": "memory/file.md"}}
```

### Messaging

**Send to Discord/WhatsApp:**
```bash
{"tool": "message", "args": {"action": "send", "channel": "discord", "target": "channel_id", "message": "Hello"}}
```

### Other Tools

- `cron` — `{action: "list"|"create"|"delete", job?, jobId?}` — scheduled jobs
- `tts` — `{text}` — text to speech
- `image` — `{image, prompt?}` — analyze image
- `session_status` — `{sessionKey?}` — get usage stats

## Common Sessions

- `agent:main:main` — Primary Synclaw session (default)
- WhatsApp/Discord sessions follow pattern: `agent:main:<channel>:<id>`

## Response Format

Successful responses:
```json
{"ok": true, "result": {"content": [...], "details": {...}}}
```

Errors:
```json
{"ok": false, "error": {"type": "...", "message": "..."}}
```

## Tips

- Use `agent:main:main` session key for the primary Synclaw session
- For long-running tasks, use `sessions_spawn` to create sub-agents
- **Announcements:** API messages are silent by default. Include `[announce]` in the message to also post to Discord
- **For direct server operations** (commands, files), use the `synclaw-server` skill instead
