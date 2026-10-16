/** Reading credits (off unless CREDITS_ENABLED=true). 1 credit = one extra AI
 * reading after the free daily one, or one follow-up / clarifier for a free
 * user. Credits never expire. A credit is refunded if the reading fails. */

export interface CreditStore {
  balance(key: string): Promise<number>;
  /** Adds credits for a store purchase; false if this transaction was seen. */
  add(key: string, amount: number, txn: string): Promise<boolean>;
  /** Takes one credit if there is one. */
  spend(key: string): Promise<boolean>;
  refund(key: string): Promise<void>;
}

/** Credits in a consumable product id, e.g. "shentarot_credits_5" -> 5. */
export function creditsInProduct(productId: string): number | null {
  const m = /credits_(\d{1,3})(?::|$)/.exec(productId);
  return m ? Number(m[1]) : null;
}

export class D1CreditStore implements CreditStore {
  constructor(private db: D1Database) {}
  async balance(key: string) {
    return (await this.db.prepare("SELECT balance FROM credits WHERE owner_key = ?1").bind(key).first<{ balance: number }>())?.balance ?? 0;
  }
  async add(key: string, amount: number, txn: string) {
    const now = new Date().toISOString();
    const ins = await this.db.prepare("INSERT OR IGNORE INTO credit_grants (txn, owner_key, amount, created_at) VALUES (?1, ?2, ?3, ?4)")
      .bind(txn, key, amount, now).run();
    if ((ins.meta.changes ?? 0) === 0) return false;
    await this.db.prepare(
      "INSERT INTO credits (owner_key, balance, updated_at) VALUES (?1, ?2, ?3) " +
      "ON CONFLICT(owner_key) DO UPDATE SET balance = balance + excluded.balance, updated_at = excluded.updated_at",
    ).bind(key, amount, now).run();
    return true;
  }
  async spend(key: string) {
    const r = await this.db.prepare("UPDATE credits SET balance = balance - 1, updated_at = ?2 WHERE owner_key = ?1 AND balance > 0")
      .bind(key, new Date().toISOString()).run();
    return (r.meta.changes ?? 0) > 0;
  }
  async refund(key: string) {
    await this.db.prepare("UPDATE credits SET balance = balance + 1, updated_at = ?2 WHERE owner_key = ?1")
      .bind(key, new Date().toISOString()).run();
  }
}
