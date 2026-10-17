// @ts-nocheck - uses Node built-ins (node:sqlite) that the Workers tsconfig does not type.
import { DatabaseSync } from "node:sqlite";
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { D1CreatorStore } from "../src/creator";

/** Minimal D1 look-alike over node:sqlite so the real SQL runs in tests. */
function fakeD1(db: DatabaseSync): D1Database {
  const stmt = (sql: string, args: unknown[] = []) => ({
    bind: (...a: unknown[]) => stmt(sql, a),
    run: async () => ({ meta: { changes: Number(db.prepare(sql).run(...args).changes) } }),
    first: async () => db.prepare(sql).get(...args) ?? null,
    all: async () => ({ results: db.prepare(sql).all(...args) }),
  });
  return { prepare: (sql: string) => stmt(sql) } as unknown as D1Database;
}

const setup = () => {
  const db = new DatabaseSync(":memory:");
  db.exec(readFileSync(new URL("../migrations/0007_creator.sql", import.meta.url), "utf8"));
  return new D1CreatorStore(fakeD1(db));
};
const post = (n: number, extra = {}) => ({ ownerKey: "u", appUser: "app-u", platform: "tiktok", url: `https://tiktok.com/@a/video/${n}`, urlHash: `h${n}`, screenshotKey: `shots/${n}.jpg`, createdAt: "2026-10-16T10:00:00.000Z", ...extra });

describe("D1CreatorStore (real SQL)", () => {
  it("adds a post once per link and counts attempts per period", async () => {
    const s = setup();
    expect(await s.create(post(1))).toBe(1);
    expect(await s.create(post(1))).toBeNull(); // same link
    const second = await s.create(post(2, { createdAt: "2026-10-17T10:00:00.000Z" }));
    expect(second).toBeGreaterThan(1); // SQLite may skip an id after the ignored duplicate
    expect(await s.countSince("u", "2026-10-17T00:00:00.000Z")).toBe(1);
    expect(await s.countSince("u", "2026-10-01T00:00:00.000Z")).toBe(2);
    expect(await s.countSince("someone-else", "2026-10-01T00:00:00.000Z")).toBe(0);
    expect((await s.mine("u", 10)).map((p) => p.id)).toEqual([second, 1]);
  });

  it("reviews a post once and tracks free months", async () => {
    const s = setup();
    const one = await s.create(post(1));
    const two = await s.create(post(2));
    expect((await s.pending(10)).length).toBe(2);
    expect(await s.verify(one, 55, "2026-10-20T00:00:00.000Z")).toBe(true);
    expect(await s.verify(one, 60, "2026-10-21T00:00:00.000Z")).toBe(false); // already reviewed
    await s.markMonthGranted(one, "2026-10-20T00:00:00.000Z");
    expect(await s.lastMonthAt("u")).toBe("2026-10-20T00:00:00.000Z");
    expect(await s.monthsGrantedSince("u", "2026-01-01T00:00:00.000Z")).toBe(1);
    expect(await s.monthsGrantedSince("u", "2026-11-01T00:00:00.000Z")).toBe(0);
    expect(await s.reject(two, "fake likes", "2026-10-22T00:00:00.000Z")).toBe(true);
    expect(await s.reject(two, "again", "2026-10-22T00:00:00.000Z")).toBe(false);
    expect((await s.pending(10)).length).toBe(0);
    expect((await s.get(one)).likes).toBe(55);
    expect((await s.get(two)).note).toBe("fake likes");
  });

  it("finds and clears screenshots older than the cutoff", async () => {
    const s = setup();
    const old = await s.create(post(1, { createdAt: "2026-09-01T00:00:00.000Z" }));
    await s.create(post(2, { createdAt: "2026-10-16T00:00:00.000Z" }));
    expect(await s.staleScreenshots("2026-10-01T00:00:00.000Z", 10)).toEqual([{ id: old, key: "shots/1.jpg" }]);
    await s.clearScreenshot(old);
    expect(await s.staleScreenshots("2026-10-01T00:00:00.000Z", 10)).toEqual([]);
    expect((await s.get(old)).screenshotKey).toBeNull();
  });
});
