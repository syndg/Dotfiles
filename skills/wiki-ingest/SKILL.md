---
name: wiki-ingest
description: Ingest a source into the knowledge wiki — read it, save the raw, create a source-summary page, propagate claims into concept/entity pages, cross-link, and update index and log. Use when the user says "ingest", "add this source", or pastes a URL/file/text to file into the wiki.
---

# Ingest a source

Operates on a wiki hub (default `~/Knowledge`) laid out per its `AGENTS.md` / `CLAUDE.md` schema — read that schema once before starting if you haven't this session.

Take the source provided by the user (URL, file path, or pasted text). Then:

1. **Save the raw source** into `raw/` as an immutable markdown document. Never edit `raw/` after writing.
2. **Create a source-summary page** at `wiki/sources/<slug>.md` with frontmatter (`type`, `date`, `author`, `url`, `raw`). If the raw contains good images, include the best ones — they make source pages far more useful to browse.
3. **Propagate claims** — update or create concept/entity pages at the `wiki/` root that this source affects. Cite the source inline with `([[slug]])`.
4. **Cross-link aggressively** — this is the step most often skipped and the most important:
   - Read `wiki/index.md` to find every page related to the new material.
   - **Add `[[wikilinks]]` FROM existing pages TO the new pages.** Open 2–3 related existing pages and edit them to reference the new content where relevant.
   - **Add `[[wikilinks]]` FROM new pages TO existing pages.** Every new page links out to related concepts, entities, and sources already in the wiki.
   - The goal: no orphans. Every new page should have inbound links from existing pages AND outbound links to them.
5. **Update `wiki/index.md`** — add the new page(s) to the catalog with one-line summaries, under the right category.
6. **Update `wiki/home.md`** — if the source materially changes the narrative or adds a new theme, revise it. Don't wait for the wiki to be "complete."
7. **Append to `wiki/log.md`** — add a timestamped entry at the top: `## [YYYY-MM-DD HH:MM] ingest | <title>`.

After ingesting, report what pages were created or updated, and list the cross-links added (which existing pages now link to the new content).

## Verification before commit

Before committing an ingest, run a lightweight graph sanity check:

- Scan all `wiki/**/*.md` wikilinks and verify every `[[target]]` resolves to an existing page stem (allow documented virtual links like `[[AGENTS]]` if the repo uses them).
- For every newly created wiki page, list inbound links from existing pages; a new page with zero inbound links is not integrated.
- Check `git diff --stat` and skim the diff for accidental edits outside `wiki/` or the intended `raw/` capture.
- Commit and push only after `wiki/index.md` and `wiki/log.md` are updated and `git status --short --branch` is clean after push.

A simple Python one-off is fine for the wikilink/inbound scan; do not turn this into a heavy test suite unless the repo already has one.

## Notes

- Keep `wiki/` flat — the only allowed subdirectory is `wiki/sources/`.
- Don't invent facts. If the source doesn't say it, don't claim it.
- For a deeper ripple across many existing pages, follow up with the `wiki-digest` skill.
- This skill is tool-agnostic: use whatever file-read/-write and shell tools your agent provides.
