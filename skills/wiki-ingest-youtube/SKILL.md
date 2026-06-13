---
name: wiki-ingest-youtube
description: >
  Capture a YouTube video's transcript into the knowledge wiki and ingest it as a source.
  Auto-trigger on YouTube URLs (youtube.com, youtu.be) when the user wants a video
  summarized, transcribed, filed, or added to the wiki. Also trigger on: "summarize this
  video", "get transcript", "transcribe this", "what does this video say", "what's this
  video about", "ingest this video". Manually invokable via /wiki-ingest-youtube.
  The transcript is written to the wiki's raw/ layer; summarizing, cross-linking, and
  indexing are handled by chaining into wiki-ingest.
---

# Ingest a YouTube video

Capture a video's transcript into a wiki hub (default `~/Knowledge`, laid out per its
`AGENTS.md` / `CLAUDE.md` schema), then file it like any other source. A YouTube video
behaves exactly like a Readwise doc or a tweet thread: the **transcript is a raw source**
(`raw/`), and the **summary is synthesis** (`wiki/sources/`), created by `wiki-ingest`.

## Prerequisites

- `yt-dlp` installed (`brew install yt-dlp`).
- Chrome browser — cookies are read automatically via `--cookies-from-browser chrome`
  (needed for age-restricted / members / region-locked videos).

## Step 1 — Capture the transcript into raw/

Run the capture script. It downloads + cleans the transcript, writes it to `raw/<slug>.md`
with frontmatter (`type: youtube`, title, channel, date, duration, url), and prints
**metadata only** (path, title, duration, word count) — not the transcript body.

```bash
python3 ~/.agents/skills/wiki-ingest-youtube/scripts/extract_transcript.py "<URL>"
```

Options:
- `--no-timestamps` — omit `[MM:SS]` timestamps from the saved transcript.
- `--raw-dir <path>` — target a different wiki's `raw/` (default `~/Knowledge/raw`).

Do **not** echo or re-read the full transcript into the conversation — it's on disk now,
and the ingest step reads it from there. Report the title and word count to the user.

## Step 2 — Ingest it into the wiki

Invoke the **`wiki-ingest`** skill on the new `raw/<slug>.md`. That skill owns everything
downstream and keeps YouTube consistent with every other source:

- Creates the source-summary page at `wiki/sources/<slug>.md` (use `type: youtube` in its
  frontmatter; carry over title, channel, url, date).
- Propagates claims into concept/entity pages, cited with `([[slug]])`.
- Cross-links aggressively (no orphans), updates `wiki/index.md`, appends to `wiki/log.md`,
  and revises `wiki/home.md` if the video shifts the narrative.

When summarizing, prefer **timestamped references as clickable links**:
`[MM:SS](<url>&t=<seconds>)` — the saved transcript carries the timestamps to build them.

## Escape hatch — just summarize, don't file

If the user only wants a quick read and explicitly says not to file it (e.g. "just
summarize this, don't add it to the wiki"), still run Step 1 to get the transcript onto
disk, then read `raw/<slug>.md` and summarize in chat **without** running `wiki-ingest`.
Default behavior is to file it — exploration should compound in the wiki, not vanish into
chat history.

## Notes

- Tool-agnostic: use whatever shell/file tools your agent provides. No assumptions about
  a specific agent.
- The transcript in `raw/` is immutable — never edit it after capture. All synthesis lives
  in `wiki/`.
