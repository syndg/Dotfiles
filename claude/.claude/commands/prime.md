---
allowed-tools: Bash(bun:*), AskUserQuestion
argument-hint: [session_id]
description: Prime conversation with previous session history
---

# Prime Session Context

## Recent Sessions (JSON)

!`bun ~/.claude/tools/session-capture/prime.ts list _ json`

## Instructions

If no session ID was provided (`$1` is empty/whitespace or literally "$1"):
- Parse the JSON session list above

**PAGINATION - Use 2 questions in a single AskUserQuestion call:**

Call AskUserQuestion with an array of 2 questions:

**Question 1:** `"Recent sessions"` (header: `"Page 1"`)
- Options: Sessions at indices 0, 1, 2 (up to 3 options)

**Question 2:** `"Older sessions"` (header: `"Page 2"`)
- Options: Sessions at indices 3, 4, 5, 6 (up to 4 options)

**Session option format:**
- `label`: `"<session_id>: <first> → <last>"` (use full `first` and `last` fields from JSON, do not truncate)
- `description`: `"<project>"` (the directory name)

**When user selects a session:**
- Fetch history: `bun ~/.claude/tools/session-capture/prime.ts get <selected_id>`
- Present the conversation history and ask what they'd like to continue

If a session ID was provided (`$1` is not empty and not literally "$1"):
- Fetch that session's history by running: `bun ~/.claude/tools/session-capture/prime.ts get $1`
- Present the conversation history to the user
- Explain this is the context from their previous session
- Ask what they'd like to continue working on or if they need a summary

The session history includes:
- User messages and assistant responses
- Tools that were used in each turn
- Project context (working directory)
