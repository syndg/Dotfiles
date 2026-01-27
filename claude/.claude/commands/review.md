---
description: Review code changes before committing
allowed-tools: Bash(git:*), Read, Grep
---

# Code Review

Review staged/unstaged changes for issues before committing.

## Process

1. Get changes:
   ```bash
   git diff --cached --name-only  # staged files
   git diff --name-only           # unstaged files
   ```

2. For each changed file, run `git diff <file>` and analyze for:

   **Security**
   - Hardcoded secrets, API keys, passwords
   - SQL injection, XSS, command injection
   - Insecure dependencies

   **Bugs**
   - Null/undefined access
   - Off-by-one errors
   - Race conditions
   - Unhandled errors

   **Code Quality**
   - Dead code
   - Duplicate logic
   - Missing error handling
   - Inconsistent naming

   **Performance**
   - N+1 queries
   - Unnecessary re-renders
   - Memory leaks
   - Blocking operations

3. Output format:

   ```
   ## <filename>

   [severity] Line X: <issue>
   > <code snippet>
   Suggestion: <fix>
   ```

   Severities: `CRITICAL` | `WARNING` | `INFO`

4. End with summary:
   ```
   ---
   Critical: X | Warnings: Y | Info: Z

   Ready to commit: YES/NO
   ```

## Rules

- Be concise - one line per issue
- Only flag real problems, not style preferences
- If no issues found, say "LGTM" and confirm ready to commit
