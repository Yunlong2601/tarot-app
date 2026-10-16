export interface Env {
  DB: D1Database;
  KV: KVNamespace;
  JWT_SECRET: string;
  HASH_SALT: string;
  ANTHROPIC_API_KEY: string;
  REVENUECAT_SECRET_KEY?: string;
  LLM_MODEL?: string;
  GLOBAL_DAILY_TOKEN_CAP?: string;
  /** Local testing only: skips device attestation. Never set in production. */
  ALLOW_UNATTESTED_INSTALLS?: string;
}
