# App Store (iOS) release checklist

Rules and menu names change. Items marked (verify) must be checked against the current Apple pages before you rely on them: App Review Guidelines (developer.apple.com/app-store/review/guidelines), App Store Connect Help, and the Program License Agreement.

## Accounts and agreements
- [ ] Apple Developer Program enrolled (individual vs organisation: see the addendum in `step1-plan.md`).
- [ ] Paid Applications agreement accepted; Singapore bank and tax forms done in App Store Connect (verify the forms you need).
- [ ] Small Business Program application (verify eligibility and the fee rate).

## Project
- [ ] Real **bundle ID** (replace `com.shentech.shentarot` everywhere, including RunnerTests) and a final **app name** (check trademarks and App Store name availability; do not use "Rider-Waite" in the name, icon or keywords).
- [x] **App icon** (1024x1024, no transparency, original art) and launch screen: done (see PROGRESS.md). Check how they look on a device.
- [x] Version 1.0.0 (build 1), iPhone only, portrait only, privacy manifest, purpose strings (camera, photo library, microphone), export-compliance key: done 2026-10-17; a release build compiles without signing. [ ] Signing with your paid team and the **In-App Purchase** capability: yours (guide step 3).
- [ ] Release build runs on a **real iPhone** (camera, notifications, purchases). Not verified yet.
- [x] `NSCameraUsageDescription` present ("Used to recognise the tarot card you hold up. Photos are never saved or uploaded."). Done.
- [ ] No secrets in the app; `API_BASE_URL` and the Qonversion **public** key passed with `--dart-define` at build time.
- [ ] Legal texts are filled in (provider ShenTech, no lawyer review: owner decision); re-read them before each release.

## Subscriptions (guideline 3.1.2: verify)
- [ ] Three auto-renewing subscriptions in one group (annual US$39.99 with a US$1.99 first-month introductory offer, 3 months US$14.99, monthly US$6.99; no weekly, no free trial), localised names and descriptions, review screenshot for each. Step by step: `docs/app-store-submission-guide.md`.
- [ ] Paywall shows price, billing period, trial length and auto-renew terms next to the buy button, with **Privacy Policy** and **Terms of Use** links and **Restore Purchases**. Implemented; confirm on a device.
- [ ] Settings has **Manage subscription**. Implemented.
- [ ] Privacy Policy URL and (if not using Apple's standard EULA) Terms URL entered in App Store Connect and in the app metadata.
- [ ] Sandbox test: buy, trial, restore on a second device, cancel.

## Privacy
- [ ] App Privacy ("nutrition label") answers match `docs/data-inventory.md`. Proposed mapping (verify against Apple's current definitions):
  - Data **collected**: Purchases (via the store/Qonversion), Identifiers (app-generated anonymous ID), User Content (optional question text, sent to generate the reading), Usage/Diagnostics only if you add analytics.
  - Tracking: **No**. No ads, no cross-app tracking, so no App Tracking Transparency prompt.
  - Camera: processed on device only, not collected.
- [ ] Age rating questionnaire answered honestly (astrology/fortune-telling content, AI-generated text; verify the current questions).
- [ ] Export compliance: the app uses HTTPS only (verify the encryption questions).
- [ ] If you ever add accounts, account deletion inside the app is required (verify). Not needed now.

## Review risk: guideline 4.3 "spam / saturated category" (verify)
Tarot and astrology apps are a crowded category. Lead the screenshots, subtitle and review notes with the **physical-card scan**, which is less common than plain digital draws (Taroter, Thoth Tarot School and others also scan, so pair it with the interpretation angle: "you hold the cards, the app explains them"). Draft review notes:

> ShenTarot identifies a physical Rider-Waite-Smith tarot card with the camera (on-device recognition) and shows an AI-written reflection. It is for entertainment and self-reflection and says so on every reading. To test without a deck: open Scan, tap "Can't scan? Pick a card manually", choose any card and orientation, then the reading appears. Printable card images to scan are at [URL]. To see Premium: use the sandbox account [EMAIL] (password in the Notes field). Subscriptions: weekly, monthly, annual (7-day free trial); Restore Purchases and Manage Subscription are in Settings. No account is required. A demo video is at [URL].

- [ ] Demo video, printable card images, and a working backend URL (deploy first; the reviewer's readings need the server to be live).
- [ ] Content: no medical/legal/financial/death predictions (enforced in the system prompt; keep the disclaimer visible).

## Store listing
- [ ] Screenshots (required device sizes: verify), description, keywords, support URL, marketing URL (optional), copyright, category (Lifestyle or Entertainment: decide), promotional text.
- [ ] Support email and a monitored inbox for review questions.

## Before pressing submit
- [ ] `flutter analyze` and `flutter test` pass; `cd backend && npm test && npm audit --omit=dev` pass.
- [ ] Backend deployed, secrets set, spend limit set in the Anthropic console, global daily token cap set.
- [ ] Device attestation implemented in `POST /v1/install` and the dev flag `ALLOW_UNATTESTED_INSTALLS` is **not** set in production.
- [ ] TestFlight build tested by a few people.
