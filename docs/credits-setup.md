# Reading credits and credit packs: status and owner setup

Built 2026-10-17, **switched off** (app flag `CREDITS`, server `CREDITS_ENABLED`). Server migration `0004_credits.sql` is NOT applied to the live database yet.

## How it works (ShenTarot's version)
- **One wallet.** 1 credit = one AI reading or one follow-up / clarifier (same credit for both). Everyone gets 2 credits the first time they use the app on a UTC day (`FREE_DAILY_CREDITS`). Premium also gets monthly credits the first time they use it in a UTC calendar month: annual 150, 3 months 120, monthly 90 (`PLAN_MONTHLY_CREDITS` in `backend/src/usage.ts`). `POST /v1/credits/daily` grants both; the first reading does it automatically. Nothing accrues on days or months the app is not used, and nothing new arrives after Premium lapses.
- **Welcome gift.** 10 credits once per owner (a first grant, idempotent by transaction id `welcome:<key>`, outside the caps). Reinstalling gives a new owner and so a new gift until App Attest / Play Integrity is built; signing in moves credits to the account.
- **Referral credits.** When a friend who redeemed a code finishes a first reading, the friend and the referrer each get 10 credits (`REFERRAL_CREDITS`); the referrer is rewarded for at most 20 friends a year (`REFERRAL_CREDIT_FRIENDS_PER_YEAR`), the friend always. Needs `REFERRALS_ENABLED` and `CREDITS_ENABLED`; migration `0006_referral_credits.sql` (not applied yet). Worst-case farming by one person costs 20 credits x 20 friends = 400 credits a year (about US$1.20).
- **Rollover and caps.** Unused credits stay and never expire. Daily credits stop arriving while 10 days' worth are held (`DAILY_BANK_DAYS`), monthly ones while 2 months' worth are held (`MONTHLY_BANK_MONTHS`); bought, referral and creator credits are outside both caps. Nobody can spend more than 50 credits a day (`DAILY_SPEND_GUARD`), which bounds abuse and cost spikes. Someone who cancels keeps what they banked.
- Calendar-month grants can be slightly gamed (subscribe on the 31st, get this month's and next month's credits within two days); accepted. Billing-date anchoring would need Qonversion purchase dates.
- Migration `0005_daily_login_credit.sql` (not applied yet) adds the credit lots table and the grant-period columns. With the wallet switched off, free gets 1 reading a day and Premium up to 50 a day, shared by readings and follow-ups.
- The server holds the balance (per account, or per install without one), so it can't be edited on the phone. Each store purchase is added once, even if the store retries.
- A credit is given back automatically if the reading fails. The oldest credit is spent first, and a failed reading refunds the credit to the lot it came from.
- The paywall shows credit packs under the memberships ("Not ready to subscribe?"). Packs are priced per credit well above Premium's monthly credits on purpose (owner decision 2026-10-17), so Premium is the better deal and the packs nudge heavier users toward it: 10 credits US$1.99 (US$0.20 each), 25 credits US$3.99 (US$0.16), 40 credits US$5.99 (US$0.15), against about US$0.078 per monthly-plan credit (US$6.99 for 90) and less on the longer plans. The biggest pack costs less than the monthly plan in total, so the plan is the natural next step.
- Without an account, credits belong to this phone and are lost if the app is deleted (same as referral months); signing in keeps them. Say this in the small print once accounts are on.

## Owner setup
1. App Store Connect: In-App Purchases > + > **Consumable**, three products: `shentarot_credits_10` ("10 credits", US$1.99), `shentarot_credits_25` ("25 credits", US$3.99), `shentarot_credits_40` ("40 credits", US$5.99). The number in the product id is the credit count the server adds.
2. Play Console: Monetize > In-app products > create the same three product ids, names and prices, Active.
3. Qonversion: create a product with the same id (no entitlement needed). Webhook set up as in `docs/referral-setup.md` step 4 (same URL and secret); the server reads the `in_app_purchase` event.
4. Tell me to switch on: I apply migration 0004, set `CREDITS_ENABLED=true`, deploy, and build with `--dart-define=CREDITS=true`.
5. Store forms: Play Data safety already declares Purchase history; Apple's privacy label already covers purchases. Re-check both after switching on.

- Tests: `backend/test/credits-sqlite.test.ts` runs the real SQL (migrations 0004 and 0005) on node:sqlite. Still to do once: apply the migration to the live D1 database and try `/v1/credits/daily` with `wrangler dev`.

- Reinstall: credits belong to the install (or the account when signed in). Free users and Premium users who are not signed in lose them when they delete the app. With RevenueCat a `TRANSFER` event used to move a restoring Premium user's credits; Qonversion has no such event, so that was removed on 2026-10-17. Before credits ship, either ask Premium users to sign in, or move credits on restore with a server check. Credits are off for v1.
