-- Links each purchased lot to its store transaction, so a refunded credit pack
-- can take back the credits that are still unused.
ALTER TABLE credit_lots ADD COLUMN txn TEXT;
CREATE INDEX credit_lots_txn ON credit_lots (txn);
