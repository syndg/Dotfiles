---
disable-model-invocation: true
description: "Link shared skills from this Dotfiles repo into ~/.claude/skills/ and ~/.agents/skills/"
---

# Install Skills

Link the shared skills directory from this repository into the user's global `~/.claude/skills/` and `~/.agents/skills/` directories.

## Steps

1. **Find the repo root**: Run `git rev-parse --show-toplevel` to get the repo root path. The skills directory is at `<repo-root>/skills/`.

2. **Scan available skills**: List all subdirectories under that skills directory. For each one, read its `SKILL.md` and extract the `name` and `description` fields from the YAML frontmatter.

3. **Present the list**: Use `AskUserQuestion` with `multiSelect: true` to present all discovered skills. Each option:
   - `label`: The skill directory name
   - `description`: The description from SKILL.md frontmatter (truncated to ~100 chars if needed)

4. **Create shared symlinks**:
   - Create `~/.claude/` and `~/.agents/` if they don't exist (`mkdir -p`)
   - Remove or replace any existing `~/.claude/skills` and `~/.agents/skills` entries
   - Symlink both directories to the shared source: `ln -s <repo-root>/skills ~/.claude/skills` and `ln -s <repo-root>/skills ~/.agents/skills`

5. **Report results**: List the shared source path and confirm both final symlink targets.

## Important

- The skills source is always `<repo-root>/skills/` — use `git rev-parse --show-toplevel` to locate it.
- `~/.claude/skills` and `~/.agents/skills` should both point to the same shared directory.
- Preserve or migrate any agent-only skills before replacing a real directory with a symlink.
