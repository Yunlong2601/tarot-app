/** Reading credits (off unless CREDITS_ENABLED=true). 1 credit = one extra AI
 * reading or follow-up / clarifier beyond the daily allowance. Credits never expire. A credit is refunded if the reading fails. */

/** Credit wallet. Everyone receives FREE_DAILY_CREDITS the first time they use
 * the app on a UTC day; Premium also receives their plan's monthly credits the
 * first time they use it in a UTC calendar month (usage.ts). Unused credits
 * roll over and never expire. Daily credits stop arriving while 10 days' worth
 * are held, monthly credits while 2 months' worth are held; bought, referral
 * and creator credits are outside both caps. */
export const DAILY_BANK_DAYS = 10;
export const MONTHLY_BANK_MONTHS = 2;
/** A one-time gift on the first day (outside the caps). */
export const WELCOME_CREDITS = 10;

export interface CreditStore {
  /** Today's daily credits: adds up to `amount` (once per UTC day per owner),
   * never taking the daily-sourced credits held above `bankCap`. Returns how many were added. */
  claimDaily(key: string, day: string, amount: number, bankCap: number): Promise<number>;
  /** This month's credits for a Premium user (`month` is "YYYY-MM"), same rules with monthly-sourced credits. */
  claimMonthly(key: string, month: string, amount: number, bankCap: number): Promise<number>;
  balance(key: string): Promise<number>;
  /** Adds credits once per `txn` (a store purchase, the welcome gift, a referral reward); false if this txn was seen. */
  add(key: string, amount: number, txn: string, source?: string): Promise<boolean>;
  /** Moves every credit from one owner to another (a Premium user restoring on a new install). */
  move(fromKey: string, toKey: string): Promise<number>;
  /** Takes one credit if there is one; returns the lot it came from. */
  spend(key: string): Promise<number | null>;
  /** Deletes everything held for this owner (account deletion). */
  deleteAll(key: string): Promise<void>;
  /** Gives a spent credit back to the lot it came from. */
  refund(lotId: number): Promise<void>;
  /** A store refunded this purchase: removes its credits that are still
   * unused. Returns how many were removed (spent ones are not taken back). */
  revoke(txn: string): Promise<number>;
}

/** Credits in a consumable product id, e.g. "shentarot_credits_25" -> 25. */
export function creditsInProduct(productId: string): number | null {
  const m = /credits_(\d{1,3})(?::|$)/.exec(productId);
  return m ? Number(m[1]) : null;
}

/** Each grant (purchase, daily credits) is a lot. Credits never expire; the
 * oldest lot is spent first and a refund goes back to the lot it came from. */
export class D1CreditStore implements CreditStore {
  constructor(private db: D1Database, private nowMs: () => number = () => Date.now()) {}
  private iso() { return new Date(this.nowMs()).toISOString(); }
  private async lot(key: string, amount: number, source: string, txn: string | null = null) {
    await this.db.prepare("INSERT INTO credit_lots (owner_key, remaining, created_at, source, txn) VALUES (?1, ?2, ?3, ?4, ?5)")
      .bind(key, amount, this.iso(), source, txn).run();
  }
  async balance(key: string) {
    const r = await this.db.prepare("SELECT COALESCE(SUM(remaining), 0) AS n FROM credit_lots WHERE owner_key = ?1")
      .bind(key).first<{ n: number }>();
    return r?.n ?? 0;
  }
  async add(key: string, amount: number, txn: string, source = "purchase") {
    const ins = await this.db.prepare("INSERT OR IGNORE INTO credit_grants (txn, owner_key, amount, created_at) VALUES (?1, ?2, ?3, ?4)")
      .bind(txn, key, amount, this.iso()).run();
    if ((ins.meta.changes ?? 0) === 0) return false;
    await this.lot(key, amount, source, txn);
    return true;
  }
  private async claim(key: string, period: string, amount: number, bankCap: number, source: "daily" | "monthly") {
    const column = source === "daily" ? "last_login_day" : "last_month";
    const held = await this.db.prepare("SELECT COALESCE(SUM(remaining), 0) AS n FROM credit_lots WHERE owner_key = ?1 AND source = ?2")
      .bind(key, source).first<{ n: number }>();
    const grant = Math.min(amount, bankCap - (held?.n ?? 0));
    if (grant <= 0) return 0;
    await this.db.prepare("INSERT OR IGNORE INTO credits (owner_key, balance, updated_at) VALUES (?1, 0, ?2)").bind(key, this.iso()).run();
    const r = await this.db.prepare(
      `UPDATE credits SET ${column} = ?2, updated_at = ?3 WHERE owner_key = ?1 AND (${column} IS NULL OR ${column} <> ?2)`,
    ).bind(key, period, this.iso()).run();
    if ((r.meta.changes ?? 0) === 0) return 0;
    await this.lot(key, grant, source);
    return grant;
  }
  claimDaily(key: string, day: string, amount: number, bankCap: number) {
    return this.claim(key, day, amount, bankCap, "daily");
  }
  claimMonthly(key: string, month: string, amount: number, bankCap: number) {
    return this.claim(key, month, amount, bankCap, "monthly");
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
  async deleteAll(key: string) {
    await this.db.batch([
      this.db.prepare("DELETE FROM credit_lots WHERE owner_key = ?1").bind(key),
      this.db.prepare("DELETE FROM credit_grants WHERE owner_key = ?1").bind(key),
      this.db.prepare("DELETE FROM credits WHERE owner_key = ?1").bind(key),
    ]);
  }
  async refund(lotId: number) {
    await this.db.prepare("UPDATE credit_lots SET remaining = remaining + 1 WHERE id = ?1").bind(lotId).run();
  }
  async revoke(txn: string) {
    const r = await this.db.prepare("SELECT COALESCE(SUM(remaining), 0) AS n FROM credit_lots WHERE txn = ?1").bind(txn).first<{ n: number }>();
    await this.db.prepare("UPDATE credit_lots SET remaining = 0 WHERE txn = ?1").bind(txn).run();
    return r?.n ?? 0;
  }
}
