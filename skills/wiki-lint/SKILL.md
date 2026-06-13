---
name: wiki-lint
description: Health-check the knowledge wiki and fix what can be fixed — orphan pages, dead-ends, broken/missing cross-links — and flag contradictions and stale claims. Use when the user says "lint", "health-check the wiki", or "clean up the wiki".
---

# Lint the wiki

Operates on a wiki hub (default `~/Knowledge`) per its `AGENTS.md` / `CLAUDE.md` schema.

Scan every page in `wiki/` and check for:

1. **Orphan pages (highest priority)** — pages not linked from any other page. For each, find 2–3 related pages and add `[[wikilinks]]` to them. Don't just report orphans — fix them.
2. **Dead-end pages** — pages with no outbound `[[wikilinks]]`. Add links to related concepts/sources.
3. **Missing cross-links** — pages discussing the same topic that don't link to each other. Add the links.
4. **Contradictions** — claims on one page conflicting with another. Mark with `> [!contradiction]` callouts.
5. **Broken wikilinks** — `[[links]]` pointing to pages that don't exist. Fix or remove them.
6. **Stale claims** — claims citing sources that have been superseded or are very old.
7. **Stale `home.md`** — if it doesn't reflect the current state (missing major themes, outdated narrative), update it.

**Fix, don't just report.** For items 1–3 and 5, make the edits yourself. For items 4 and 6–7, report findings and suggest fixes (and apply the clear ones).

Report what was fixed and what needs human review. Suggest new questions worth investigating or sources worth seeking out.

Append to `wiki/log.md` (at the top): `## [YYYY-MM-DD HH:MM] lint | <summary>`.

## Notes

- Tool-agnostic: use your agent's file-search (grep/find equivalents) to locate orphans and broken links — e.g. for each page, check whether any other page contains a `[[link]]` to it.
