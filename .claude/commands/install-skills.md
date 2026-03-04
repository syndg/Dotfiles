---
disable-model-invocation: true
description: "Install Claude Code skills from this Dotfiles repo to ~/.claude/skills/"
---

# Install Skills

Install skills from this repository into the user's global `~/.claude/skills/` directory.

## Steps

1. **Find the repo root**: Run `git rev-parse --show-toplevel` to get the repo root path. The skills directory is at `<repo-root>/claude/.claude/skills/`.

2. **Scan available skills**: List all subdirectories under that skills directory. For each one, read its `SKILL.md` and extract the `name` and `description` fields from the YAML frontmatter.

3. **Present the list**: Use `AskUserQuestion` with `multiSelect: true` to present all discovered skills. Each option:
   - `label`: The skill directory name
   - `description`: The description from SKILL.md frontmatter (truncated to ~100 chars if needed)

4. **Copy skills**: For each selected skill:
   - Create `~/.claude/skills/` if it doesn't exist (`mkdir -p`)
   - If `~/.claude/skills/<skill-name>/` already exists, note it will be overwritten
   - Copy the entire skill directory: `cp -r <repo-root>/claude/.claude/skills/<skill-name> ~/.claude/skills/`

5. **Report results**: List which skills were installed and their final paths.

## Important

- The skills source is always `<repo-root>/claude/.claude/skills/` — use `git rev-parse --show-toplevel` to locate it.
- If `~/.claude/skills` is a symlink, resolve it with `readlink` and copy to the resolved target.
- Do NOT delete existing skills that weren't selected — only copy/overwrite selected ones.
