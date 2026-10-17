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
  it("a credit bought on 25 Oct 2026 works until the end of 25 Oct 2027, then expires", async () => {
    const now = { t: T0 };
    const s = setup(now);
    expect(await s.add("u", 2, "t1")).toBe(true);
    expect(await s.add("u", 2, "t1")).toBe(false); // same transaction twice
    expect(await s.balance("u")).toBe(2);
    now.t = Date.parse("2027-10-25T20:00:00Z");
    expect(await s.balance("u")).toBe(2);
    now.t = Date.parse("2027-10-26T00:00:01Z");
    expect(await s.balance("u")).toBe(0);
    expect(await s.spend("u")).toBeNull();
  });

  it("spends the soonest-expiring credit first and a refund goes back to its own lot", async () => {
    const now = { t: T0 };
    const s = setup(now);
    await s.add("u", 1, "old");
    now.t = T0 + 30 * DAY;
    await s.add("u", 1, "new");
    const first = await s.spend("u");
    expect(first).toBe(1); // the older lot
    await s.refund(first!);
    expect(await s.balance("u")).toBe(2);
    now.t = Date.parse("2027-10-26T00:00:01Z"); // the old lot expired, the newer one has not
    expect(await s.balance("u")).toBe(1);
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
});
