---
name: wiki-fetch-readwise-document
description: Fetch one or more Readwise Reader documents into the wiki's raw/ without loading bodies into context. Streams content to disk via a jq pipe, then chains into wiki-ingest. Called by wiki-import-readwise; can also be used directly.
---

# Fetch Readwise document

Grab a Reader document (or several) and drop it into `raw/` **without ever loading the full body into context**. Only small metadata (title, author, url, date, category, doc_id) belongs in context. The body streams from the CLI to a file via a pipe.

## Preconditions

- `readwise` CLI installed and authenticated (see `wiki-import-readwise` Step 0).
- `jq` installed (`brew install jq` if missing).
- A `raw/` directory exists in the wiki hub.

## Core pattern (single doc)

Given a Readwise URL (`https://read.readwise.io/read/<id>`), a bare doc_id, or a search query:

### Step 1 — Resolve doc_id

If the user gave a URL, the id is the last path segment — no CLI call needed.

For a **specific title**, use `--title-search` (`--query` is also required even when filtering by title):

```bash
readwise reader-search-documents --query "<title words>" --title-search "<title words>" --limit 5 --json \
  | jq -r '.[] | "\(.document_id)\t\(.title)\t\(.author)\t\(.category)"'
```

For a topical search, use `--query` alone; add `--author-search` when you know the author. Show candidates if ambiguous.

### Step 2 — Fetch metadata (mandatory)

`reader-get-document-details` does **not** return `image_url`, `source_url`, `published_date`, `word_count`, or `site_name`. Pull those from `reader-list-documents`:

```bash
readwise reader-list-documents --id <DOC_ID> \
  --response-fields title,author,url,source_url,category,published_date,saved_at,site_name,word_count,image_url \
  --json | jq '.results[0]'
```

- `image_url` — cover image. Embed as `![](url)` in the raw header.
- `source_url` — the original URL (not the `read.readwise.io` shell). Use as the canonical `**Source:**`.

If `image_url` is null, skip the image embed — don't fail the fetch.

Filename slug: `<author-last-or-source>_<short-title-slug>.md`, lowercase, hyphen-separated, no punctuation, max 60 chars.

### Step 3 — Stream the body to disk

**The critical command.** Never run `reader-get-document-details` without piping into jq and redirecting to a file:

```bash
{
  printf '# %s\n\n![](%s)\n\n**Source:** %s\n**Readwise URL:** https://read.readwise.io/read/%s\n**Readwise ID:** %s\n**Date:** %s\n**Author:** %s\n**Category:** %s\n\n---\n\n' \
    "<TITLE>" "<IMAGE_URL>" "<SOURCE_URL>" "<DOC_ID>" "<DOC_ID>" "<DATE>" "<AUTHOR>" "<CATEGORY>"
  readwise reader-get-document-details --document-id <DOC_ID> --json | jq -r '.content'
} > raw/<slug>.md
```

Drop the `![](%s)\n\n` line if `image_url` is null.

### Step 4 — Verify without reading the body

```bash
wc -l raw/<slug>.md && head -n 10 raw/<slug>.md
```

`head -n 10` shows only the header you wrote. Line count 0 means something went wrong.

### Step 5 — Report, then chain into ingest

Tell the user the filename and word count (from metadata), and that the body is on disk. Do not summarize content — you haven't read it. Then invoke `wiki-ingest` on the raw file.

## Multi-doc pattern

Resolve all doc_ids (Step 1), fetch metadata for all (Step 2), then loop:

```bash
for id in <ID1> <ID2> <ID3>; do
  slug=$(...)  # derived per-id from metadata
  {
    printf '...header...'
    readwise reader-get-document-details --document-id "$id" --json | jq -r '.content'
  } > "raw/$slug.md"
done
wc -l raw/*.md
```

Hold off on ingest until all fetches finish, then ingest the batch (parallel subagents if available — see `wiki-import-readwise` Step 4).

## JSON shapes (don't re-probe these)

- `reader-search-documents --json` → **top-level array**. Items: `document_id`, `title`, `author`, `category`, `url`, `matches[]`.
- `reader-list-documents --json` → **`{count, nextPageCursor, results: [...]}`**. Access with `jq -r '.results[0] | ...'`.
- `reader-get-document-details --json` → **flat object**: `id, title, author, category, tags, notes, content`. Body is `.content`. No `image_url`/`source_url`/`published_date`.

## CLI flag reference (don't guess)

```bash
readwise reader-get-document-details --document-id <DOC_ID> --json   # NOT --id
readwise reader-list-documents --id <DOC_ID> --json                 # NOT --document-id
readwise reader-search-documents --query "<text>" --json
readwise reader-search-documents --query "<text>" --title-search "<title>" --json
readwise readwise-search-highlights --vector-search-term "<text>" --limit 30 --json
```

## Tweet caveat

When a saved tweet is a reply, Reader stores the **parent thread** as the document. `source_url` points at the actually-saved tweet; `image_url` is the parent author's avatar. Surface this when fetching tweet replies.

## Rules

- **Never** run `reader-get-document-details` without `| jq -r '.content' > <file>`.
- **Never** re-open or `cat` a `raw/` file you just wrote unless the user asks.
- **Never** probe JSON shapes with `jq 'keys'` — they're documented above.
- Use the flag reference over `--help`; `--help` is a fine fallback.
- Prefer `--title-search` over `--query` when the user names a specific title.
- Missing metadata fields → use `null`/`unknown`; do not fetch the body to find them.
- Confirm before overwriting an existing `raw/` file.
