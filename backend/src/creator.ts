/** Creator program (off unless CREATOR_ENABLED=true and CREDITS_ENABLED=true).
 * Anyone can post about ShenTarot with #shentarot (and #ad / #gifted) and submit
 * the post link plus a screenshot. Every attempt gets CREATOR_CREDITS credits at
 * once, limited to CREATOR_MAX_PER_DAY a day and CREATOR_MAX_PER_MONTH a month. A
 * post that reaches LIKES_FOR_MONTH likes, checked by the owner through the admin
 * endpoints, earns 1 free month of Premium (RevenueCat promotional entitlement),
 * at most once per MONTH_COOLDOWN_DAYS and MONTHS_PER_YEAR a year. Screenshots are
 * kept in R2 for SCREENSHOT_KEEP_DAYS and then deleted. */

export const CREATOR_CREDITS = 10;
export const CREATOR_MAX_PER_DAY = 1;
export const CREATOR_MAX_PER_MONTH = 8;
export const LIKES_FOR_MONTH = 50;
export const MONTH_COOLDOWN_DAYS = 60;
export const MONTHS_PER_YEAR = 6;
export const SCREENSHOT_MAX_BYTES = 1_000_000;
export const SCREENSHOT_KEEP_DAYS = 30;
/** Request body limit: a 1 MB image is about 1.4 MB as base64. */
export const SUBMIT_MAX_BODY_CHARS = 1_500_000;

const HOSTS: Record<string, string> = {
  "tiktok.com": "tiktok", "vm.tiktok.com": "tiktok",
  "instagram.com": "instagram",
  "youtube.com": "youtube", "youtu.be": "youtube",
  "xiaohongshu.com": "xiaohongshu", "xhslink.com": "xiaohongshu",
  "reddit.com": "reddit", "redd.it": "reddit",
  "x.com": "x", "twitter.com": "x",
  "facebook.com": "facebook", "fb.watch": "facebook",
  "threads.net": "threads", "threads.com": "threads",
};

/** An https link to a post on a known platform; tracking parameters are dropped
 * so the same post cannot be submitted twice with different tags. */
export function parsePostUrl(raw: unknown): { url: string; platform: string } | null {
  if (typeof raw !== "string" || raw.length > 500) return null;
  let u: URL;
  try { u = new URL(raw.trim()); } catch { return null; }
  if (u.protocol !== "https:") return null;
  const host = u.hostname.toLowerCase().replace(/^(www|m|mobile|vm)\./, "");
  const platform = HOSTS[host] ?? HOSTS[u.hostname.toLowerCase()];
  if (!platform || u.pathname.length < 3) return null;
  return { url: `https://${host}${u.pathname.replace(/\/+$/, "")}`, platform };
}

/** Image type from the first bytes: only JPEG and PNG are accepted. */
export function sniffImage(b: Uint8Array): { mime: string; ext: string } | null {
  if (b.length > 4 && b[0] === 0xff && b[1] === 0xd8 && b[2] === 0xff) return { mime: "image/jpeg", ext: "jpg" };
  if (b.length > 8 && b[0] === 0x89 && b[1] === 0x50 && b[2] === 0x4e && b[3] === 0x47) return { mime: "image/png", ext: "png" };
  return null;
}

export function decodeBase64(s: unknown): Uint8Array | null {
  if (typeof s !== "string" || s.length === 0 || s.length > SUBMIT_MAX_BODY_CHARS) return null;
  try {
    const bin = atob(s.replace(/^data:[^,]*,/, ""));
    const out = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
    return out;
  } catch { return null; }
}

export interface CreatorPost {
  id: number; ownerKey: string; appUser: string; platform: string; url: string;
  screenshotKey: string | null; createdAt: string; status: "pending" | "verified" | "rejected";
  likes: number | null; monthGrantedAt: string | null; note: string | null;
}

export interface CreatorStore {
  /** Adds the post; null if this link was already submitted. */
  create(p: { ownerKey: string; appUser: string; platform: string; url: string; urlHash: string; screenshotKey: string; createdAt: string }): Promise<number | null>;
  countSince(ownerKey: string, sinceIso: string): Promise<number>;
  mine(ownerKey: string, limit: number): Promise<CreatorPost[]>;
  get(id: number): Promise<CreatorPost | null>;
  pending(limit: number): Promise<CreatorPost[]>;
  verify(id: number, likes: number, atIso: string): Promise<boolean>;
  reject(id: number, note: string, atIso: string): Promise<boolean>;
  markMonthGranted(id: number, atIso: string): Promise<void>;
  lastMonthAt(ownerKey: string): Promise<string | null>;
  monthsGrantedSince(ownerKey: string, sinceIso: string): Promise<number>;
  staleScreenshots(beforeIso: string, limit: number): Promise<{ id: number; key: string }[]>;
  clearScreenshot(id: number): Promise<void>;
  /** Deletes every post of this owner (for account deletion); returns the screenshot keys to delete from storage. */
  deleteAllFor(ownerKey: string): Promise<string[]>;
}

/** Where screenshots are kept (R2 in production). */
export interface ShotStorage {
  put(key: string, bytes: Uint8Array, mime: string): Promise<void>;
  get(key: string): Promise<{ bytes: Uint8Array; mime: string } | null>;
  delete(key: string): Promise<void>;
}

export class R2ShotStorage implements ShotStorage {
  constructor(private bucket: R2Bucket) {}
  async put(key: string, bytes: Uint8Array, mime: string) { await this.bucket.put(key, bytes, { httpMetadata: { contentType: mime } }); }
  async get(key: string) {
    const o = await this.bucket.get(key);
    return o ? { bytes: new Uint8Array(await o.arrayBuffer()), mime: o.httpMetadata?.contentType ?? "image/jpeg" } : null;
  }
  async delete(key: string) { await this.bucket.delete(key); }
}

type Row = Record<string, string | number | null>;
const toPost = (r: Row): CreatorPost => ({
  id: Number(r.id), ownerKey: String(r.owner_key), appUser: String(r.app_user), platform: String(r.platform), url: String(r.url),
  screenshotKey: (r.screenshot_key as string | null) ?? null, createdAt: String(r.created_at),
  status: r.status as CreatorPost["status"], likes: r.likes === null || r.likes === undefined ? null : Number(r.likes),
  monthGrantedAt: (r.month_granted_at as string | null) ?? null, note: (r.note as string | null) ?? null,
});

export class D1CreatorStore implements CreatorStore {
  constructor(private db: D1Database) {}
  async create(p: { ownerKey: string; appUser: string; platform: string; url: string; urlHash: string; screenshotKey: string; createdAt: string }) {
    const r = await this.db.prepare(
      "INSERT OR IGNORE INTO creator_posts (owner_key, app_user, platform, url, url_hash, screenshot_key, created_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
    ).bind(p.ownerKey, p.appUser, p.platform, p.url, p.urlHash, p.screenshotKey, p.createdAt).run();
    if ((r.meta.changes ?? 0) === 0) return null;
    const row = await this.db.prepare("SELECT id FROM creator_posts WHERE url_hash = ?1").bind(p.urlHash).first<{ id: number }>();
    return row?.id ?? null;
  }
  async countSince(k: string, since: string) {
    return (await this.db.prepare("SELECT COUNT(*) AS n FROM creator_posts WHERE owner_key = ?1 AND created_at >= ?2").bind(k, since).first<{ n: number }>())?.n ?? 0;
  }
  async mine(k: string, limit: number) {
    const r = await this.db.prepare("SELECT * FROM creator_posts WHERE owner_key = ?1 ORDER BY id DESC LIMIT ?2").bind(k, limit).all<Row>();
    return (r.results ?? []).map(toPost);
  }
  async get(id: number) {
    const r = await this.db.prepare("SELECT * FROM creator_posts WHERE id = ?1").bind(id).first<Row>();
    return r ? toPost(r) : null;
  }
  async pending(limit: number) {
    const r = await this.db.prepare("SELECT * FROM creator_posts WHERE status = 'pending' ORDER BY id LIMIT ?1").bind(limit).all<Row>();
    return (r.results ?? []).map(toPost);
  }
  async verify(id: number, likes: number, at: string) {
    const r = await this.db.prepare("UPDATE creator_posts SET status = 'verified', likes = ?2, reviewed_at = ?3 WHERE id = ?1 AND status = 'pending'").bind(id, likes, at).run();
    return (r.meta.changes ?? 0) > 0;
  }
  async reject(id: number, note: string, at: string) {
    const r = await this.db.prepare("UPDATE creator_posts SET status = 'rejected', note = ?2, reviewed_at = ?3 WHERE id = ?1 AND status = 'pending'").bind(id, note, at).run();
    return (r.meta.changes ?? 0) > 0;
  }
  async markMonthGranted(id: number, at: string) {
    await this.db.prepare("UPDATE creator_posts SET month_granted_at = ?2 WHERE id = ?1").bind(id, at).run();
  }
  async lastMonthAt(k: string) {
    return (await this.db.prepare("SELECT MAX(month_granted_at) AS t FROM creator_posts WHERE owner_key = ?1").bind(k).first<{ t: string | null }>())?.t ?? null;
  }
  async monthsGrantedSince(k: string, since: string) {
    return (await this.db.prepare("SELECT COUNT(*) AS n FROM creator_posts WHERE owner_key = ?1 AND month_granted_at >= ?2").bind(k, since).first<{ n: number }>())?.n ?? 0;
  }
  async staleScreenshots(before: string, limit: number) {
    const r = await this.db.prepare("SELECT id, screenshot_key FROM creator_posts WHERE screenshot_key IS NOT NULL AND created_at < ?1 LIMIT ?2").bind(before, limit).all<{ id: number; screenshot_key: string }>();
    return (r.results ?? []).map((x) => ({ id: x.id, key: x.screenshot_key }));
  }
  async deleteAllFor(k: string) {
    const r = await this.db.prepare("SELECT screenshot_key FROM creator_posts WHERE owner_key = ?1 AND screenshot_key IS NOT NULL").bind(k).all<{ screenshot_key: string }>();
    await this.db.prepare("DELETE FROM creator_posts WHERE owner_key = ?1").bind(k).run();
    return (r.results ?? []).map((x) => x.screenshot_key);
  }
  async clearScreenshot(id: number) {
    await this.db.prepare("UPDATE creator_posts SET screenshot_key = NULL WHERE id = ?1").bind(id).run();
  }
}
