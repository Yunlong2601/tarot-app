-- Optional accounts (Sign in with Google / Apple). No email or name is stored:
-- only a salted hash of the provider's user id.
CREATE TABLE accounts (
  id            TEXT PRIMARY KEY,           -- random UUID, also the RevenueCat app user id
  provider      TEXT NOT NULL,              -- 'google' | 'apple'
  subject_hash  TEXT NOT NULL UNIQUE,       -- salted SHA-256 of provider + provider user id
  created_at    TEXT NOT NULL
);
-- Which installs are signed in to which account (a phone can be signed in to one).
CREATE TABLE account_installs (
  install_hash  TEXT PRIMARY KEY,
  account_id    TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  linked_at     TEXT NOT NULL
);
CREATE INDEX account_installs_account ON account_installs (account_id);
