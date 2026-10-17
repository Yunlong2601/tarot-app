# Reading credits and the Starter Pack: status and owner setup

Built 2026-10-17, **switched off** (app flag `CREDITS`, server `CREDITS_ENABLED`). Server migration `0004_credits.sql` is NOT applied to the live database yet.

## How it works (ShenTarot's version)
- **One wallet.** 1 credit = one AI reading or one follow-up / clarifier (same credit for both). The first time a user uses the app on a UTC day (`POST /v1/credits/daily`, or automatically on their first reading) they receive their daily credits: free 2, Premium annual 50, 3 months 40, monthly 30 (`FREE_DAILY_CREDITS`, `PLAN_DAILY_ALLOWANCE` in `backend/src/usage.ts`). No credits accrue on days the app is not used.
- **Rollover.** Unused credits stay and never expire. Daily credits stop arriving while the user holds 10 days' worth of daily-sourced credits (`DAILY_BANK_DAYS`); bought, referral and creator credits are outside that cap. At most 2 days' worth can be spent in one day (`DAILY_SPEND_DAYS`), which bounds cost spikes. Someone who cancels Premium keeps what they banked but receives the free amount from then on.
- Migration `0005_daily_login_credit.sql` (not applied yet) adds the credit lots table. With the wallet switched off, free gets 1 reading a day and Premium the plain per-day allowance shared by readings and follow-ups.
- The server holds the balance (per account, or per install without one), so it can't be edited on the phone. Each store purchase is added once, even if the store retries.
- A credit is given back automatically if the reading fails. The oldest credit is spent first, and a failed reading refunds the credit to the lot it came from.
- The paywall shows the Starter Pack under the memberships: "Not ready to subscribe? Starter Pack: 5 reading credits for $X, one time."
- Without an account, credits belong to this phone and are lost if the app is deleted (same as referral months); signing in keeps them. Say this in the small print once accounts are on.

## Owner setup
1. App Store Connect: In-App Purchases > + > **Consumable**, product id `shentarot_credits_5`, name "Starter Pack (5 readings)", price about US$2.99.
2. Play Console: Monetize > In-app products > Create product `shentarot_credits_5`, same name and price, Active.
3. RevenueCat: import the product (no entitlement needed). Webhook set up as in `docs/referral-setup.md` step 4 (same URL and secret).
4. Tell me to switch on: I apply migration 0004, set `CREDITS_ENABLED=true`, deploy, and build with `--dart-define=CREDITS=true`.
5. Store forms: Play Data safety already declares Purchase history; Apple's privacy label already covers purchases. Re-check both after switching on.

- Tests: `backend/test/credits-sqlite.test.ts` runs the real SQL (migrations 0004 and 0005) on node:sqlite. Still to do once: apply the migration to the live D1 database and try `/v1/credits/daily` with `wrangler dev`.

- Reinstall: free users lose credits when they delete the app (credits belong to the install) unless they signed in. Premium users keep them: when they restore purchases, RevenueCat sends a `TRANSFER` webhook event and the server moves the credits to the new install if the new id has an active Premium entitlement. RevenueCat must send TRANSFER events to the same webhook URL (all events are sent by default); Project Settings > Restore behavior must stay on the default "Transfer to new App User ID". Known gap: RevenueCat can merge anonymous ids without a TRANSFER event; test a delete / reinstall / restore on a real device before launch, and tell users to sign in as the sure way to keep credits.
