---
name: youtube-history-db
description: Query and analyze the local YouTube history SQLite database at `/Volumes/External/Coding/youtube-history/youtube-history.db`. Use when the user wants to search watch history, inspect search history, find channels or patterns, compare time periods, explain viewing behavior, or generate evidence-backed insights from their YouTube history export.
---

# YouTube History DB

## Overview

Use the local SQLite database directly. Prefer read-only SQL over guesses. Answer with evidence from query results, and call out ambiguity when the export lacks duration, topic labels, or full metadata.

## Workflow

1. Inspect `references/schema.sql` if table or view names are unclear.
2. Run `scripts/query_youtube_history.sh` with focused SQL.
3. Start with a narrow query to confirm data shape.
4. Expand into aggregates, comparisons, or time windows.
5. Summarize findings in plain language and cite the exact query basis.

## Query Rules

- Use `scripts/query_youtube_history.sh` instead of repeating the database path.
- Treat the database as read-only. Never run mutating SQL unless the user explicitly asks for DB changes.
- Use `top_channels` and `daily_activity` first for common questions.
- Filter out non-video watch rows when needed with `video_id IS NOT NULL`.
- Expect some watch or search rows to have `NULL` URLs because Takeout includes deleted posts or non-video activity.
- When comparing periods, use the ISO timestamps already stored in the DB.

## Common Questions

- Top channels: query `top_channels` ordered by `watch_count`.
- Daily or weekly activity: aggregate `watch_events` or use `daily_activity`.
- Repeated searches: group `search_events` by `query`.
- Trend windows: compare recent 7, 30, or 90 day slices with timestamp filters.
- Search-to-watch correlation: join nearby `search_events` and `watch_events` by time window, and present results as heuristic rather than fact.

## Example Queries

Top channels:

```sql
SELECT channel, watch_count
FROM top_channels
ORDER BY watch_count DESC
LIMIT 10;
```

Most common searches:

```sql
SELECT query, COUNT(*) AS count
FROM search_events
WHERE query IS NOT NULL AND query <> ''
GROUP BY query
ORDER BY count DESC
LIMIT 20;
```

Recent watch activity:

```sql
SELECT DATE(watched_at) AS day, COUNT(*) AS watches
FROM watch_events
GROUP BY DATE(watched_at)
ORDER BY day DESC
LIMIT 14;
```

## Limits

- The export does not include reliable watch duration here, so do not claim watch time.
- Topic inference requires title or channel heuristics unless more enrichment is added later.
- Search intent and watch intent can be related, but direct causality is not guaranteed.

## Resources

- `scripts/query_youtube_history.sh`: read-only SQLite wrapper against the canonical DB path.
- `references/schema.sql`: current database schema and built-in views.
- `references/query-patterns.md`: reusable SQL patterns for common questions.
