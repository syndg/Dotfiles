---
name: spawn
description: Spawn parallel Claude sessions in worktrees. Use when the user asks to "spawn", "hand off", "run in parallel", "create a worktree", or wants to launch a coding agent on a separate task. Also covers the full PR-based worktree lifecycle — committing (wt-commit), creating PRs (wt-pr), cleaning up (wt-done), and opening project workspaces (wt-project).
---

# Spawn — Parallel Agentic Worktree Workflow

PR-based workflow: spawn worktrees in cmux panes, agent works, commit, push, PR, cleanup. No local merge.

## Commands

All commands are shell functions in `~/.zsh/functions.zsh`.

### wt-spawn — Create worktree + cmux pane + launch agent

```bash
wt-spawn <branch> [-- 'task description']
```

Creates a cmux pane (quad layout: TL→TR→BL→BR), creates a worktree from latest main, launches Claude with the task.

```bash
wt-spawn fix-auth -- 'Fix the session timeout bug in auth middleware'
wt-spawn add-search -- 'Add search to the products page'
```

Quad layout logic: 1 pane → split right, 2 panes → split down (left), 3 panes → split down (right). Max 4 quadrants.

### wt-commit — Stage + LLM commit message + review

```bash
wt-commit
```

Stages all changes, generates commit message via Claude Haiku, shows it for approval. User confirms with `y`.

### wt-pr — Push + LLM PR description + create

```bash
wt-pr
```

Pushes branch to origin, generates PR title and body via Claude Haiku, shows for approval. Creates PR via `gh`.

### wt-done — Cleanup worktree

```bash
wt-done
```

Removes the current worktree and branch, switches back to main.

### wt-project — New cmux workspace for a project

```bash
wt-project <path> [name]
```

Creates a cmux workspace, cd's into the project, names the workspace.

```bash
wt-project /Volumes/External/Coding/deck deck
```

## Workflow Sequence

```
wt-project ~/Code/myapp myapp         # open project workspace
wt-spawn fix-auth -- 'Fix auth bug'   # agent starts in new pane
# ... agent works ...
# pane flashes when agent needs attention
# click into pane, review work
wt-commit                              # LLM commit, approve
wt-pr                                  # push + LLM PR, approve
wt-done                                # cleanup worktree
```

## Agent Handoff

When the user says "spawn a worktree for X" or "hand off X to another agent", run:

```bash
wt-spawn <branch-name> -- '<task description>'
```

Pick a descriptive branch name from the task. The agent launches in an isolated worktree with full context.

## Configuration

### User config (`~/.config/worktrunk/config.toml`)
- `pre-switch`: auto-pulls main if stale (>5 min)
- `post-create`: copies .env, node_modules, caches via `wt step copy-ignored`
- `commit.generation`: Claude Haiku for LLM commit messages

### Per-project (`.config/wt.toml`) — optional
- `pre-merge` hooks for local CI gates (lint, test)
- `post-start` hooks for dev servers

## Important Notes

- Workflow is PR-based — never use `wt merge` for local merging
- Every worktree branches from latest remote main (pre-switch auto-pull)
- `wt-commit` and `wt-pr` always show generated content for user approval
- Agents can call `wt-commit`, `wt-pr`, `wt-done` directly via Bash tool
- `wt-spawn` only works inside cmux (requires `cmux` CLI)
