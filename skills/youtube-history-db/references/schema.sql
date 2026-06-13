CREATE TABLE channels (
    channel_url TEXT PRIMARY KEY,
    channel_name TEXT
  );
CREATE TABLE videos (
    video_id TEXT PRIMARY KEY,
    title TEXT,
    title_url TEXT NOT NULL,
    channel_url TEXT,
    FOREIGN KEY (channel_url) REFERENCES channels(channel_url)
  );
CREATE TABLE watch_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    watched_at TEXT NOT NULL,
    title TEXT,
    title_url TEXT,
    video_id TEXT,
    channel_url TEXT,
    header TEXT,
    products_json TEXT,
    activity_controls_json TEXT,
    FOREIGN KEY (video_id) REFERENCES videos(video_id),
    FOREIGN KEY (channel_url) REFERENCES channels(channel_url),
    UNIQUE (watched_at, title_url, title)
  );
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE search_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    searched_at TEXT NOT NULL,
    query TEXT,
    query_url TEXT,
    header TEXT,
    products_json TEXT,
    activity_controls_json TEXT,
    UNIQUE (searched_at, query, query_url)
  );
CREATE INDEX idx_watch_events_watched_at ON watch_events(watched_at);
CREATE INDEX idx_watch_events_video_id ON watch_events(video_id);
CREATE INDEX idx_watch_events_channel_url ON watch_events(channel_url);
CREATE UNIQUE INDEX idx_watch_events_dedupe
    ON watch_events(watched_at, COALESCE(title_url, ''), COALESCE(title, ''));
CREATE INDEX idx_search_events_searched_at ON search_events(searched_at);
CREATE UNIQUE INDEX idx_search_events_dedupe
    ON search_events(searched_at, COALESCE(query, ''), COALESCE(query_url, ''));
CREATE VIEW top_channels AS
  SELECT
    COALESCE(c.channel_name, w.channel_url, "Unknown") AS channel,
    COUNT(*) AS watch_count,
    MIN(w.watched_at) AS first_watched_at,
    MAX(w.watched_at) AS last_watched_at
  FROM watch_events w
  LEFT JOIN channels c ON c.channel_url = w.channel_url
  GROUP BY COALESCE(c.channel_name, w.channel_url, "Unknown");
CREATE VIEW daily_activity AS
  SELECT
    DATE(watched_at) AS day,
    COUNT(*) AS watches,
    COUNT(DISTINCT video_id) AS distinct_videos,
    COUNT(DISTINCT channel_url) AS distinct_channels
  FROM watch_events
  GROUP BY DATE(watched_at);
