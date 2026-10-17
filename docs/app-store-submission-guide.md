# App Store submission guide: the fastest safe path (v1)

Written 2026-10-17. Menu names, sizes and rules change: items marked (verify) must be checked in App Store Connect or Apple's current pages before you rely on them. Longer checklists: `docs/app-store-checklist.md`, `docs/test-plan.md`.

## 1. Launch scope for v1 (decide first)
**Recommended: ship v1 with the new credit wallet, referral, creator program and sign-in switched OFF.** It cuts review risk and work: no consumable packs to review, no credit server to deploy and test, no free-credit giveaways to attack. v1 is then:
- Free: 1 AI reading a day on 1 to 3-card spreads, plus one try of a 5, 7 or 10-card spread; scanning, manual pick, Card of the Day, library, guide, history.
- Premium: all spreads, up to 50 readings a day, follow-ups, clarifier card, look-back, journal notes. Plans: monthly US$6.99, 3 months US$14.99, annual US$39.99 with US$1.99 first month.
- The credit wallet, referrals, creator program and credit packs ship in v1.1 (all built and tested, flags off; `docs/credits-setup.md`, `docs/creator-setup.md`).

**Second decision: device checks.** The owner's 2026-10-16 decision is App Attest before launch. It needs your paid Apple Team and is real work (server-side certificate checks). Faster interim: launch with unattested installs, but only with these in place: per-IP new-install limit in the database, the global token cap raised and alarmed, and an Anthropic monthly spend limit. Exposure is small in v1 because a fake install gets only 1 reading a day (about US$0.0003), and it shrinks again once App Attest ships in v1.0.1. The release check script blocks the unattested switch in production config, so this interim needs a conscious `deploy:beta`-style deploy: decide and tell me.

## 2. Already done in the repo
- Bundle id `com.shentech.shentarot`, version 1.0.0 (build 1), iPhone only, portrait only, iOS 15+, camera permission text, export-compliance key (HTTPS only), privacy manifest (`ios/Runner/PrivacyInfo.xcprivacy`: no tracking, purchases, user id and question text, none used for tracking), app icon and launch screen, release build compiles (no signing).
- Paywall: price, period, intro terms, Restore, Terms and Privacy links, Manage subscription in settings. Report-a-reading button. Crisis message. "Entertainment and self-reflection" line on every reading.
- No demo sign-in, no TODOs, tester mode forced off in release builds, `scripts/release-check.sh` guards production deploys.
- Store copy drafted (`docs/store-listing.md`), legal pages published, account deletion page live.

## 2b. Current state in App Store Connect (checked 2026-10-17)
- **Account:** Individual paid team `SX4CW2L35K` ("SHEN YUNLONG"); Xcode on this Mac is signed in to it. Business agreements, bank and tax status: not checked (the next page to look at is Business).
- **App record:** **ShenTarot: AI Lens**, iOS 1.0 "Prepare for Submission", bundle id `com.shentech.shentarot`, SKU `shentarot`, Apple ID `6823779463`, primary language English (U.S.). **Done 2026-10-17:** subtitle "Tarot card scanner and reader"; categories Lifestyle (primary) and Entertainment (secondary); age rating questionnaire (all "No" for features; fear themes, nudity, fantasy violence and weapons "Infrequent" because of classic card art; calculated **13+**, 12+ in Vietnam, Brazil and Korea); privacy policy URL `https://yunlong2601.github.io/shentarot-legal/privacy.html`; App Privacy answers (Other User Content: App Functionality, not linked; User ID: App Functionality, linked; Purchase History: App Functionality, linked; no tracking), **saved but not yet published**. **Not done:** Content Rights (needs the owner's declaration about the card art), the version page (description, keywords, promo text, support URL, screenshots, build), review notes and contact details, Business agreements.
- **Subscription group "Premium"** (id 22486710, display name "ShenTarot Premium"), levels set to match the plan:

| Level | Reference name | Product id | Length | Base price set | Status |
|---|---|---|---|---|---|
| 1 | Annual | `shentarot_annual` | 1 year | US$39.99 (Apple-calculated elsewhere: S$59.98, C$49.99, EUR 44.99) | Prepare for Submission |
| 2 | 3 Months | `shentarot_quarterly` | 3 months | US$14.99 (S$19.98) | Prepare for Submission |
| 3 | Monthly | `shentarot_monthly` | 1 month | US$6.99 (S$9.98) | Prepare for Submission |

- **Display names and descriptions (English U.S.): done.** Annual: "Premium Annual" ("All premium readings and features, billed yearly."); 3 Months: "Premium 3 Months" and Monthly: "Premium Monthly" (both "All spreads, follow-ups, 50 readings a day").
- **Introductory offer on Annual: done (2026-10-17).** Pay up front, 1 month, US$1.99 (UK GBP 1.99, Canada CAD 2.99, Singapore SGD 2.98), all 175 countries, starts Oct 17, 2026, no end date. An earlier draft offer at US$3.99 was deleted and replaced.
- **Still missing on every subscription:** the review screenshot of the paywall (needs the paywall to show real prices: RevenueCat or a StoreKit test run), and a look at availability and Singapore prices (Apple's S$59.98 for annual is above the US price once tax is included; adjust if you prefer).
- The annual price had been US$99.99 from an earlier attempt; it was changed to US$39.99 on 2026-10-17 with all other countries recalculated.

## 3. Steps only you can do, in order (the critical path)
1. **Apple Developer Program: status Active** (check developer.apple.com/account; if "Processing" after 3 days, contact Apple Developer Support with your Enrollment ID). Confirm the Team ID in Xcode (`SX4CW2L35K` is in the project now) is the paid team, not a free Personal Team.
2. **App Store Connect > Business:** accept the Paid Applications agreement, add your Singapore bank and tax forms (verify which). Without this, subscriptions cannot go live. Join the **Small Business Program** (15% fee).
3. **Identifiers:** App ID `com.shentech.shentarot` with the In-App Purchase capability (Xcode creates it when you sign in with the paid team and build once).
4. ~~New App~~ **Done**: record `ShenTarot: AI Lens` exists (section 2b).
5. **Subscriptions**: the group, the three products, levels and base prices are **done** (section 2b). Names, descriptions and the US$1.99 first-month introductory offer on `shentarot_annual` are done too. Still to do: a paywall review screenshot for each, and a look at availability and Singapore prices.
6. **RevenueCat** (`docs/phase-e-subscriptions-setup.md`): add the iOS app, upload the App Store Connect **In-App Purchase key** (.p8, key id, issuer id), import the three products, create entitlement `premium`, make an offering marked *current* with packages Annual, Three Month and Monthly. Copy the public iOS SDK key (starts `appl_`). Set the RevenueCat secret on the Worker (`npx wrangler secret put REVENUECAT_SECRET_KEY`) and, for v1.1 features, the webhook.
7. **Backend for production:** Anthropic monthly spend limit; secrets set; remove `TESTER_INSTALL_IDS`; raise `GLOBAL_DAILY_TOKEN_CAP` for launch traffic; apply migrations (`npx wrangler d1 migrations apply shentarot --remote`; they only add tables for v1.1, safe to apply); `bash scripts/release-check.sh`; then deploy and run `backend/scripts/smoke.sh` against the live URL. Decide device checks (section 1).
8. **Build and upload** (on this Mac, after step 6):
   ```bash
   cd app
   flutter build ipa --release --dart-define-from-file=config/live.json --dart-define=REVENUECAT_IOS_KEY=appl_YOURKEY
   ```
   then upload `build/ios/ipa/*.ipa` with Xcode Organizer or the Transporter app. Raise the build number (`version: 1.0.0+2` in `pubspec.yaml`) for every re-upload. I can run this once the key and paid team exist.
9. **TestFlight:** install on a real iPhone. Check: camera scan, a real reading, the daily reminder, a sandbox purchase of each plan, Restore on a second device, cancel. Ask 2 or 3 friends to try it (internal testers need no review).
10. **App Store Connect > the version page:** fill in the fields in section 4, add screenshots (section 5), pick the TestFlight build, set pricing and availability, answer the age rating and privacy questionnaires, add the review notes, then **Add for Review** and **Submit**. Review usually takes 1 to 2 days (verify); first submissions of subscription apps are reviewed together with the subscriptions.

## 4. Fields to paste into App Store Connect
- **Name:** ShenTarot: AI Lens. **Subtitle:** Tarot card scanner and reader.
- **Promotional text:** Hold a card up to your camera and find out what it means for the question on your mind.
- **Keywords (100 characters, no spaces after commas):** reading,meanings,interpretation,spread,journal,daily,deck,reflection,oracle,cards,celtic,cross
- **Description:** from `docs/store-listing.md` (v1 wording: free = 1 reading a day on 1 to 3-card spreads and one try of a longer spread; Premium = all spreads, up to 50 readings a day, follow-ups, clarifier, look-back).
- **Category:** Lifestyle (primary), Entertainment (secondary). **Copyright:** 2026 ShenTech.
- **Support URL:** https://yunlong2601.github.io/shentarot-legal/ **Privacy Policy URL:** https://yunlong2601.github.io/shentarot-legal/privacy.html **Terms:** use Apple's standard EULA, or https://yunlong2601.github.io/shentarot-legal/terms.html in the app description.
- **Content rights:** the app contains third-party content: yes, public-domain 1909 card scans (`app/assets/cards/art/CREDITS.md`); you have the rights to use it.
- **Export compliance:** uses only standard HTTPS encryption, exempt (already declared in Info.plist; verify the questions).
- **Age rating questionnaire:** answer honestly. Content is astrology and fortune-telling, AI-generated text, no violence, no gambling, no user chat or user-generated content, no web browsing. Expect a low rating, but accept whatever the questionnaire produces (verify the current questions).
- **App Privacy** (matches `ios/Runner/PrivacyInfo.xcprivacy` and `docs/data-inventory.md`): Purchases (purchase history, linked to a random id, app functionality); Identifiers (random app-generated user id, linked, app functionality); User Content (optional question and "look first" text sent to the AI to write the reading, not linked, app functionality). **Tracking: No.** No camera data collected (processed on the device only). If Apple asks about the AI provider: the text goes to Anthropic (and OpenAI as a fallback) through our server.
- **Review notes (paste):**
  > ShenTarot identifies a physical Rider-Waite-Smith tarot card with the camera (recognition runs on the device) and shows an AI-written reflection. It is for entertainment and self-reflection and says so on every reading. No login is needed. To test without a deck: open Read, tap the swap icon beside "Photo reading" to switch to "Digital reading", ask a question, pick a spread, and tap cards to flip them. Readings come from our server, which is live. Premium can be tested with a sandbox account: tap You > Go Premium. Restore Purchases and Manage Subscription are on the Premium screen and in You. The app includes a Report button on every AI reading and shows a fixed support message with hotline information if a question suggests crisis. Contact: shenyunlongbusiness@gmail.com.

## 5. Screenshots (verify the required sizes)
Required: 6.9-inch iPhone (1320 x 2868). Use the iPhone 18 Pro Max simulator. iPhone only (iPad is switched off). Suggested order, leading with the scan: (1) Read home "Hold the cards. We explain them." (2) Which card is it? (3) a reading (4) library with meanings (5) a 3-card spread (6) history and journal. Add a short caption on each. Only the public-domain art in the app.

## 6. Review risks and answers
- **4.3 spam / saturated category:** lead with the physical-card scan and the beginner explanation; the review notes above say so.
- **3.1.2 subscriptions:** terms next to the button, Restore, Manage; all present.
- **1.1 / 5.1 content and safety:** disclaimer on every reading, report button, crisis message, no medical, legal, financial or death predictions.
- **Camera:** purpose string present; photos not stored or uploaded.
- **Accounts:** v1 has none, so Sign in with Apple and in-app account deletion are not triggered. If accounts are turned on later, both are required.
- **Server must be live and fast during review.** Check the live URL and your Anthropic balance the day you submit.

## 7. After approval
Release manually the same day, watch the token cap and Anthropic spend, then ship v1.0.1 (App Attest, privacy text) and v1.1 (credits, referrals, creator program, packs).
