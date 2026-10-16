-- One row per reading request. No questions or readings are stored.
CREATE TABLE usage (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  install_hash  TEXT    NOT NULL,
  day           TEXT    NOT NULL,           -- UTC date, YYYY-MM-DD
  kind          TEXT    NOT NULL,           -- 'reading'
  spread        TEXT    NOT NULL,
  model         TEXT    NOT NULL,
  input_tokens  INTEGER NOT NULL DEFAULT 0,
  output_tokens INTEGER NOT NULL DEFAULT 0,
  created_at    TEXT    NOT NULL
);
CREATE INDEX usage_install_day ON usage (install_hash, day);
CREATE INDEX usage_day ON usage (day);
