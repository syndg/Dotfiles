---
name: wiki-ingest-song
description: >
  Ingest a song into the knowledge wiki's Music domain — research it from the web,
  fetch and analyze the lyrics, capture the craft (lyrics, production, melody), then
  write a song page, an artist page, and link it into the cross-cutting "spine" pages
  that reveal the user's taste patterns. Use when ingesting a music source: a raw clip
  carrying `clip-type: song`, a pasted YouTube/Spotify/Apple Music link to a song, or
  when the user says "ingest this song". The music counterpart to wiki-ingest.
---

# Ingest a song

Operates on a wiki hub (default `~/Knowledge`) per its `AGENTS.md` / `CLAUDE.md` schema —
read the **Music domain** section of that schema once before starting if you haven't this
session. This is the music-specific counterpart to `wiki-ingest`.

The goal is NOT a glorified playlist entry. It's a **songwriter's commonplace book**:
capture the transferable *craft* of each song the user loves, and wire it into spine pages
so patterns across their taste emerge over time. Three spines: **lyrical themes & devices**,
**production / arrangement**, **melody / topline**.

## Step 0 — Get the song

- **From a raw clip** (`clip-type: song` in frontmatter): the raw file already exists in
  `raw/`. Read its frontmatter (`title`, `source`/url, `author`) and body. **Never edit `raw/`.**
- **From a pasted link**: identify the song/artist from the URL and page metadata, then save
  an immutable capture to `raw/<song-slug>.md` (link + any metadata). This becomes the raw.

## Step 1 — Research the web

Gather what the web has. Weight effort toward the three spines:

- **Lyrics** — fetch the lyrics (e.g. the Genius page). Lyrics are the foundation of the
  lyrical spine and the only craft layer you can analyze yourself with full reliability.
- **Credits & facts** — writers, producers, featured artists, year, label, genre
  (Genius, Wikipedia, Songfacts). Producer credits feed the production spine.
- **Production & aesthetic** — interviews (artist explaining the song), reviews, theory
  breakdowns. This is where "why it works" comes from.
- **Relationships** — samples, interpolations, "cover of", "remix of". These become real
  graph edges between song pages.

Append the research to the raw capture only if you created the raw this run; if the raw came
from a clip, keep your findings in the new wiki pages instead (raw stays immutable).

## Step 2 — Auto-analyze the lyrics yourself

You don't need anyone else's analysis for this. From the lyrics, extract: subject/theme,
point-of-view, narrative structure, imagery, rhyme scheme, notable devices (wordplay,
repetition, volta/turn). This is the most reliable craft output — do it directly.

## Step 3 — Ask the user to fill the gaps (hybrid)

The web is weakest on **melody** and often thin on **production**. Ask the user **1–3
targeted questions** for only the gaps you couldn't fill — weighted to melody/production.
Examples: *"Where's the melodic hook, and what makes it stick?"*, *"What's the standout
production move?"*. Don't quiz them on what you already found.

**Batch escape hatch:** when ingesting many songs at once (e.g. a catch-up backlog), do all
the auto-research first, then either ask gap questions song-by-song, OR — if the user says
"just do what you can" — ingest in hands-off mode (skip the questions, write what the web +
lyric analysis gave you, and flag the melody/production gaps as open threads to enrich later).

## Step 4 — Write the pages

1. **Song page** → `wiki/sources/<song-slug>.md`. Frontmatter: `type: song`, `artist`,
   `year`, `genre`, `url`, `raw`. Body: a short "why it works" TL;DR, then sections for the
   three spines + song structure. Cite specifics; don't invent. Keep it a short blog post,
   not a data dump (per the schema's writing style).
2. **Artist page** → `wiki/<artist-slug>.md` (create if new, update if exists). Who they
   are, their signature, and a list of every song of theirs filed so far.
3. **Spine pages** → `wiki/<technique-slug>.md`. For each notable technique in the song,
   create the spine page if it doesn't exist (e.g. `second-person-confessional`,
   `half-time-pre-chorus`, `octave-leap-payoff`) or add this song to it if it does. These
   are the generative core — they accumulate songs and reveal patterns. Create them
   on-demand; do not pre-seed.

## Step 5 — Cross-link (the #1 rule)

- **Link IN** — the artist page and every relevant spine page link to the new song.
- **Link OUT** — the song page links to its artist, its spine pages, and any related song
  (samples/interpolations/same producer/same technique).
- No orphans. A song page with no spine links is a failure — find at least one technique
  worth a spine, even if the spine is new.
- Cross-domain links are welcome (a song's theme might touch a concept elsewhere in the wiki).

## Step 6 — Update index, home, log

- **`wiki/index.md`** — add the song (and any new artist/spine pages) under a **Music**
  category, with one-line summaries.
- **`wiki/home.md`** — if this opens the Music domain or shifts the narrative, revise it.
- **`wiki/log.md`** — prepend `## [YYYY-MM-DD HH:MM] ingest | <song> — <artist>`.

## Step 7 — Report

List the song/artist/spine pages created or updated, the cross-links added, and any
melody/production gaps left as open threads. Note any emerging pattern you spotted across
spine pages (e.g. "third song now on `half-time-pre-chorus`") — that's the payoff.

## Notes

- **Never modify `raw/`.** Read-only.
- Don't invent musical facts. If you can't confirm a chord/producer/structure, say so or ask
  — flag gaps as open threads rather than guessing.
- The spines are fixed (lyrical / production / melody); the spine *pages* within them grow
  organically. If a technique doesn't fit a spine, put it as prose on the song page.
- Tool-agnostic: use whatever web-fetch, file, and shell tools your agent provides. Where
  this mentions parallel subagents (for batches), that's an optimization — inline is fine.
