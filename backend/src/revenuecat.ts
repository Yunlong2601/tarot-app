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
    const res = await fetchFn(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(installId)}`, {
      headers: { Authorization: `Bearer ${secretKey}` },
    });
    if (!res.ok) return false;
    const data = (await res.json()) as {
      subscriber?: { entitlements?: Record<string, { expires_date: string | null }> };
    };
    const ent = data.subscriber?.entitlements?.premium;
    const active = !!ent && (ent.expires_date === null || Date.parse(ent.expires_date) > nowMs);
    await kv.put(cacheKey, active ? "1" : "0", { expirationTtl: 300 });
    return active;
  } catch {
    return false;
  }
}
