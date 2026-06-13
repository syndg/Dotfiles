# Query Patterns

## Top channels

```sql
SELECT channel, watch_count, first_watched_at, last_watched_at
FROM top_channels
ORDER BY watch_count DESC
LIMIT 20;
```

## Recent activity window

```sql
SELECT DATE(watched_at) AS day, COUNT(*) AS watches
FROM watch_events
WHERE watched_at >= datetime('now', '-30 days')
GROUP BY DATE(watched_at)
ORDER BY day;
```

## Repeated searches

```sql
SELECT query, COUNT(*) AS count
FROM search_events
WHERE query IS NOT NULL AND query <> ''
GROUP BY query
ORDER BY count DESC
LIMIT 20;
```

## Channel streak in recent period

```sql
SELECT COALESCE(c.channel_name, w.channel_url, 'Unknown') AS channel, COUNT(*) AS watches
FROM watch_events w
LEFT JOIN channels c ON c.channel_url = w.channel_url
WHERE w.watched_at >= datetime('now', '-14 days')
GROUP BY COALESCE(c.channel_name, w.channel_url, 'Unknown')
ORDER BY watches DESC
LIMIT 20;
```

## Non-video activity rows

```sql
SELECT watched_at, title, header
FROM watch_events
WHERE video_id IS NULL
ORDER BY watched_at DESC
LIMIT 50;
```
