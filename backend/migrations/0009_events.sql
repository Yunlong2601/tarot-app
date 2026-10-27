-- Anonymous product events (funnel steps) for measuring app changes. Keyed by
-- the hashed install id; no question text or personal data. Kept 180 days.
CREATE TABLE events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  install_hash TEXT NOT NULL,
  variant TEXT NOT NULL,
  name TEXT NOT NULL,
  props TEXT NOT NULL,
  at INTEGER NOT NULL,
  day TEXT NOT NULL
);
CREATE INDEX events_day_name ON events (day, name);
CREATE INDEX events_install ON events (install_hash);
