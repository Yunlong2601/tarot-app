import type { Spread } from "./validate";

/** Per-install daily usage and the global token budget. D1 in production,
 * in-memory in tests. */
export interface UsageStore {
  /** Readings counted for this install today (including in-flight ones). */
  countReadings(installHash: string, day: string): Promise<number>;
  /** Total tokens used by everyone today. */
  tokensToday(day: string): Promise<number>;
  /** Reserve a slot before calling the model; returns a row id. */
  reserve(installHash: string, day: string, spread: Spread, model: string): Promise<number>;
  finalize(id: number, inputTokens: number, outputTokens: number): Promise<void>;
  /** Give the slot back when the model call failed. */
  release(id: number): Promise<void>;
}

export class D1UsageStore implements UsageStore {
  constructor(private db: D1Database) {}

  async countReadings(installHash: string, day: string): Promise<number> {
    const r = await this.db
      .prepare("SELECT COUNT(*) AS n FROM usage WHERE install_hash = ?1 AND day = ?2 AND kind = 'reading'")
      .bind(installHash, day).first<{ n: number }>();
    return r?.n ?? 0;
  }

  async tokensToday(day: string): Promise<number> {
    const r = await this.db
      .prepare("SELECT COALESCE(SUM(input_tokens + output_tokens), 0) AS n FROM usage WHERE day = ?1")
      .bind(day).first<{ n: number }>();
    return r?.n ?? 0;
  }

  async reserve(installHash: string, day: string, spread: Spread, model: string): Promise<number> {
    const r = await this.db
      .prepare("INSERT INTO usage (install_hash, day, kind, spread, model, created_at) VALUES (?1, ?2, 'reading', ?3, ?4, ?5)")
      .bind(installHash, day, spread, model, new Date().toISOString()).run();
    return r.meta.last_row_id;
  }

  async finalize(id: number, inputTokens: number, outputTokens: number): Promise<void> {
    await this.db.prepare("UPDATE usage SET input_tokens = ?2, output_tokens = ?3 WHERE id = ?1")
      .bind(id, inputTokens, outputTokens).run();
  }

  async release(id: number): Promise<void> {
    await this.db.prepare("DELETE FROM usage WHERE id = ?1").bind(id).run();
  }
}

export const FREE_READINGS_PER_DAY = 1;
export const PREMIUM_READINGS_PER_DAY = 20;
export const BURST_PER_MINUTE = 10;
export const IP_PER_MINUTE = 30;
export const DEFAULT_GLOBAL_DAILY_TOKEN_CAP = 2_000_000;

/** Fixed-window counter in KV (not atomic; good enough as a burst brake. The
 * daily caps use D1). Returns true if the request is allowed. */
export async function allowWithinMinute(
  kv: KVNamespace, key: string, limit: number, nowMs: number,
): Promise<boolean> {
  const bucket = `${key}:${Math.floor(nowMs / 60_000)}`;
  const n = Number((await kv.get(bucket)) ?? "0");
  if (n >= limit) return false;
  await kv.put(bucket, String(n + 1), { expirationTtl: 120 });
  return true;
}

export function utcDay(nowMs: number): string {
  return new Date(nowMs).toISOString().slice(0, 10);
}
