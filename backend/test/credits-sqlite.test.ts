// @ts-nocheck - uses Node built-ins (node:sqlite) that the Workers tsconfig does not type.
import { DatabaseSync } from "node:sqlite";
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { D1CreditStore, LOGIN_CREDIT_BANK_CAP } from "../src/credits";

/** Minimal D1 look-alike over node:sqlite so the real SQL runs in tests. */
function fakeD1(db: DatabaseSync): D1Database {
  const stmt = (sql: string, args: unknown[] = []) => ({
    bind: (...a: unknown[]) => stmt(sql, a),
    run: async () => ({ meta: { changes: Number(db.prepare(sql).run(...(args as never[])).changes) } }),
    first: async () => (db.prepare(sql).get(...(args as never[])) as never) ?? null,
  });
  return { prepare: (sql: string) => stmt(sql) } as unknown as D1Database;
}

function setup(now: { t: number }) {
  const db = new DatabaseSync(":memory:");
  for (const f of ["0004_credits.sql", "0005_daily_login_credit.sql"]) db.exec(readFileSync(new URL(`../migrations/${f}`, import.meta.url), "utf8"));
  return new D1CreditStore(fakeD1(db), () => now.t);
}
const DAY = 86_400_000;
const T0 = Date.parse("2026-10-25T09:30:00Z");

describe("D1CreditStore (real SQL)", () => {
  it("credits never expire, the oldest is spent first, and a refund goes back to its own lot", async () => {
    const now = { t: T0 };
    const s = setup(now);
    await s.add("u", 1, "old");
    now.t = T0 + 30 * DAY;
    await s.add("u", 1, "new");
    expect(await s.add("u", 1, "new")).toBe(false); // same transaction twice
    now.t = Date.parse("2035-01-01T00:00:00Z"); // years later
    expect(await s.balance("u")).toBe(2);
    const first = await s.spend("u");
    expect(first).toBe(1); // the older lot
    await s.refund(first!);
    expect(await s.balance("u")).toBe(2);
    expect(await s.spend("u")).toBe(1);
    expect(await s.spend("u")).toBe(2);
    expect(await s.spend("u")).toBeNull();
  });

  it("one login credit a day, banked up to 3; bought credits never block it", async () => {
    const now = { t: T0 };
    const s = setup(now);
    await s.add("u", 5, "pack");
    expect(await s.claimDaily("u", "2026-10-25", LOGIN_CREDIT_BANK_CAP)).toBe(true);
    expect(await s.claimDaily("u", "2026-10-25", LOGIN_CREDIT_BANK_CAP)).toBe(false); // same day
    expect(await s.claimDaily("u", "2026-10-26", LOGIN_CREDIT_BANK_CAP)).toBe(true);
    expect(await s.claimDaily("u", "2026-10-27", LOGIN_CREDIT_BANK_CAP)).toBe(true);
    expect(await s.claimDaily("u", "2026-10-28", LOGIN_CREDIT_BANK_CAP)).toBe(false); // 3 login credits held
    expect(await s.balance("u")).toBe(8);
  });

  it("move() hands every credit to the new owner", async () => {
    const s = setup({ t: T0 });
    await s.add("old", 3, "p1");
    await s.claimDaily("old", "2026-10-25", LOGIN_CREDIT_BANK_CAP);
    expect(await s.move("old", "new")).toBe(4);
    expect(await s.balance("old")).toBe(0);
    expect(await s.balance("new")).toBe(4);
    expect(await s.spend("new")).not.toBeNull();
  });
});
