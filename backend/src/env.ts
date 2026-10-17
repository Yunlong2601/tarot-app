export interface Env {
  DB: D1Database;
  KV: KVNamespace;
  JWT_SECRET: string;
  HASH_SALT: string;
  ANTHROPIC_API_KEY?: string;
  /** Optional second provider (fallback, or primary with LLM_PROVIDER=openai). */
  OPENAI_API_KEY?: string;
  OPENAI_MODEL?: string;
  /** "anthropic" (default) or "openai". */
  LLM_PROVIDER?: string;
  REVENUECAT_SECRET_KEY?: string;
  LLM_MODEL?: string;
  GLOBAL_DAILY_TOKEN_CAP?: string;
  /** Comma-separated OAuth client ids accepted as the ID-token audience. Unset = accounts off. */
  GOOGLE_CLIENT_IDS?: string;
  /** Apple bundle id and/or Services ID, comma-separated. */
  APPLE_CLIENT_IDS?: string;
  /** "true" turns on reading credits (credit packs). */
  CREDITS_ENABLED?: string;
  /** "true" turns on refer-and-earn (needs store offers set up first). */
  REFERRALS_ENABLED?: string;
  /** "true" turns on the creator program (needs CREDITS_ENABLED and an R2 bucket bound as SHOTS). */
  CREATOR_ENABLED?: string;
  /** Secret for the owner-only admin endpoints (at least 24 characters). */
  ADMIN_TOKEN?: string;
  /** R2 bucket for creator screenshots (deleted after 30 days). */
  SHOTS?: R2Bucket;
  /** Shared secret RevenueCat sends in the webhook Authorization header. */
  REVENUECAT_WEBHOOK_AUTH?: string;
  /** Testing only: comma-separated install/account ids treated as Premium. */
  TESTER_INSTALL_IDS?: string;
  /** Local testing only: skips device attestation. Never set in production. */
  ALLOW_UNATTESTED_INSTALLS?: string;
}
