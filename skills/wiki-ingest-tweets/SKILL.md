---
name: wiki-ingest-tweets
description: Search X/Twitter for tweets on a topic via browser automation, extract the interesting ones, and ingest the discourse into the knowledge wiki as a source. Use when the user says "ingest tweets", "what's X saying about <topic>", or wants Twitter discourse filed into the wiki.
---

# Ingest tweets on a topic

Operates on a wiki hub (default `~/Knowledge`) per its `AGENTS.md` / `CLAUDE.md` schema. Use browser automation to search X/Twitter for a topic, extract the good tweets, and run them through `wiki-ingest`.

## Prerequisites

You need a way to drive a real browser (X requires login and is JS-heavy). Use whichever your agent has:

- The **`agent-browser`** or **`playwright-cli`** skill (preferred — already available here).
- A browser-automation MCP server (e.g. a Playwright or Chrome DevTools MCP).

If none is available, tell the user they need a browser automation tool connected, and stop. The user must be logged into X in that browser.

## Step 1 — Open X search

Navigate to:

```
https://x.com/search?q=<url-encoded-query>&src=typed_query&f=top
```

Use `f=top` (Top) by default; use `f=live` if the user wants recency. Wait for the feed to render.

## Step 2 — Read and scroll the feed

For each tweet capture: **author** (display name + @handle), **date**, **full text** (expand "Show more"), **engagement** (likes/retweets/replies, rough is fine), **URL** (`https://x.com/<handle>/status/<id>`).

Scroll 2–3 times. Aim for **10–20 tweets** unless the user said otherwise. If you hit a login wall or CAPTCHA, stop and tell the user.

## Step 3 — Curate

Present the collected tweets as a numbered list (author, date, one-line summary). Ask which to ingest, or confirm "all".

## Step 4 — Save to raw/

Write a single raw file at `raw/tweets_<topic-slug>_<YYYY-MM-DD>.md`:

```markdown
# Tweets: <Topic>

**Collected:** YYYY-MM-DD HH:MM
**Query:** <the search query used>
**Source:** https://x.com/search?q=<query>

---

## @handle — YYYY-MM-DD

> Full tweet text, preserving line breaks.

Likes: N · Retweets: N · Replies: N
Source: https://x.com/handle/status/id

---

## @handle2 — YYYY-MM-DD

> Next tweet...
```

## Step 5 — Ingest

Invoke `wiki-ingest` on the raw file. The source-summary page should:

- Use `type: tweets` in frontmatter.
- Summarize the overall discourse — what people are saying, where they agree/disagree, dominant vs. contrarian takes.
- Attribute specific claims to specific authors with tweet URLs.

## Tips

- **Threads:** if a tweet is part of a reply chain from the same author, click in and grab the full thread; note it as a thread.
- **Quote tweets:** include the quoted tweet inline, indented, to preserve context.
- **Media:** note `[image]`, `[video]`, or `[link preview: <url>]` inline — don't download media.
- **Broad topics:** offer to run multiple queries (topic name, key people, related hashtags).

## Rules

- **Never** fabricate tweets. Only include content actually visible on the page.
- **Never** re-open a `raw/` file you just wrote unless the user asks.
- **Stop and ask** if fewer than 3 tweets are found — the query may need adjusting.
- **Respect the user's curation** in Step 3 — don't silently drop or add tweets.
