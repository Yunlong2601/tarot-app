/** Refer and earn (off unless REFERRALS_ENABLED=true).
 * Both sides: 10 credits each when the friend finishes a first reading (needs
 * CREDITS_ENABLED too); the referrer is rewarded for at most 20 friends a year.
 * Friend: 50% off the first year of annual, only when subscribing (Apple
 * one-time offer code / Play developer-determined offer "referral-50").
 * Referrer: 1 free month per friend who pays, 14 days after the payment, at
 * most 6 a year, granted as a RevenueCat promotional entitlement. */

export const CREDIT_DELAY_DAYS = 14;
export const MAX_CREDITS_PER_YEAR = 6;
/** Credits each side gets when the friend finishes a first reading, and the
 * most friends a referrer is rewarded for in a year (the friend is always rewarded). */
export const REFERRAL_CREDITS = 10;
export const REFERRAL_CREDIT_FRIENDS_PER_YEAR = 20;
export const PLAY_REFERRAL_OFFER_TAG = "referral-50";
const ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"; // no 0/O, 1/I/L

export function newCode(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(8));
  return [...bytes].map((b) => ALPHABET[b % ALPHABET.length]).join("");
}

export const normaliseCode = (raw: unknown): string | null => {
  if (typeof raw !== "string") return null;
  const c = raw.trim().toUpperCase().replace(/[\s-]/g, "");
  return /^[A-Z0-9]{8}$/.test(c) ? c : null;
};

export interface Referral {
  friendKey: string; referrerKey: string; code: string; platform: string;
  redeemedAt: string; paidTxn: string | null; paidAt: string | null; creditedAt: string | null;
}

export interface ReferralStore {
  codeFor(ownerKey: string): Promise<string | null>;
  createCode(ownerKey: string, appUserId: string, code: string): Promise<void>;
  ownerOf(code: string): Promise<string | null>;
  appUserOf(ownerKey: string): Promise<string | null>;
  referralOf(friendKey: string): Promise<Referral | null>;
  addReferral(r: Referral): Promise<void>;
  markPaid(friendKey: string, txn: string, at: string): Promise<boolean>;
  dueForCredit(beforeIso: string): Promise<Referral[]>;
  creditsSince(referrerKey: string, sinceIso: string): Promise<number>;
  markCredited(friendKey: string, at: string): Promise<void>;
  stats(referrerKey: string): Promise<{ redeemed: number; paid: number; credited: number }>;
  /** Anonymous list of this referrer's friends: dates and status only. */
  friendsOf(referrerKey: string): Promise<{ joinedAt: string; paidAt: string | null; creditedAt: string | null }[]>;
  /** The friend finished a first reading: marks it once. Returns the referrer and
   * whether the referrer is still under the yearly cap (and so is rewarded); null if
   * there is no referral or it already paid out. */
  claimReadingReward(friendKey: string, atIso: string, sinceIso: string, maxPerYear: number): Promise<{ referrerKey: string; rewardReferrer: boolean } | null>;
  /** Friends this referrer was rewarded for (credits earned = this x REFERRAL_CREDITS). */
  rewardedFriends(referrerKey: string): Promise<number>;
  takeAppleCode(friendKey: string, at: string): Promise<string | null>;
  /** Deletes this owner's code and every referral they are part of, as friend or referrer (account deletion). */
  deleteAll(ownerKey: string): Promise<void>;
}

export class D1ReferralStore implements ReferralStore {
  constructor(private db: D1Database) {}
  async codeFor(k: string) {
    return (await this.db.prepare("SELECT code FROM referral_codes WHERE owner_key = ?1").bind(k).first<{ code: string }>())?.code ?? null;
  }
  async createCode(k: string, appUserId: string, code: string) {
    await this.db.prepare("INSERT INTO referral_codes (code, owner_key, owner_app_user, created_at) VALUES (?1, ?2, ?3, ?4)")
      .bind(code, k, appUserId, new Date().toISOString()).run();
  }
  async appUserOf(k: string) {
    return (await this.db.prepare("SELECT owner_app_user FROM referral_codes WHERE owner_key = ?1").bind(k).first<{ owner_app_user: string }>())?.owner_app_user ?? null;
  }
  async ownerOf(code: string) {
    return (await this.db.prepare("SELECT owner_key FROM referral_codes WHERE code = ?1").bind(code).first<{ owner_key: string }>())?.owner_key ?? null;
  }
  async referralOf(friendKey: string) {
    const r = await this.db.prepare("SELECT * FROM referrals WHERE friend_key = ?1").bind(friendKey).first<Record<string, string | null>>();
    return r ? rowToReferral(r) : null;
  }
  async addReferral(r: Referral) {
    await this.db.prepare(
      "INSERT INTO referrals (friend_key, referrer_key, code, platform, redeemed_at) VALUES (?1, ?2, ?3, ?4, ?5)",
    ).bind(r.friendKey, r.referrerKey, r.code, r.platform, r.redeemedAt).run();
  }
  async markPaid(friendKey: string, txn: string, at: string) {
    const res = await this.db.prepare(
      "UPDATE referrals SET paid_txn = ?2, paid_at = ?3 WHERE friend_key = ?1 AND paid_txn IS NULL " +
      "AND NOT EXISTS (SELECT 1 FROM referrals WHERE paid_txn = ?2)",
    ).bind(friendKey, txn, at).run();
    return (res.meta.changes ?? 0) > 0;
  }
  async dueForCredit(before: string) {
    const r = await this.db.prepare("SELECT * FROM referrals WHERE paid_at IS NOT NULL AND paid_at <= ?1 AND credited_at IS NULL")
      .bind(before).all<Record<string, string | null>>();
    return (r.results ?? []).map(rowToReferral);
  }
  async creditsSince(k: string, since: string) {
    return (await this.db.prepare("SELECT COUNT(*) AS n FROM referrals WHERE referrer_key = ?1 AND credited_at >= ?2")
      .bind(k, since).first<{ n: number }>())?.n ?? 0;
  }
  async markCredited(friendKey: string, at: string) {
    await this.db.prepare("UPDATE referrals SET credited_at = ?2 WHERE friend_key = ?1").bind(friendKey, at).run();
  }
  async stats(k: string) {
    const r = await this.db.prepare(
      "SELECT COUNT(*) AS redeemed, COUNT(paid_at) AS paid, COUNT(credited_at) AS credited FROM referrals WHERE referrer_key = ?1",
    ).bind(k).first<{ redeemed: number; paid: number; credited: number }>();
    return r ?? { redeemed: 0, paid: 0, credited: 0 };
  }
  async friendsOf(k: string) {
    const r = await this.db.prepare(
      "SELECT redeemed_at, paid_at, credited_at FROM referrals WHERE referrer_key = ?1 ORDER BY redeemed_at DESC LIMIT 50",
    ).bind(k).all<{ redeemed_at: string; paid_at: string | null; credited_at: string | null }>();
    return (r.results ?? []).map((x) => ({ joinedAt: x.redeemed_at, paidAt: x.paid_at, creditedAt: x.credited_at }));
  }

  async claimReadingReward(friendKey: string, atIso: string, sinceIso: string, maxPerYear: number) {
    const upd = await this.db.prepare(
      "UPDATE referrals SET reading_credited_at = ?2, referrer_rewarded = " +
      "CASE WHEN (SELECT COUNT(*) FROM referrals r2 WHERE r2.referrer_key = referrals.referrer_key " +
      "AND r2.referrer_rewarded = 1 AND r2.reading_credited_at >= ?3) < ?4 THEN 1 ELSE 0 END " +
      "WHERE friend_key = ?1 AND reading_credited_at IS NULL",
    ).bind(friendKey, atIso, sinceIso, maxPerYear).run();
    if ((upd.meta.changes ?? 0) === 0) return null;
    const row = await this.db.prepare("SELECT referrer_key, referrer_rewarded FROM referrals WHERE friend_key = ?1")
      .bind(friendKey).first<{ referrer_key: string; referrer_rewarded: number }>();
    return row ? { referrerKey: row.referrer_key, rewardReferrer: row.referrer_rewarded === 1 } : null;
  }
  async rewardedFriends(k: string) {
    return (await this.db.prepare("SELECT COUNT(*) AS n FROM referrals WHERE referrer_key = ?1 AND referrer_rewarded = 1")
      .bind(k).first<{ n: number }>())?.n ?? 0;
  }

  async deleteAll(k: string) {
    await this.db.batch([
      this.db.prepare("DELETE FROM referral_codes WHERE owner_key = ?1").bind(k),
      this.db.prepare("DELETE FROM referrals WHERE friend_key = ?1 OR referrer_key = ?1").bind(k),
      // keep an issued one-time code consumed, but unlink it from the person
      this.db.prepare("UPDATE apple_offer_codes SET assigned_to = 'deleted' WHERE assigned_to = ?1").bind(k),
    ]);
  }

  async takeAppleCode(friendKey: string, at: string) {
    const existing = await this.db.prepare("SELECT code FROM apple_offer_codes WHERE assigned_to = ?1").bind(friendKey).first<{ code: string }>();
    if (existing) return existing.code;
    const row = await this.db.prepare(
      "UPDATE apple_offer_codes SET assigned_to = ?1, assigned_at = ?2 WHERE code = " +
      "(SELECT code FROM apple_offer_codes WHERE assigned_to IS NULL LIMIT 1) RETURNING code",
    ).bind(friendKey, at).first<{ code: string }>();
    return row?.code ?? null;
  }
}

function rowToReferral(r: Record<string, string | null>): Referral {
  return {
    friendKey: r.friend_key!, referrerKey: r.referrer_key!, code: r.code!, platform: r.platform!,
    redeemedAt: r.redeemed_at!, paidTxn: r.paid_txn ?? null, paidAt: r.paid_at ?? null, creditedAt: r.credited_at ?? null,
  };
}

/** RevenueCat promotional entitlement: one month of "premium" for the app user. */
export async function grantFreeMonth(appUserId: string, secretKey: string, fetchFn: typeof fetch = fetch): Promise<boolean> {
  const res = await fetchFn(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}/entitlements/premium/promotional`,
    { method: "POST", headers: { Authorization: `Bearer ${secretKey}`, "Content-Type": "application/json" }, body: JSON.stringify({ duration: "monthly" }) },
  );
  return res.ok;
}

/** True when the user has Premium from a store subscription (not a promotional
 * grant). Free months are banked until then. Fails "true" (bank) on errors. */
export async function hasStoreSubscription(appUserId: string, secretKey: string, nowMs: number, fetchFn: typeof fetch = fetch): Promise<boolean> {
  try {
    const res = await fetchFn(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`, {
      headers: { Authorization: `Bearer ${secretKey}` },
    });
    if (!res.ok) return true;
    const data = (await res.json()) as { subscriber?: { entitlements?: Record<string, { expires_date: string | null; product_identifier?: string }> } };
    const e = data.subscriber?.entitlements?.premium;
    if (!e) return false;
    const active = e.expires_date === null || Date.parse(e.expires_date) > nowMs;
    return active && !(e.product_identifier ?? "").startsWith("rc_promo");
  } catch {
    return true;
  }
}
