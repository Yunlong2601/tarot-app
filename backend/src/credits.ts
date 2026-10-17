/** Reading credits (off unless CREDITS_ENABLED=true). 1 credit = one extra AI
 * reading or follow-up / clarifier beyond the daily allowance. Credits never expire. A credit is refunded if the reading fails. */

/** Daily credits: the first time a user opens the app on a UTC day they
 * receive their plan's daily amount (free 2, Premium monthly 30, 3 months 40,
 * annual 50, see usage.ts). Unused credits roll over and never expire. New
 * daily credits stop arriving while the user already holds DAILY_BANK_DAYS
 * days' worth of them (bought credits do not count toward that cap), and a user
 * can spend at most DAILY_SPEND_DAYS days' worth in one day. */
export const DAILY_BANK_DAYS = 10;
export const DAILY_SPEND_DAYS = 2;

export interface CreditStore {
  /** Today's daily credits: adds up to `amount` (once per UTC day per owner),
   * never taking the daily-sourced credits held above `bankCap`. Returns how many were added. */
  claimDaily(key: string, day: string, amount: number, bankCap: number): Promise<number>;
  balance(key: string): Promise<number>;
  /** Adds credits for a store purchase; false if this transaction was seen. */
  add(key: string, amount: number, txn: string): Promise<boolean>;
  /** Moves every credit from one owner to another (a Premium user restoring on a new install). */
  move(fromKey: string, toKey: string): Promise<number>;
  /** Takes one credit if there is one; returns the lot it came from. */
  spend(key: string): Promise<number | null>;
  /** Gives a spent credit back to the lot it came from. */
  refund(lotId: number): Promise<void>;
}

/** Credits in a consumable product id, e.g. "shentarot_credits_5" -> 5. */
export function creditsInProduct(productId: string): number | null {
  const m = /credits_(\d{1,3})(?::|$)/.exec(productId);
  return m ? Number(m[1]) : null;
}

/** Each grant (purchase, daily credits) is a lot. Credits never expire; the
 * oldest lot is spent first and a refund goes back to the lot it came from. */
export class D1CreditStore implements CreditStore {
  constructor(private db: D1Database, private nowMs: () => number = () => Date.now()) {}
  private iso() { return new Date(this.nowMs()).toISOString(); }
  private async lot(key: string, amount: number, source: string) {
    await this.db.prepare("INSERT INTO credit_lots (owner_key, remaining, created_at, source) VALUES (?1, ?2, ?3, ?4)")
      .bind(key, amount, this.iso(), source).run();
  }
  async balance(key: string) {
    const r = await this.db.prepare("SELECT COALESCE(SUM(remaining), 0) AS n FROM credit_lots WHERE owner_key = ?1")
      .bind(key).first<{ n: number }>();
    return r?.n ?? 0;
  }
  async add(key: string, amount: number, txn: string) {
    const ins = await this.db.prepare("INSERT OR IGNORE INTO credit_grants (txn, owner_key, amount, created_at) VALUES (?1, ?2, ?3, ?4)")
      .bind(txn, key, amount, this.iso()).run();
    if ((ins.meta.changes ?? 0) === 0) return false;
    await this.lot(key, amount, "purchase");
    return true;
  }
  async claimDaily(key: string, day: string, amount: number, bankCap: number) {
    const held = await this.db.prepare("SELECT COALESCE(SUM(remaining), 0) AS n FROM credit_lots WHERE owner_key = ?1 AND source = 'daily'")
      .bind(key).first<{ n: number }>();
    const grant = Math.min(amount, bankCap - (held?.n ?? 0));
    if (grant <= 0) return 0;
    await this.db.prepare("INSERT OR IGNORE INTO credits (owner_key, balance, updated_at) VALUES (?1, 0, ?2)").bind(key, this.iso()).run();
    const r = await this.db.prepare(
      "UPDATE credits SET last_login_day = ?2, updated_at = ?3 WHERE owner_key = ?1 AND (last_login_day IS NULL OR last_login_day <> ?2)",
    ).bind(key, day, this.iso()).run();
    if ((r.meta.changes ?? 0) === 0) return 0;
    await this.lot(key, grant, "daily");
    return grant;
  }
  async move(fromKey: string, toKey: string) {
    if (fromKey === toKey) return 0;
    const held = await this.balance(fromKey);
    await this.db.prepare("UPDATE credit_lots SET owner_key = ?2 WHERE owner_key = ?1").bind(fromKey, toKey).run();
    return held;
  }
  async spend(key: string) {
    for (let attempt = 0; attempt < 3; attempt++) {
      const lot = await this.db.prepare(
        "SELECT id FROM credit_lots WHERE owner_key = ?1 AND remaining > 0 ORDER BY id LIMIT 1",
      ).bind(key).first<{ id: number }>();
      if (!lot) return null;
      const r = await this.db.prepare("UPDATE credit_lots SET remaining = remaining - 1 WHERE id = ?1 AND remaining > 0").bind(lot.id).run();
      if ((r.meta.changes ?? 0) > 0) return lot.id;
    }
    return null;
  }
  async refund(lotId: number) {
    await this.db.prepare("UPDATE credit_lots SET remaining = remaining + 1 WHERE id = ?1").bind(lotId).run();
  }
}
