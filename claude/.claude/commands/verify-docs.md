---
description: Verify local Claude Code docs against official sources
allowed-tools: Read, Glob, WebFetch, Task
---

# Verify Documentation

Verify the accuracy of local Claude Code documentation against official sources.

## Docs Location

Local docs: `~/.claude/claude-code-docs/`

## Process

1. **List available docs**
```bash
ls ~/.claude/claude-code-docs/
```

2. **For each doc file, verify against official source**

| Local File | Official URL |
|------------|--------------|
| hooks.md | https://code.claude.com/docs/en/hooks-guide |
| plugins.md | https://code.claude.com/docs/en/plugins |
| skills.md | https://code.claude.com/docs/en/skills |
| slash-commands.md | https://code.claude.com/docs/en/slash-commands |

3. **Use the claude-code-guide agent** to fetch and compare each doc:
   - Read the local file
   - Fetch the official documentation
   - Identify discrepancies, outdated info, missing features

4. **Report findings** in this format:

```
## [filename]

**Status**: Current | Outdated | Missing Features

**Accurate**:
- Feature X documented correctly
- Feature Y documented correctly

**Outdated/Missing**:
- Feature Z not documented
- Feature W has changed

**Action**: None needed | Update required
```

## Reference URLs

- Hooks reference: https://code.claude.com/docs/en/hooks
- Plugins reference: https://code.claude.com/docs/en/plugins-reference
- Skills best practices: https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices
- Full docs index: https://code.claude.com/docs/llms.txt
