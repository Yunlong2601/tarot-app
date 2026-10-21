-- Reading credits (Starter Pack). Balance per account or install key; each
-- store purchase is recorded once so a webhook retry never adds twice.
CREATE TABLE credits (
  owner_key   TEXT PRIMARY KEY,
  balance     INTEGER NOT NULL DEFAULT 0,
  updated_at  TEXT NOT NULL
);
CREATE TABLE credit_grants (
  txn         TEXT PRIMARY KEY,
  owner_key   TEXT NOT NULL,
  amount      INTEGER NOT NULL,
  created_at  TEXT NOT NULL
);
