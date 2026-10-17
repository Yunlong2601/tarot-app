/** Qonversion REST API v4 (server to server, Secret Key `sk_…`). The app calls
 * `identify(appUserId)`, so our install / account id is the Qonversion
 * identity; the API is asked for the Qonversion user behind it, then for that
 * user's `premium` entitlement. Everything fails closed. */
const API = "https://api.qonversion.io/v4";

export interface PremiumEntitlement {
  active: boolean;
  /** appstore, playstore, manual (our free-month grants), ... */
  source: string;
  productId: string;
}

async function qonversionUserId(appUserId: string, secretKey: string, fetchFn: typeof fetch): Promise<string | null> {
  const res = await fetchFn(`${API}/identities/${encodeURIComponent(appUserId)}`, {
    headers: { Authorization: `Bearer ${secretKey}` },
  });
  if (!res.ok) return null;
  const data = (await res.json()) as { user_id?: string };
  return data.user_id || null;
}

/** The user's `premium` entitlement, or null when there is none. Throws on
 * network / API errors so each caller decides how to fail. */
export async function premiumEntitlement(appUserId: string, secretKey: string, nowMs: number, fetchFn: typeof fetch = fetch): Promise<PremiumEntitlement | null> {
  const userId = await qonversionUserId(appUserId, secretKey, fetchFn);
  if (!userId) return null;
  const res = await fetchFn(`${API}/users/${encodeURIComponent(userId)}/entitlements`, {
    headers: { Authorization: `Bearer ${secretKey}` },
  });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`qonversion ${res.status}`);
  const data = (await res.json()) as {
    data?: { id?: string; is_active?: boolean; expires_at?: string | null; source?: string; product?: { product_id?: string } | null }[];
  };
  const ent = data.data?.find((e) => e.id === "premium");
  if (!ent) return null;
  const notExpired = ent.expires_at == null || Date.parse(ent.expires_at) > nowMs;
  return { active: ent.is_active === true && notExpired, source: ent.source ?? "unknown", productId: ent.product?.product_id ?? "" };
}

/** Server-side premium check. Fails closed: any error or missing key means
 * "not premium". The client's claim is never trusted. */
export async function isPremium(
  installId: string,
  secretKey: string | undefined,
  kv: KVNamespace,
  nowMs: number,
  fetchFn: typeof fetch = fetch,
): Promise<boolean> {
  if (!secretKey) return false;
  const cacheKey = `premium:${installId}`;
  const cached = await kv.get(cacheKey);
  if (cached === "1") return true;
  if (cached === "0") return false;
  try {
    const active = (await premiumEntitlement(installId, secretKey, nowMs, fetchFn))?.active === true;
    await kv.put(cacheKey, active ? "1" : "0", { expirationTtl: 300 });
    return active;
  } catch {
    return false;
  }
}

/** Which paid plan the user is on, from the product behind the `premium`
 * entitlement (product ids contain annual / quarterly / monthly). Fails
 * closed to null; a premium product we do not recognise returns "other". */
export async function premiumPlan(
  installId: string,
  secretKey: string | undefined,
  kv: KVNamespace,
  nowMs: number,
  fetchFn: typeof fetch = fetch,
): Promise<"annual" | "quarterly" | "monthly" | "other" | null> {
  if (!secretKey) return null;
  const cacheKey = `plan:${installId}`;
  const cached = await kv.get(cacheKey);
  if (cached === "none") return null;
  if (cached === "annual" || cached === "quarterly" || cached === "monthly" || cached === "other") return cached;
  try {
    const ent = await premiumEntitlement(installId, secretKey, nowMs, fetchFn);
    const id = (ent?.productId ?? "").toLowerCase();
    const plan = !ent?.active ? null : id.includes("annual") ? "annual" : id.includes("quarter") ? "quarterly" : id.includes("month") ? "monthly" : "other";
    await kv.put(cacheKey, plan ?? "none", { expirationTtl: 300 });
    return plan;
  } catch {
    return null;
  }
}

/** One month of "premium" as a manual grant (referral and creator rewards). */
export async function grantFreeMonth(appUserId: string, secretKey: string, nowMs: number = Date.now(), fetchFn: typeof fetch = fetch): Promise<boolean> {
  try {
    const userId = await qonversionUserId(appUserId, secretKey, fetchFn);
    if (!userId) return false;
    const res = await fetchFn(`${API}/users/${encodeURIComponent(userId)}/entitlements`, {
      method: "POST",
      headers: { Authorization: `Bearer ${secretKey}`, "Content-Type": "application/json" },
      body: JSON.stringify({ entitlement_id: "premium", expires_at: Math.floor(nowMs / 1000) + 30 * 86_400 }),
    });
    return res.ok;
  } catch {
    return false;
  }
}

/** True when the user has Premium from a store subscription (not a manual
 * grant). Free months are banked until then. Fails "true" (bank) on errors. */
export async function hasStoreSubscription(appUserId: string, secretKey: string, nowMs: number, fetchFn: typeof fetch = fetch): Promise<boolean> {
  try {
    const ent = await premiumEntitlement(appUserId, secretKey, nowMs, fetchFn);
    return !!ent && ent.active && ent.source !== "manual";
  } catch {
    return true;
  }
}
