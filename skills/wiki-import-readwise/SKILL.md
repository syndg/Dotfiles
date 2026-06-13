---
name: wiki-import-readwise
description: Import highlights and documents from Readwise into the knowledge wiki using the Readwise CLI. Searches/browses interactively, then delegates to wiki-fetch-readwise-document and wiki-fetch-readwise-highlights to stream large content to disk and ingest it. Use when the user says "import from Readwise" or "pull my Readwise".
---

# Import from Readwise

Operates on a wiki hub (default `~/Knowledge`) per its `AGENTS.md` / `CLAUDE.md` schema. Pull the user's reading history and highlights from Readwise, then compile them into wiki pages.

**Use the `readwise` CLI for all Readwise access** — it handles authentication, pagination, and rate limiting. Do not use any MCP server, the HTTP API directly, or other methods. All commands run via your agent's shell tool.

When it's time to pull large content into `raw/`, delegate to:

- **`wiki-fetch-readwise-document`** — streams a full Reader document to disk without loading the body into context.
- **`wiki-fetch-readwise-highlights`** — vector-searches highlights, groups by parent doc, writes highlight collections to disk.

## Step 0 — Ensure the Readwise CLI is installed and authenticated

Run in order; fix each issue before continuing.

1. **CLI present?** `which readwise`
2. **If not installed**, check Node: `which node`
   - **If Node exists:** `npm install -g @readwise/cli`
   - **If Node missing:** install it, then install the CLI:
     ```
     curl -fsSL https://nodejs.org/dist/v22.15.0/node-v22.15.0-darwin-arm64.tar.xz | tar -xJ -C /usr/local/lib
     ln -sf /usr/local/lib/node-v22.15.0-darwin-arm64/bin/node /usr/local/bin/node
     ln -sf /usr/local/lib/node-v22.15.0-darwin-arm64/bin/npm /usr/local/bin/npm
     ln -sf /usr/local/lib/node-v22.15.0-darwin-arm64/bin/npx /usr/local/bin/npx
     ```
     Then `npm install -g @readwise/cli`
3. **Authenticated?** `readwise reader-list-documents --limit 1`
4. **If not:** `readwise login` (opens the browser for OAuth — wait for it to complete).

Do not proceed until installed and authenticated.

## Step 1 — Ask what to import

Suggest importing by topic first — it's the most useful starting point:
- **By topic** (recommended) — search docs and highlights related to a subject
- Specific documents (by URL, title, or search)
- Filter by date range or source type (books, articles, podcasts, tweets)
- Mine highlights for material relevant to the wiki

## Step 2 — Search and browse

```bash
readwise reader-search-documents --query "<topic>" --limit 20 --json
readwise reader-list-documents --limit 20 --json
readwise readwise-search-highlights --vector-search-term "<topic>" --limit 30 --json
```

Show results and let the user pick. It's fine to have this metadata (titles, authors, snippets) in context.

**`--json` outputs raw arrays, not `{results: [...]}`** for search — use `jq '.[].title'`, not `jq '.results[].title'`. (`reader-list-documents` is the exception — it returns `{results: [...]}`.)

**Flag gotcha:** `reader-get-document-details` uses `--document-id` (NOT `--id`). See `wiki-fetch-readwise-document` for the full reference.

## Step 2.5 — Update home immediately

Once you know what was found, **update `wiki/home.md` right away** — before fetching/ingesting. Write a brief overview of what's coming: topics found, how many sources, what the wiki will cover. Gives the user something to read while the import runs.

## Step 3 — Fetch into raw/

**Import in small batches.** Fetch and fully ingest 3–5 sources first so the user sees the wiki taking shape before importing more. A few well-connected pages beat a queue of unprocessed raws. After the first batch is browsable, ask whether to continue.

- For **documents**: invoke `wiki-fetch-readwise-document` with the selected doc IDs.
- For **highlights**: invoke `wiki-fetch-readwise-highlights` with the agreed search queries.

Both chain into `wiki-ingest` to create wiki pages from the raws.

**All files in `raw/` must be markdown (`.md`), never JSON.** Temp JSON from CLI queries goes in `/tmp/`. Convert any structured data to readable markdown before saving to `raw/`.

## Step 4 — Ingest (parallelize if you can)

After fetching raw files, do NOT ingest one at a time if your agent supports parallel subagents:

1. **Read the current wiki state yourself first** — `wiki/index.md` and `wiki/home.md`.
2. **Dispatch one subagent per source** (or per 2–3 related sources), all launched together. Each brief includes: the raw file path(s), the current index, the schema reference, and instructions to create the source-summary page, propagate claims, cross-link from 2–3 existing pages, and update `index.md` + `log.md`.
3. **After all complete**, do one pass yourself to: dedupe `index.md` entries, update `home.md` with the full picture, and fix cross-linking gaps between the new pages.

If your agent has no subagents, ingest the batch sequentially with `wiki-ingest`.

## Step 5 — Finish

1. Deduplicate `wiki/index.md` (parallel agents may add overlapping entries).
2. Update `wiki/home.md` to reflect everything imported.
3. Verify `wiki/log.md` has timestamped entries.
4. Scan for cross-linking gaps between pages created by different agents.

Report what was imported and what pages were created.
