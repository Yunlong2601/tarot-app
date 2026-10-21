// @ts-nocheck - uses Node built-ins (node:sqlite) that the Workers tsconfig does not type.
import { DatabaseSync } from "node:sqlite";
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { D1CreditStore } from "../src/credits";

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
  for (const f of ["0004_credits.sql", "0005_daily_login_credit.sql", "0008_credit_refunds.sql"]) db.exec(readFileSync(new URL(`../migrations/${f}`, import.meta.url), "utf8"));
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

  it("daily credits arrive once a day, roll over, stop at the bank cap, and bought credits do not count toward it", async () => {
    const now = { t: T0 };
    const s = setup(now);
    await s.add("u", 100, "pack");
    expect(await s.claimDaily("u", "2026-10-25", 5, 12)).toBe(5);
    expect(await s.claimDaily("u", "2026-10-25", 5, 12)).toBe(0); // same day
    expect(await s.claimDaily("u", "2026-10-26", 5, 12)).toBe(5); // rolled over: 10 held
    expect(await s.claimDaily("u", "2026-10-27", 5, 12)).toBe(2); // only room for 2
    expect(await s.claimDaily("u", "2026-10-28", 5, 12)).toBe(0); // at the cap
    expect(await s.balance("u")).toBe(112);
    // spending daily credits makes room again
    for (let i = 0; i < 5; i++) await s.spend("u");
    now.t += DAY;
    expect(await s.claimDaily("u", "2026-10-29", 5, 12)).toBe(0); // oldest lot spent was the bought one
  });

  it("a refunded pack loses only its unused credits, even after a move", async () => {
    const s = setup({ t: T0 });
    await s.add("u", 10, "pack1");
    await s.add("u", 5, "other");
    for (let i = 0; i < 3; i++) await s.spend("u"); // spends from the older pack1 lot
    await s.move("u", "v");
    expect(await s.revoke("pack1")).toBe(7);
    expect(await s.balance("v")).toBe(5);
    expect(await s.revoke("pack1")).toBe(0); // repeat webhook: nothing more
  });

  it("move() hands every credit to the new owner", async () => {
    const s = setup({ t: T0 });
    await s.add("old", 3, "p1");
    await s.claimDaily("old", "2026-10-25", 1, 10);
    expect(await s.move("old", "new")).toBe(4);
    expect(await s.balance("old")).toBe(0);
    expect(await s.balance("new")).toBe(4);
    expect(await s.spend("new")).not.toBeNull();
  });

  it("monthly credits arrive once per month, roll over, and stop at the 2-month bank", async () => {
    const s = setup({ t: T0 });
    expect(await s.claimMonthly("u", "2026-10", 90, 180)).toBe(90);
    expect(await s.claimMonthly("u", "2026-10", 90, 180)).toBe(0); // same month
    expect(await s.claimMonthly("u", "2026-11", 90, 180)).toBe(90);
    expect(await s.claimMonthly("u", "2026-12", 90, 180)).toBe(0); // 180 banked
    expect(await s.claimDaily("u", "2026-10-25", 2, 20)).toBe(2); // independent of the monthly grant
    expect(await s.balance("u")).toBe(182);
  });

  it("add() with a source is idempotent per txn and counts toward the balance", async () => {
    const s = setup({ t: T0 });
    expect(await s.add("u", 10, "welcome:u", "welcome")).toBe(true);
    expect(await s.add("u", 10, "welcome:u", "welcome")).toBe(false);
    expect(await s.balance("u")).toBe(10);
    expect(await s.claimDaily("u", "2026-10-25", 2, 20)).toBe(2); // welcome is outside the daily bank
    expect(await s.balance("u")).toBe(12);
  });
});
