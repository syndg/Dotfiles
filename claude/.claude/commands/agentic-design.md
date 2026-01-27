---
description: Analyze codebase structure and session history to design agentic automation layers
allowed-tools: Read, Glob, Grep, Bash
---

# Agentic Design

Design intelligent automation layers using the **Core Four**: context, model, prompt, tools.

## Analysis Process

### 1. Analyze Session History

Query user behavior patterns:

```bash
# Tool usage frequency - reveals repetitive operations
sqlite3 ~/.claude/tools/session-capture/data/sessions.db "SELECT tool_name, COUNT(*) as uses FROM tool_calls GROUP BY tool_name ORDER BY uses DESC LIMIT 20;"

# Recent user prompts - reveals common requests
sqlite3 ~/.claude/tools/session-capture/data/sessions.db "SELECT substr(prompt, 1, 150), created_at FROM user_inputs ORDER BY id DESC LIMIT 30;"

# Session summaries by project - reveals workflow patterns
sqlite3 ~/.claude/tools/session-capture/data/sessions.db "SELECT s.cwd, COUNT(DISTINCT s.id) as sessions, (SELECT COUNT(*) FROM tool_calls WHERE session_id IN (SELECT id FROM sessions WHERE cwd = s.cwd)) as total_tools FROM sessions s GROUP BY s.cwd ORDER BY sessions DESC LIMIT 10;"
```

**Look for:**
- Same prompt 3+ times → slash command candidate
- Repeating tool sequences → skill candidate
- Heavy Read/Grep in specific dirs → specialized agent candidate

### 2. Explore the Codebase

- Main directories and purpose
- Existing automation (scripts, configs, Makefiles)
- `.claude/` folder, CLAUDE.md, existing commands/skills

### 3. Identify Current Agentic Grade

| Grade | Components                  | Capability                            |
| ----- | --------------------------- | ------------------------------------- |
| 1     | Prime prompt + memory file  | Basic agent understanding             |
| 2     | + Plans, docs, sub-agents   | Specialization, basic parallelization |
| 3     | + Custom tools, skills, MCP | Direct system operation               |
| 4     | + Closed-loop prompts       | Self-correcting agents                |
| 5     | + Orchestrator agents       | Full autonomous workflows             |

### 4. Recommend Automation

Based on session + codebase analysis, suggest concrete components.

## Reference Materials

See `~/.claude/skills/agentic-design/docs/` for patterns from IndyDevDan's video summaries.

## Composition Hierarchy

```
Slash Command → Sub-agent (if parallel) → Skill (for domain management)
```

### Slash Commands (`~/.claude/commands/` or `.claude/commands/`)
Single action, manually triggered, repeated task.

### Sub-agents (`~/.claude/agents/` or `.claude/agents/`)
Parallelization, isolated context, specialized expertise. Prompted by primary agent, responds to primary agent.

### Skills (`~/.claude/skills/` or `.claude/skills/`)
Family of related operations (CRUD-like). Orchestrates commands, sub-agents, MCP.

## Decision Framework

```
Single manual action? → Slash Command
Need parallelization/isolation? → Sub-agent
Family of related operations? → Skill
External system integration? → MCP server or script
```

## Principles

1. **Prompts are the primitive** - master slash commands first
2. **Earn complexity** - don't over-engineer
3. **Skills compose** - orchestrate commands, sub-agents, MCP
4. **Problem first** - solve real pains, not demos
