---
description: Generate and create a git commit with smart message
allowed-tools: Bash(git:*), AskUserQuestion
---

# Smart Commit

Generate a commit message and create the commit.

## Process

1. Run in parallel:

   - `git status` (no -uall flag)
   - `git diff --cached` (staged changes)
   - `git diff` (unstaged changes)
   - `git log --oneline -5` (recent commit style)

2. If no staged changes, ask user what to stage:

   - "All changes"
   - "Select files" (then list modified files as options)

3. Analyze changes and draft commit message:

   - Follow conventional commits if repo uses them
   - Otherwise match existing commit style
   - Focus on "why" not "what"
   - 1-2 sentences max

4. Present commit message to user with options:

   - "Commit" (proceed)
   - "Edit" (let user modify)
   - "Cancel"

5. If approved, run:

   ```bash
   git commit -m "$(cat <<'EOF'
   <message>
   EOF
   )"
   ```

6. Show `git status` after commit to confirm success.

## Rules

- NEVER use `git add .` without user consent
- NEVER commit files that look like secrets (.env, credentials, keys)
- NEVER amend commits unless explicitly requested
- NEVER push unless explicitly requested
