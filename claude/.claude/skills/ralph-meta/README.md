# ralph-meta

A Claude Code skill that generates an **agentic build loop** for any project — a structured PRD + customized bash script that builds your project autonomously using Claude Code headless mode.

## What It Does

You describe a project idea. The skill grills you with questions about your stack, architecture, data model, build tooling, and constraints. Then it generates two files:

1. **`PRD.md`** — A phased implementation plan with atomic, checkbox-tracked tasks
2. **`ralph.sh`** — A bash script that feeds each task to Claude Code headless, validates between phases, self-heals on failures, and commits per phase

## Usage

```
/ralph-meta Build a customer support portal with Next.js and Supabase
```

## How the Loop Works

```
PRD.md (you approve)        ralph.sh reads it           Claude builds each task
┌──────────────┐       ┌─────────────────────┐     ┌────────────────────────┐
│ Phase 1       │       │ Parse task list      │     │ claude -p "prompt..."  │
│  ☐ Task 1.1  │  ──►  │ Check [x] done?      │ ──► │ - reads PRD.md         │
│  ☐ Task 1.2  │       │ Skip if done         │     │ - reads FINDINGS.md    │
│ Phase 2       │       │ Run if pending       │     │ - implements the task  │
│  ☐ Task 2.1  │       │ Mark [x] when done   │     │ - logs findings        │
└──────────────┘       └─────────────────────┘     └────────────────────────┘
                                │
                                ▼
                      ┌─────────────────────┐
                      │ Phase boundary?      │
                      │ → Run sanity checks  │
                      │ → Fix if broken (3x) │
                      │ → Git commit         │
                      └─────────────────────┘
```

### Key Properties

- **Resumable** — Tracks progress via `[x]` checkboxes. Stop and restart anytime.
- **Self-healing** — Build breaks? Claude gets the error output and tries to fix it (up to 3 attempts).
- **Atomic commits** — One git commit per phase, not per task.
- **Context-carrying** — `FINDINGS.md` passes decisions between tasks so Claude doesn't contradict itself.
- **Stack-agnostic** — Works with any language, framework, or toolchain. You specify the validation commands.

## What Gets Generated

### PRD.md

A markdown file with phased, checkbox-tracked tasks:

```markdown
## Phase 1: Setup

- [ ] **1.1** Install dependencies
  bun add express prisma @prisma/client

- [ ] **1.2** Create database schema
  Create prisma/schema.prisma with User and Post models...
```

Each task targets 1-2 files max with exact file paths, function signatures, and expected behavior.

### ralph.sh

A customized bash script with:

- **Task list** matching your PRD
- **Sanity checks** using your stack's validation commands (tsc, pytest, cargo check, etc.)
- **Prompt template** with your project-specific rules and constraints
- **Model + tools** configuration for Claude Code headless

### FINDINGS.md (generated at runtime)

Institutional memory between tasks. Each task logs what it did, decisions made, and notes for future tasks.

## Running the Loop

```bash
chmod +x ralph.sh
./ralph.sh
```

**Resume after stopping:** `./ralph.sh` — skips completed tasks automatically.
**Re-run a task:** Change `[x]` back to `[ ]` in PRD.md, then run again.

## Files

```
ralph-meta/
├── SKILL.md                    # Skill instructions (the interrogation + generation flow)
├── README.md                   # This file
└── references/
    └── script-template.sh      # Base ralph.sh template that gets customized
```

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Git repository initialized
- Project directory scaffolded (the loop builds features, not boilerplate)

## Installation

Copy this skill directory to `~/.claude/skills/ralph-meta/`, or use the `/install-skills` command from the Dotfiles repo to install interactively.
