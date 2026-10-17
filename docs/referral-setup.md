# Refer and earn: status and owner setup

> **Provider change (2026-10-17):** subscriptions move from RevenueCat to **Qonversion** (owner decision; the app and backend code migration is in progress). RevenueCat steps, keys and webhooks below are on hold: do not create a RevenueCat project. This doc is rewritten for Qonversion once the code lands.

Built 2026-10-17, **switched off** (app flag `REFERRALS`, server `REFERRALS_ENABLED`). Design: `market-research/referral-program.md` (project library).

## Built
- Server (`backend/src/referrals.ts`, migration `0003_referrals.sql`, NOT applied to the live database yet): `POST /v1/referral/me` (code, counts, anonymous friends list), `POST /v1/referral/redeem` (rate-limited; hands out a one-time Apple offer code from a pool, or returns the Play offer tag `referral-50`), `POST /v1/webhooks/revenuecat` (a friend's first paid purchase qualifies; free trials, zero-price and promotional events don't), daily cron that grants 1 RevenueCat promotional month 14 days after payment, max 6 a year, banked while the referrer has an active store subscription.
- App: You tab > Invite friends (tier and progress, code, share sheet, earned/pending months, anonymous friends list, tier ladder, small print, friend-code entry). Paywall: Android shows the friend's annual offer from the store; iOS shows the App Store code and opens Apple's redeem sheet.
- Not built: Apple subscription extensions / Play deferred billing for referrers who are subscribed (credits are banked instead), cosmetic rewards (art not made), App Review notes text.

## Owner setup (in order)
1. **App Store Connect**: on `shentarot_annual` > Subscription Prices > Offer Codes: create an offer "Friend 50%" (new subscribers, pay up front, 1 year, US$19.99 (50% of the US$39.99 annual price)). Generate one-time codes (CSV). Codes expire within 6 months; generate in batches.
2. Send me the CSV file (or run `npx wrangler d1 execute shentarot --remote --command "INSERT INTO apple_offer_codes (code) VALUES ('CODE1'),('CODE2')"`); codes are not secrets but treat them as limited stock.
3. **Play Console**: on `shentarot_annual` base plan > Add offer: developer-determined, tag **`referral-50`**, one phase: single payment, 1 year, US$19.99 (50% of the US$39.99 annual price), eligibility "never had any subscription in this app".
4. **RevenueCat**: Project > Integrations > Webhooks: URL `https://shentarot-api.shentech.workers.dev/v1/webhooks/revenuecat`, Authorization header = a long random string; then `npx wrangler secret put REVENUECAT_WEBHOOK_AUTH` with the same string. The RevenueCat secret API key must already be set (`REVENUECAT_SECRET_KEY`).
5. Tell me to switch on: I apply migration 0003, set `REFERRALS_ENABLED=true`, deploy, and build with `--dart-define=REFERRALS=true`.
6. Legal review of `docs/referral-terms-draft.md`; then I add it to the Terms and the privacy policy, and update `docs/data-inventory.md`, Play Data safety and Apple privacy labels.
7. **Cosmetics** (original art only): an "Adept" card back (same size as the current card back), a "Mystic" alternate app icon (1024 px) and reading theme colours, an "Oracle" badge. Until supplied, tiers show the perks as "coming soon".
