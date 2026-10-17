-- Referral credits: both sides get credits when the friend finishes a first reading.
ALTER TABLE referrals ADD COLUMN reading_credited_at TEXT;   -- when the friend's first reading paid out
ALTER TABLE referrals ADD COLUMN referrer_rewarded INTEGER NOT NULL DEFAULT 0;  -- 1 = referrer got credits (yearly cap not hit)
