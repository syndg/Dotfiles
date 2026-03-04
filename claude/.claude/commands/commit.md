---
description: Review and commit changes with suggested branch names and messages
allowed-tools: Bash(but:*), Bash(git log:*), Bash(git diff:*), AskUserQuestion, Skill
---

# Smart Commit (GitButler)

Review uncommitted changes, suggest branch + commit messages, execute on approval.

## Prerequisites

Invoke the `gitbutler` skill first for command reference and workspace model context.

## Process

1. Get workspace state:
   ```bash
   but status --json -f
   ```

2. If changes span multiple logical concerns, run:
   ```bash
   but diff --json
   ```
   to get hunk-level IDs for granular commits.

3. Check existing stacks - are we adding to one or need new branch?

4. Propose to user:
   - Branch name (derive from file paths/change patterns)
   - Commit message(s) - group by logical theme
   - Which files/hunks go in each commit
   - Anything excluded (debug code, unrelated changes)

5. Use AskUserQuestion with options:
   - "Approve"
   - "Edit branch name"
   - "Edit commit messages"
   - "Reassign hunks"

6. Execute commits using `but commit` commands.

## Branch Naming Heuristics

- Feature addition → `add-<thing>`
- Bug fix → `fix-<thing>`
- Refactor → `refactor-<scope>`
- Multiple concerns → ask user to pick primary theme
