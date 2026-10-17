# AGENTS.md: ShenTarot tarot scan app

Read this first, then `PROGRESS.md` (current status and next steps), then `docs/step1-plan.md` (full plan, costs, store notes). Keep `PROGRESS.md` updated at the end of every phase.

## What it is
Flutter app (iOS + Android). The user scans a physical Rider-Waite-Smith tarot card with the camera; an on-device model identifies it (manual picker fallback); a backend returns an AI reading. Credits are the one currency (owner decision 2026-10-17): 1 credit = one AI reading or one follow-up. Everyone gets 2 credits the first time they use the app each UTC day; Premium also gets monthly credits the first time they use it each UTC month: annual 150, 3 months 120, monthly 90. Unused credits roll over and never expire; daily credits stop arriving once 10 days' worth are held, monthly ones once 2 months' worth are held, bought/referral credits are outside the caps, and nobody can spend more than 50 credits a day. Free users can read 1 to 3-card spreads; the 5, 7 and 10-card spreads are Premium after one free trial reading (`isFreeSpread` in `backend/src/spreads.ts` and `SpreadInfo.isFree` in `app/lib/data/spreads.dart` must match). New users get 10 welcome credits once. Referral: when a friend redeems a code and finishes a first reading, both get 10 credits (the referrer for up to 20 friends a year; needs `REFERRALS_ENABLED` and `CREDITS_ENABLED`). Signing in moves the install's credits to the account. Creator program (`CREATOR_ENABLED` + `CREDITS_ENABLED`, app flag `CREATOR`, needs an R2 bucket `SHOTS` and `ADMIN_TOKEN`): anyone posts with #shentarot and sends the link and a screenshot for 10 credits (1 a day, 8 a month, each post once); 50 likes, checked by the owner through `/v1/admin/creator/*`, earns 1 free month (60-day cooldown, 6 a year); screenshots are deleted after 30 days (`docs/creator-setup.md`). Premium also has follow-ups, the clarifier card, look back and journal notes. Premium users keep credits across reinstall via restore; free users lose them on delete unless signed in. The wallet is behind `CREDITS_ENABLED` (server) and `CREDITS` (app); with it off, free gets 2 readings a day (owner decision 2026-10-17, was 1; `FREE_READINGS_PER_DAY` change pending) and Premium up to 50 a day. Entertainment and self-reflection only; no medical, legal, financial or life-or-death predictions.

## Decisions (do not re-litigate without the owner)
- Store name: **ShenTarot: AI Lens** (the name on the App Store Connect record created for ShenTarot, 2026-10-17; it replaced the earlier pick "ShenTarot: AI Scan & Read"; brand from ShenTech). Earlier candidates dropped: "Veilscan" (a cybersecurity product called VeilScan exists) and "ShenScan: Tarot Card Scanner". A quick web search found no ShenTarot app or trademark, but that is not a registry check: owner still searches IPOS and the stores. Audience: people who own a physical deck and don't know how to read what they drew. Copy: `docs/store-listing.md`. The bundle id `com.shentech.shentarot` is final (App Store Connect app 6823779463, SKU `shentarot`); the `shentarot.db` file name stays.
- Flutter; Cloudflare Workers backend (TypeScript, KV + D1); LLM Claude Haiku 5.5 (`claude-haiku-5-5`, effort low, model name in a backend env var); Qonversion for subscriptions (owner decision 2026-10-17, replaced RevenueCat before launch: free up to US$7,000 monthly tracked revenue, then 0.8%); no user accounts; SQLite on device for history; English first (strings should be easy to localise later).
- Deck: Rider-Waite-Smith only. Card art must be public domain (1909 scans) or original. Never use 1971+ US Games art. Do not use "Rider-Waite" in the app name, icon or keywords.
- The mobile app never contains an LLM API key. Secrets live in backend env vars (`wrangler secret put`). Never commit keys.
- Prices (USD, to be re-set in SGD per storefront): annual $39.99 with $1.99 for the first month (no free trial), 3 months $14.99, monthly $6.99; no weekly (owner decision 2026-10-17, repriced from 99.99/34.99/14.99 the same day).
- Owner is a student in Singapore (PDPA, tax forms, store account rules are in the plan addendum; all items are "to verify").

## Layout
```
app/        Flutter app (lib/app, lib/data, lib/features/*, assets/cards, tools/, test/)
backend/    Cloudflare Worker (Phase D, see backend/README.md)
ml/         Training pipeline for the card classifier (Phase C)
docs/       step1-plan.md and later docs (privacy, terms drafts, store checklists in Phase G)
```

## Working copy
The owner's local folder on their Mac (`/Users/syl/tarot-app`) is the primary working copy. This GitHub repo is the backup and the hand-off point between tools. The repo must stay self-contained and tool-agnostic: any AI tool or developer should be able to continue from README.md, AGENTS.md, PROGRESS.md and docs/ alone. Never put cloud-only paths or secrets in the repo.

## Run and test
```bash
cd app && flutter pub get && flutter analyze && flutter test && flutter run
```
Toolchain used so far: Flutter 3.47.7 stable. (In one cloud sandbox a hook forced the test run through an MCP tool; that is an environment quirk, not a project rule. Run `flutter pub get` first or the test run reports a missing flutter_test dependency.)

## Conventions
- Small commits, one branch per phase (`phase-x-name`), PR to `main`, never push to `main` directly. Commit trailers: `Co-Authored-By` and `Claude-Session` lines as used in existing commits.
- Match existing style: Material 3 dark theme in `lib/app/theme.dart`, go_router in `lib/app/router.dart`, plain `ChangeNotifier` state (`lib/app/app_state.dart`) until Phase E/F replace the mocks.
- Card text in `app/assets/cards/cards.json` is generated by `app/tools/make_cards.py`; edit the script, regenerate, and keep the 78-card tests green.
- Every screen that shows a reading keeps the "for entertainment and self-reflection only" disclaimer.
- Camera frames are never stored or uploaded. If a temp photo file is created it must be deleted immediately.
- Say what was NOT verified (devices, store rules, licences) instead of assuming.
