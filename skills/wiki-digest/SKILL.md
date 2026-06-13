---
name: wiki-digest
description: Deep-propagate already-ingested sources across the knowledge wiki — ripple claims into concept/entity/question pages, flag contradictions, create new pages where warranted. Optional deeper pass after wiki-ingest. Use when the user says "digest" or "propagate" a source across the wiki.
---

# Digest source

Operates on a wiki hub (default `~/Knowledge`) per its `AGENTS.md` / `CLAUDE.md` schema.

Goal: take one or more raw files that already have a wiki summary page (created by `wiki-ingest`) and produce the full ripple effect — surgical propagation into existing pages + new pages where genuinely warranted + index/log updates. This turns an ingested source into *integrated* knowledge across the wiki.

## When to use

- After `wiki-ingest`, as an optional deeper pass.
- When the user says "digest" / "propagate" a source across the wiki.
- When source-summary pages exist whose claims haven't been woven into concept/entity pages yet.

## Preconditions

- At least one source-summary page in `wiki/sources/` whose claims haven't been fully propagated.
- You've read the wiki schema (`AGENTS.md` / `CLAUDE.md`) and `wiki/home.md` at least once this session.

## Architecture

If your agent supports parallel subagents, delegate the heavy lifting so the main thread doesn't hold multiple source bodies at once:

1. Identify which sources need digesting.
2. Read the schema, `wiki/home.md`, and `wiki/index.md` to understand the current state.
3. Dispatch a subagent with the tight brief below (one subagent for all sources, not one per source — cross-references stay coherent).
4. Relay the subagent's report concisely.

If your agent does **not** support subagents, do the same work inline — read the schema, identify sources, make the edits yourself following the brief.

## Step 1 — Identify sources to digest

If the user didn't name files, find source-summary pages whose claims don't yet appear in concept/entity pages:

```bash
grep -l "^type:" wiki/sources/*.md
```

Confirm with the user if there's ambiguity.

## Step 2 — Load the wiki's current state

Read (and pass to the subagent, if using one):

- `AGENTS.md` (or `CLAUDE.md`) — schema, conventions.
- `wiki/home.md` — current through-line and live tensions.
- `wiki/index.md` — full catalog of existing pages.

## Step 3 — Digest brief (for a subagent, or follow inline)

> **Job:** Digest source(s) into the wiki. Follow the wiki schema exactly.
>
> **Sources to digest:** `<list of wiki source-summary pages>`
>
> **Current state:** `wiki/home.md` is the human narrative; `wiki/index.md` is the catalog. Read `home.md` first, then `index.md`.
>
> **For each source, do the full ripple:**
>
> 1. **Read the source summary and its raw.** Once, carefully.
> 2. **Propagate and cross-link.** Surgical edits (not rewrites) to existing pages the source materially informs:
>    - Add to existing sections where the material belongs; don't create duplicate sections.
>    - Cite the source: `([[<slug>]])`.
>    - If it contradicts an existing claim, add a `> [!contradiction]` callout inline.
>    - If a claim has a canonical home elsewhere, link rather than duplicate.
>    - **Bidirectional links:** when you make page A reference new concept B, also edit B to link back to A.
>    - **No orphans:** after propagation, every source-summary and concept page has ≥2 inbound `[[wikilinks]]`.
> 3. **Create new pages** *only* when genuinely warranted — a new entity, concept, open question, or position. Lean conservative.
> 4. **Update `wiki/index.md`** to list every new page under the right category.
> 5. **Prepend one log entry per source** to `wiki/log.md`: `## [YYYY-MM-DD HH:MM] digest | <title>`.
>
> **Rules:** Never modify `raw/`. Keep `wiki/` flat (only `wiki/sources/`). Don't invent facts. Don't touch schema files or `home.md` unless a schema change is forced (flag it, don't just do it). No wholesale rewrites — surgical only. One canonical home per claim; others link.
>
> **Deliverable (under 300 words):** new pages created; existing pages updated; contradictions flagged; judgment calls worth review; new open questions.

## Step 4 — Relay the report

Summarize concisely (under 200 words): judgment calls, contradictions, new open questions. Then ask the user if anything needs adjustment.

## Rules

- **Never** skip Step 2 — that context is required.
- **Never** run this on a source without an existing summary page — run `wiki-ingest` first.
- If using subagents: don't pre-read raws in the main thread; prefer one subagent for all sources.
