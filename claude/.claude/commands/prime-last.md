---
allowed-tools: Bash(bun:*)
description: Prime conversation with the most recent session (no selection)
---

# Prime Last Session

## Get Sessions

!`bun ~/.claude/tools/session-capture/prime.ts list _ json`

## Instructions

- Parse the JSON above and extract the session ID from the first entry (index 0 = most recent)
- Fetch that session's history: `bun ~/.claude/tools/session-capture/prime.ts get <session_id>`
- Present the conversation history to the user
- Explain this is context from their most recent session
- Ask what they'd like to continue working on
