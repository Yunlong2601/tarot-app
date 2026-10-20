-- Creator program: anyone can post about ShenTarot with #shentarot and submit the
-- link and a screenshot. Every attempt gets credits straight away (limited per
-- day and month); a post that reaches 50 likes, once checked by the owner, earns
-- one free month of Premium. Screenshots live in R2 and are deleted after 30 days.
CREATE TABLE creator_posts (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_key       TEXT NOT NULL,
  app_user        TEXT NOT NULL,            -- RevenueCat app user id, to grant the free month
  platform        TEXT NOT NULL,
  url             TEXT NOT NULL,
  url_hash        TEXT NOT NULL UNIQUE,     -- each post counts once
  screenshot_key  TEXT,                     -- R2 object; NULL after the 30-day purge
  created_at      TEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending',   -- pending | verified | rejected
  likes           INTEGER,
  reviewed_at     TEXT,
  month_granted_at TEXT,
  note            TEXT
);
CREATE INDEX creator_posts_owner ON creator_posts (owner_key, created_at);
CREATE INDEX creator_posts_status ON creator_posts (status, created_at);
