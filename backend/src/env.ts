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
  /** Secret for the owner's release quality test: skips the install limit and
   * the daily reading charge for requests that send it as x-qa-token. */
  QA_TOKEN?: string;
  /** Optional webhook (Discord/Slack/ntfy) for owner alerts such as the 80% token-cap warning. */
  ALERT_WEBHOOK_URL?: string;
  /** Skips device attestation. Beta, and the v1 launch until App Attest / Play Integrity ship (with the per-IP new-install limit). Never together with TESTER_INSTALL_IDS. */
  ALLOW_UNATTESTED_INSTALLS?: string;
  /** App Attest app id: "<Team ID>.<bundle id>". Set = iOS device proof is checked. */
  APPLE_APP_ID?: string;
  /** "true" also accepts development-environment App Attest keys (Xcode debug builds). Never in production. */
  APP_ATTEST_ALLOW_DEVELOPMENT?: string;
  /** Sign in with Apple key, for revoking Apple tokens when an account is deleted. */
  APPLE_TEAM_ID?: string;
  APPLE_SIWA_KEY_ID?: string;
  /** Secret: the .p8 key's PEM text. */
  APPLE_SIWA_PRIVATE_KEY?: string;
}
