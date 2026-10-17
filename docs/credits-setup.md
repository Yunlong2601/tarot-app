# Reading credits and the Starter Pack: status and owner setup

Built 2026-10-17, **switched off** (app flag `CREDITS`, server `CREDITS_ENABLED`). Server migration `0004_credits.sql` is NOT applied to the live database yet.

## How it works (ShenTarot's version)
- 1 credit = one AI reading or one follow-up / clarifier beyond the daily allowance; the same credit works for both. Everyone, free and Premium, gets 1 login credit the first time they open the app each UTC day (`POST /v1/credits/daily`), banked up to 3 (no new one while 3 login credits are held; bought credits do not count toward the 3).
- Daily allowance (readings and follow-ups together): free 1 reading; Premium by plan: annual 50, 3 months 40, monthly 30 (`PLAN_DAILY_ALLOWANCE` in `backend/src/usage.ts`). Past it, a credit pays. Migration `0005_daily_login_credit.sql` (not applied yet) adds the per-credit expiry table.
- The server holds the balance (per account, or per install without one), so it can't be edited on the phone. Each store purchase is added once, even if the store retries.
- A credit is given back automatically if the reading fails. Credits are valid for 365 days from the day they are granted (a credit received on 25 October 2026 can be used until the end of 25 October 2027, UTC); the soonest-expiring credit is spent first.
- The paywall shows the Starter Pack under the memberships: "Not ready to subscribe? Starter Pack: 5 reading credits for $X, one time."
- Without an account, credits belong to this phone and are lost if the app is deleted (same as referral months); signing in keeps them. Say this in the small print once accounts are on.

## Owner setup
1. App Store Connect: In-App Purchases > + > **Consumable**, product id `shentarot_credits_5`, name "Starter Pack (5 readings)", price about US$2.99.
2. Play Console: Monetize > In-app products > Create product `shentarot_credits_5`, same name and price, Active.
3. RevenueCat: import the product (no entitlement needed). Webhook set up as in `docs/referral-setup.md` step 4 (same URL and secret).
4. Tell me to switch on: I apply migration 0004, set `CREDITS_ENABLED=true`, deploy, and build with `--dart-define=CREDITS=true`.
5. Store forms: Play Data safety already declares Purchase history; Apple's privacy label already covers purchases. Re-check both after switching on.

- Tests: `backend/test/credits-sqlite.test.ts` runs the real SQL (migrations 0004 and 0005) on node:sqlite. Still to do once: apply the migration to the live D1 database and try `/v1/credits/daily` with `wrangler dev`.
