-- Daily login credit plus one-year expiry. Credits are now lots with their own
-- expiry; the old credits.balance column is no longer used.
ALTER TABLE credits ADD COLUMN last_login_day TEXT;
CREATE TABLE credit_lots (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_key  TEXT NOT NULL,
  remaining  INTEGER NOT NULL,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL,
  source     TEXT NOT NULL
);
CREATE INDEX credit_lots_owner ON credit_lots (owner_key, expires_at);
