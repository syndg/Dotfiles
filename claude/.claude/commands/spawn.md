---
description: Spawn parallel Claude sessions in worktrees
allowed-tools: Bash, Read, Write, Edit, Glob, AskUserQuestion, Skill
argument-hint: <branch1> [branch2] [branch3] | list | cleanup | rm <name>...
---

# Spawn

Create worktrees and open Ghostty tabs for parallel Claude sessions using the project's `wt` tool.

**Arguments**: `$ARGUMENTS`

## Prerequisites - Ensure `wt` Tool Exists

Before any operation, check if the project has a `wt` tool:

```bash
ROOT=$(git rev-parse --show-toplevel)
WT_TOOL="$ROOT/.claude/tools/wt"

if [[ ! -x "$WT_TOOL" ]]; then
    echo "No wt tool found in this project."
    # Run /install-wt to scaffold one
fi
```

**If `wt` tool doesn't exist:** Use the Skill tool to invoke `/install-wt` first, then continue.

## Quick Actions

| Input | Action | wt Command |
|-------|--------|------------|
| `<branch1> [branch2] ...` | Create worktrees + open tabs | `wt spawn <branches>...` |
| `list` / `ls` | Show worktrees | `wt ls` |
| `cleanup` | Remove merged worktrees | See cleanup section |
| `rm <name>...` | Remove specific worktrees | `wt rm <names>...` |
| `tab <name>...` | Open tabs for existing worktrees | `wt tab <names>...` |

## Execution

### 1. Check for `wt` Tool

```bash
ROOT=$(git rev-parse --show-toplevel)
WT_TOOL="$ROOT/.claude/tools/wt"

if [[ ! -x "$WT_TOOL" ]]; then
    echo "wt tool not found. Installing..."
    # Use Skill tool: /install-wt
    exit 1  # After install-wt completes, re-run spawn
fi
```

### 2. Parse Arguments and Delegate to `wt`

**Spawn branches:**
```bash
# /spawn feat/auth feat/api feat/ui
"$WT_TOOL" spawn feat/auth feat/api feat/ui
```

**List worktrees:**
```bash
# /spawn list
"$WT_TOOL" ls
```

**Remove worktrees:**
```bash
# /spawn rm feat/old test/wip
"$WT_TOOL" rm -fb feat/old test/wip
```

**Open tabs for existing worktrees:**
```bash
# /spawn tab feat/auth feat/api
"$WT_TOOL" tab feat/auth feat/api
```

**Cleanup merged:**
```bash
# /spawn cleanup
ROOT=$(git rev-parse --show-toplevel)
WT_DIR="$ROOT/.worktrees"

# Find worktrees with branches merged to main
git worktree list --porcelain | grep "^worktree $WT_DIR" | cut -d' ' -f2 | while read wt; do
    branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if git -C "$ROOT" branch --merged main 2>/dev/null | grep -qw "$branch"; then
        echo "Merged: $branch"
        "$WT_TOOL" rm -fb "$branch"
    fi
done
```

## Command Mapping

| /spawn Command | wt Tool Command |
|----------------|-----------------|
| `/spawn feat/a feat/b` | `wt spawn feat/a feat/b` |
| `/spawn list` | `wt ls` |
| `/spawn rm feat/a` | `wt rm feat/a` |
| `/spawn rm -fb feat/a feat/b` | `wt rm -fb feat/a feat/b` |
| `/spawn tab feat/a` | `wt tab feat/a` |
| `/spawn cleanup` | Loop + `wt rm -fb` |
| `/spawn setup feat/a` | `wt setup feat/a` |

## Workflow

1. **Check `wt` exists** → if not, invoke `/install-wt`
2. **Parse arguments** → determine action (spawn/list/rm/tab/cleanup)
3. **Execute via `wt`** → delegate to project's wt tool
4. **Report results** → show what was created/removed/opened

## Output Examples

**After spawning:**
```
Spawning 3 worktree(s)...

✓ Created: feat/auth
✓ Created: feat/api
✓ Created: feat/ui

Opening 3 Ghostty tab(s)...

Spawned 3 worktree(s), opened 3 tab(s)
Run claude in each tab to start sessions
```

**After cleanup:**
```
Merged: feat/old-feature
✓ Removed worktree: feat/old-feature
✓ Deleted branch: feat/old-feature

Cleaned up 1 merged worktree(s)
```

## Error Handling

- If `wt` tool not found → run `/install-wt` first
- If `wt` tool is outdated → suggest running `/install-wt` to update
- If branch already exists → `wt spawn` will use existing worktree and just open tab
