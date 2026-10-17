-- Credit wallet. Credits are stored as lots (never expire); the old
-- credits.balance column is no longer used. last_login_day / last_month record
-- the last UTC day / month in which the daily / monthly credits were granted.
ALTER TABLE credits ADD COLUMN last_login_day TEXT;
ALTER TABLE credits ADD COLUMN last_month TEXT;
CREATE TABLE credit_lots (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_key  TEXT NOT NULL,
  remaining  INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  source     TEXT NOT NULL
);
CREATE INDEX credit_lots_owner ON credit_lots (owner_key, id);
