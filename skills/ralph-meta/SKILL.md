---
name: ralph-meta
description: "Generate an agentic build loop (PRD + bash script) for any project. Takes a project idea, grills the user with targeted questions about stack, architecture, validation, and constraints, then outputs a PRD.md with atomic tasks and a customized ralph.sh automation script. Use when the user wants to automate building a project with Claude Code headless mode."
argument-hint: "[project idea or description]"
disable-model-invocation: true
---

# Ralph Meta — Agentic Loop Generator

Generate a complete agentic build automation setup: a structured PRD.md with atomic tasks + a customized ralph.sh bash script that executes them via Claude Code headless mode.

## Process

The workflow has 3 stages: **Interrogate → Generate → Deliver**. Use `AskUserQuestion` for all questioning. Be direct — no fluff.

---

### Stage 1: Interrogate

Grill the user until you have a complete, unambiguous picture of what they're building. There is **no round limit** — keep asking until every dimension below is covered and you are confident you can generate a precise PRD without guessing.

Adapt questions based on prior answers — skip irrelevant ones, dig deeper where ambiguity remains. After each round, briefly acknowledge answers and identify what's still unclear before continuing.

#### Dimensions to Cover

Work through these areas. Not every area applies to every project — skip what's irrelevant, but don't skip what's ambiguous.

**Project Shape:**
- What type of project? (web app, API, CLI tool, data pipeline, library, mobile app, automation scripts, etc.)
- Primary language? (TypeScript, Python, Go, Rust, Ruby, Java, etc.)
- Starting from scratch or existing scaffold? If existing, what's already set up?

**Stack & Architecture:**
- Framework/runtime? (Next.js, FastAPI, Express, Django, Gin, Actix, Rails, etc.)
- Database? (PostgreSQL, MongoDB, SQLite, Convex, Supabase, none, etc.)
- Package manager? (bun, npm, pnpm, pip/uv, cargo, go mod, bundler, etc.)
- Hosting/deployment target? (Vercel, AWS, Fly.io, self-hosted, Docker, etc.)
- Any external APIs or third-party services?

**Data Model & Entities:**
- Key entities/models in the system? (e.g., "Users, Posts, Comments" or "Orders, Products, Inventory")
- Relationships between entities?
- Any specific fields, constraints, or validation rules?

**Features & Behavior:**
- What are the core features / user-facing workflows?
- Any authentication/authorization requirements?
- Any real-time features (WebSockets, SSE, polling)?
- UI requirements — what pages/views exist? Any design system or component library?
- Any background jobs, cron tasks, or async processing?

**Build & Validation:**
- What commands validate a healthy build? (typecheck, lint, build, test — exact commands)
- Any access constraints? (e.g., no .env file access, no file deletion, no network calls, specific directories off-limits)
- Any existing CI/CD or testing setup?

**Claude Code Configuration:**
- Any specific Claude Code skills to use? (e.g., `/frontend-design` for UI tasks) — provide "None" as an option
- Any MCP tools to use? (e.g., context7 for docs lookup) — provide "None" as an option
- Model preference? (sonnet for speed/cost, opus for complex tasks, haiku for trivial tasks)
- Estimated scope? (small: 3-4 phases / 10-15 tasks, medium: 5-6 phases / 15-25 tasks, large: 7+ phases / 25+ tasks)

#### Questioning Rules

- Use multiple-choice options via `AskUserQuestion` whenever possible. Always include context in option descriptions.
- Group related questions into single AskUserQuestion calls (2-4 questions per call). Don't ask one at a time — but don't cram 6 questions into one call either.
- If the user's initial `$ARGUMENTS` already answers some questions, skip those — don't re-ask what's obvious.
- If a question doesn't apply (e.g., no database for a CLI tool), skip it entirely.
- After each round, briefly acknowledge answers, summarize what you now know, and state what's still unclear before continuing.
- When you believe you have enough to generate a precise PRD, state your understanding in a brief summary and ask the user to confirm before proceeding to generation. Use AskUserQuestion with a "Looks good, generate it" / "I have corrections" choice.
- If the user says "just go with defaults" or similar, make reasonable choices, state them, and proceed.

---

### Stage 2: Generate

After interrogation, generate two files. Read `references/script-template.sh` in this skill's directory for the base script structure.

#### 2A: Generate PRD.md

Write `PRD.md` to the user's project directory.

**Format rules — these are non-negotiable:**

```markdown
# [Project Name] — PRD & Implementation Plan

[1-2 sentence summary of what this builds.]

Atomic tasks for phased implementation. Each task targets 1-2 files max.
Track progress with checkboxes. Log decisions/findings in `FINDINGS.md`.

---

## Phase N: [Phase Name]

- [ ] **N.M** [Short imperative task title]
  [Detailed implementation instructions: exact file paths to create/modify,
   function signatures, expected behavior, which libraries/APIs to use.
   Be specific enough that Claude can implement without guessing.]

---

## Execution Order

| Step | Task | Phase |
|------|------|-------|
| 1 | N.M [title] | N |
```

**Task design rules:**

1. **Checkbox format**: `- [ ] **N.M**` exactly. N = phase number, M = task number within phase. The script regex-matches this pattern.
2. **1-2 files per task max.** If a task needs 3+ files, split it.
3. **Imperative titles**: "Create X", "Add Y", "Update Z" — not "X should be created".
4. **Include file paths**: Every task must name the exact file(s) to create or modify.
5. **Include function signatures**: If the task creates functions, specify names, params, return types.
6. **Dependencies flow downward**: Task 2.1 can depend on 1.x tasks but not on 3.x tasks.
7. **Each phase = buildable state**: The project should typecheck/lint/build at the end of each phase, even if incomplete.
8. **Phase grouping convention**:
   - Phase 1: Dependencies, configuration, scaffolding
   - Phase 2: Data layer (schema, models, migrations)
   - Middle phases: Core logic, then API/routes, then UI
   - Last phase: Polish (metadata, error handling, toasts, redirects)
9. **3-6 tasks per phase** is ideal. More than 6 means the phase should be split.
10. **Include the execution order table** at the end — it's the script's source of truth.

#### 2B: Generate ralph.sh

Write `ralph.sh` to the user's project directory. Base it on the template in `references/script-template.sh` and customize:

1. **`TASKS` array**: Every task from the PRD, format `"task_id|phase|description"`.
2. **`get_phase_name()`**: Map phase numbers to names from the PRD.
3. **`run_task()` prompt**: Customize the RULES section based on user's answers:
   - Package manager constraint
   - Access constraints (e.g., no .env, no rm)
   - Skills to invoke (e.g., `/frontend-design` for UI tasks)
   - MCP tools to use (e.g., context7 for doc lookups)
   - Stack-specific rules (e.g., "use shadcn components", "use SQLAlchemy ORM")
4. **`run_sanity_checks()`**: Use the exact validation commands the user specified. Make checks phase-conditional if some only apply after certain phases (e.g., tests only after test files exist).
5. **`--model`**: User's model preference.
6. **`--allowedTools`**: Include `Bash,Read,Write,Edit,Glob,Grep` as baseline. Add `Skill` if skills are needed. Add specific MCP tool names if specified.
7. **UI task handling**: If the project has UI/frontend work, add the `UI_TASKS` array and `is_ui_task()` function pattern that injects `/frontend-design` skill instructions for those specific tasks.
8. **`sed` syntax**: Detect platform — use `sed -i ''` for macOS, `sed -i` for Linux. Default to macOS since that's most Claude Code users. Add a comment noting the Linux alternative.

#### Output Quality Checks

Before writing the files, verify:

- [ ] Every task ID in `TASKS` array matches a `- [ ] **N.M**` checkbox in PRD.md
- [ ] Phase numbers are contiguous (1, 2, 3... no gaps)
- [ ] No task touches more than 2 files
- [ ] Phase names in `get_phase_name()` match PRD section headers
- [ ] Sanity check commands match what the user specified
- [ ] The prompt RULES section includes all user-specified constraints
- [ ] The `--allowedTools` list includes all necessary tools

---

### Stage 3: Deliver

After writing both files, output a brief summary:

1. **What was generated**: file paths for PRD.md and ralph.sh
2. **Quick start**: `chmod +x ralph.sh && ./ralph.sh`
3. **Prerequisites**: anything the user needs to do first (e.g., "scaffold the project", "install deps", "set up .env")
4. **How to resume**: "Just run `./ralph.sh` again — it skips completed tasks"
5. **How to re-run a task**: "Change `[x]` back to `[ ]` in PRD.md for that task"
6. **Outputs to expect**: PRD.md gets checkmarks, FINDINGS.md gets populated, ralph.log gets the full trace, one git commit per phase

Do NOT over-explain. Keep the delivery under 20 lines.
