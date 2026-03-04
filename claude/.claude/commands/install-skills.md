---
disable-model-invocation: true
description: "Install Claude Code skills from the Dotfiles repo to ~/.claude/skills/"
---

# Install Skills

Install skills from this Dotfiles repository into the user's global `~/.claude/skills/` directory.

## Steps

1. **Scan available skills**: List all directories under the `skills/` directory in this repo (relative to this command file at `claude/.claude/commands/`). The skills directory is at `claude/.claude/skills/` in the Dotfiles repo root. For each skill directory found, read the `SKILL.md` frontmatter to extract the `name` and `description` fields.

2. **Present the list**: Use `AskUserQuestion` with `multiSelect: true` to present all available skills. Each option should have:
   - `label`: The skill directory name
   - `description`: The description from SKILL.md frontmatter (truncated to ~100 chars if long)

3. **Check for conflicts**: For each selected skill, check if `~/.claude/skills/<skill-name>/` already exists. If it does, note it will be overwritten.

4. **Copy skills**: For each selected skill, copy the entire skill directory to `~/.claude/skills/<skill-name>/` using `cp -r`. Create `~/.claude/skills/` if it doesn't exist.

5. **Report results**: List which skills were installed and their paths.

## Important

- The Dotfiles repo path is determined relative to this command file. Walk up from the command file location to find the repo root, then look for `claude/.claude/skills/`.
- Use `dirname` chain or `git rev-parse --show-toplevel` from the Dotfiles repo to find the repo root.
- If `~/.claude/skills` is a symlink (common in dotfile setups), resolve it and copy to the symlink target.
- Do NOT delete any existing skills that weren't selected — only copy/overwrite the selected ones.
