---
name: wiki-ingest-new
description: >
  Catch-up ingest — scan the wiki's raw/ directory for sources that haven't been
  ingested yet (no matching wiki/sources/ page) and ingest them all in one pass.
  Use when the user says "ingest new", "catch up", "ingest everything new", "ingest
  what I clipped", or wants to process a backlog of clipped/fetched raw files at once.
  Invokable via /wiki-ingest-new.
---

# Catch-up ingest

Operates on a wiki hub (default `~/Knowledge`) per its `AGENTS.md` / `CLAUDE.md` schema.
Finds raw sources that exist on disk but haven't been turned into wiki pages yet, and
ingests each one. This is the batch counterpart to `wiki-ingest` (single source).

## Step 1 — Find un-ingested raws

A raw file is "ingested" if some `wiki/sources/*.md` page references it in its `raw:`
frontmatter. List the raws that are **not** referenced anywhere:

```bash
cd ~/Knowledge   # or the wiki hub root

# All raw markdown sources (skip the assets dir and .gitkeep)
find raw -name '*.md' -not -path 'raw/assets/*' | sort > /tmp/wiki_all_raws.txt

# Everything already referenced by a source page's `raw:` frontmatter
grep -rho '^raw:.*' wiki/sources/ 2>/dev/null \
  | sed -E 's/^raw:[[:space:]]*//; s/^"//; s/"$//' \
  | sort -u > /tmp/wiki_ingested_raws.txt

# The difference = un-ingested
comm -23 /tmp/wiki_all_raws.txt /tmp/wiki_ingested_raws.txt
```

Notes:
- Match on the path as written in `raw:` (e.g. `raw/foo.md`). If your source pages store
  just a basename, compare basenames instead.
- If the list is empty, report "nothing new to ingest" and stop.
- Show the user the list of new files before ingesting (unless running unattended).

## Step 2 — Ingest each new raw

**Route by type first.** Before ingesting a file, check its frontmatter:
- `clip-type: song` (or it's clearly a song link) → ingest with **`wiki-ingest-song`**.
- otherwise → ingest with **`wiki-ingest`**.

You can pre-sort the list with a quick check, e.g.:

```bash
# songs among the un-ingested list
grep -l '^clip-type:[[:space:]]*song' <un-ingested files> 2>/dev/null
```

When ingesting a backlog of songs, offer the batch escape hatch from `wiki-ingest-song`
(ask gap questions per song, or "just do what you can" for hands-off).

Then follow the appropriate skill for every file in the list. Two modes:

**If your agent supports parallel subagents** (preferred for a backlog):
1. Read the current wiki state yourself first — `wiki/index.md` and `wiki/home.md`.
2. Dispatch one subagent per new raw (or per 2–3 related ones), launched together. Each
   brief: the raw path, the current index, the schema reference, and instructions to
   create the source-summary page, propagate claims, cross-link from 2–3 existing pages,
   and update `index.md` + `log.md`.
3. After all complete, do one reconciliation pass yourself (Step 3).

**If no subagents:** ingest the files one at a time with `wiki-ingest`, in sequence.

## Step 3 — Reconcile (always, after a batch)

Parallel/independent ingests can drift. Do a single cleanup pass:

1. **Dedupe `wiki/index.md`** — multiple ingests may add overlapping or duplicate entries.
2. **Cross-link gaps** — pages created in the same batch may not link to each other yet;
   add the missing `[[wikilinks]]`. No orphans.
3. **Update `wiki/home.md`** — revise the narrative to reflect everything just added.
4. **Verify `wiki/log.md`** — one timestamped entry per source (or one batch entry that
   names them).

## Step 4 — Report

List what was ingested (filenames → new source pages), any new concept/entity pages, and
any contradictions or open threads surfaced. Then, if the user wants persistence, commit:
`git add -A && git commit && git push` (only if the hub is a git repo and the user hasn't
said they'll commit themselves).

## Notes

- **Never modify `raw/`.** Read-only.
- Honor the same fidelity rule as `wiki-ingest`: don't invent facts; flag gaps as open
  threads rather than filling them with assumptions.
- This skill is the unit a scheduler/file-watcher would call to make ingestion hands-off.
  Running it on a timer (e.g. macOS launchd) + auto-commit makes the wiki self-updating.
- Tool-agnostic: use whatever shell/file tools your agent provides.
