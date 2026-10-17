/** Reading credits (off unless CREDITS_ENABLED=true). 1 credit = one extra AI
 * reading or follow-up / clarifier beyond the daily allowance. Credits are valid for one year. A credit is refunded if the reading fails. */

/** Everyone gets this many credits the first time they open the app each UTC
 * day, unless they already hold LOGIN_CREDIT_BANK_CAP or more. */
export const DAILY_LOGIN_CREDITS = 1;
export const LOGIN_CREDIT_BANK_CAP = 3;

export interface CreditStore {
  /** Daily login credit: true if one was added now (once per day per owner;
   * bankCap limits how many login credits can be held at once). */
  claimDaily(key: string, day: string, bankCap: number): Promise<boolean>;
  balance(key: string): Promise<number>;
  /** Adds credits for a store purchase; false if this transaction was seen. */
  add(key: string, amount: number, txn: string): Promise<boolean>;
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

/** A credit is valid for 365 days from the day it is received, through the end
 * of that (UTC) day: received 25 Oct 2026 -> usable until the end of 25 Oct 2027. */
export const CREDIT_VALID_DAYS = 365;
export const creditExpiry = (nowMs: number): string =>
  new Date(nowMs + CREDIT_VALID_DAYS * 86_400_000).toISOString().slice(0, 10) + "T23:59:59.999Z";

/** Each grant (purchase, login credit, refund) is a lot with its own expiry;
 * the balance is the unexpired remainder and the soonest-expiring lot is spent first. */
export class D1CreditStore implements CreditStore {
  constructor(private db: D1Database, private nowMs: () => number = () => Date.now()) {}
  private iso() { return new Date(this.nowMs()).toISOString(); }
  private async lot(key: string, amount: number, source: string) {
    await this.db.prepare("INSERT INTO credit_lots (owner_key, remaining, expires_at, created_at, source) VALUES (?1, ?2, ?3, ?4, ?5)")
      .bind(key, amount, creditExpiry(this.nowMs()), this.iso(), source).run();
  }
  async balance(key: string) {
    const r = await this.db.prepare("SELECT COALESCE(SUM(remaining), 0) AS n FROM credit_lots WHERE owner_key = ?1 AND expires_at > ?2")
      .bind(key, this.iso()).first<{ n: number }>();
    return r?.n ?? 0;
  }
  async add(key: string, amount: number, txn: string) {
    const ins = await this.db.prepare("INSERT OR IGNORE INTO credit_grants (txn, owner_key, amount, created_at) VALUES (?1, ?2, ?3, ?4)")
      .bind(txn, key, amount, this.iso()).run();
    if ((ins.meta.changes ?? 0) === 0) return false;
    await this.lot(key, amount, "purchase");
    return true;
  }
  async claimDaily(key: string, day: string, bankCap: number) {
    // The bank cap counts login credits only; bought credits never block them.
    const held = await this.db.prepare("SELECT COALESCE(SUM(remaining), 0) AS n FROM credit_lots WHERE owner_key = ?1 AND source = 'login' AND expires_at > ?2")
      .bind(key, this.iso()).first<{ n: number }>();
    if ((held?.n ?? 0) >= bankCap) return false;
    await this.db.prepare("INSERT OR IGNORE INTO credits (owner_key, balance, updated_at) VALUES (?1, 0, ?2)").bind(key, this.iso()).run();
    const r = await this.db.prepare(
      "UPDATE credits SET last_login_day = ?2, updated_at = ?3 WHERE owner_key = ?1 AND (last_login_day IS NULL OR last_login_day <> ?2)",
    ).bind(key, day, this.iso()).run();
    if ((r.meta.changes ?? 0) === 0) return false;
    await this.lot(key, 1, "login");
    return true;
  }
  async spend(key: string) {
    for (let attempt = 0; attempt < 3; attempt++) {
      const lot = await this.db.prepare(
        "SELECT id FROM credit_lots WHERE owner_key = ?1 AND remaining > 0 AND expires_at > ?2 ORDER BY expires_at, id LIMIT 1",
      ).bind(key, this.iso()).first<{ id: number }>();
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
