-- Refer and earn. "Keys" are the account id (acct:<id>) when signed in, else
-- the salted install hash. No names, emails or contacts.
CREATE TABLE referral_codes (
  code        TEXT PRIMARY KEY,           -- 8 characters, shown to the user
  owner_key   TEXT NOT NULL UNIQUE,
  owner_app_user TEXT NOT NULL,           -- RevenueCat app user id, to grant free months
  created_at  TEXT NOT NULL
);
CREATE TABLE referrals (
  friend_key   TEXT PRIMARY KEY,          -- one referral per friend, ever
  referrer_key TEXT NOT NULL,
  code         TEXT NOT NULL,
  platform     TEXT NOT NULL,             -- 'ios' | 'android'
  redeemed_at  TEXT NOT NULL,
  paid_txn     TEXT UNIQUE,               -- store transaction that qualified it
  paid_at      TEXT,
  credited_at  TEXT                       -- when the referrer got the free month
);
CREATE INDEX referrals_referrer ON referrals (referrer_key);
-- One-time App Store offer codes (50% off the first year), imported in batches.
CREATE TABLE apple_offer_codes (
  code         TEXT PRIMARY KEY,
  assigned_to  TEXT,
  assigned_at  TEXT
);
