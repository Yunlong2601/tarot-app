# Google Play release checklist

> **Provider change (2026-10-17):** subscriptions move from RevenueCat to **Qonversion** (owner decision; the app and backend code migration is in progress). RevenueCat steps, keys and webhooks below are on hold: do not create a RevenueCat project. This doc is rewritten for Qonversion once the code lands.

Start with `docs/play-release-guide.md` (what is done, what only the owner can do, console order) and `docs/play-data-safety.md`. This file is the shorter checklist.

Verify every item in Play Console Help and the Policy Center (Subscriptions, Data safety, Families, User Data, Payments) before relying on it. iOS is being done first; this starts after.

## Account and testing requirement
- [ ] Play Console developer account ($25 one-off, already paid). Individual accounts may need identity verification.
- [ ] **Closed testing requirement for new personal accounts** (a minimum number of testers for a minimum number of days before production access): confirm the current numbers in Play Console help and recruit testers early; this sets the timeline.
- [ ] Payments profile and Singapore tax/bank details (verify).

## Project
- [ ] Application ID (replace `com.shentech.shentarot`), name, version code, upload key and Play App Signing.
- [x] Android toolchain on the Mac (JDK 17 in `~/development/jdk`, SDK in `~/development/android-sdk`, both in `~/.zshrc`). `flutter build apk --debug` and `flutter build appbundle --release` both succeed (2026-10-16; the release bundle is 85.8 MB before Play's per-device splitting and is signed with the DEBUG key, so it cannot be uploaded). Two fixes were needed: core library desugaring (for `flutter_local_notifications`) and `kotlin.jvm.target.validation.mode=warning` (for `tflite_flutter`'s Java/Kotlin target mismatch).
- [ ] Create an **upload key** (`keytool -genkey ...`), keep it and its passwords outside the repo (back them up: losing it is painful), add a `key.properties` + release `signingConfig` in `app/android/app/build.gradle.kts`, rebuild, then enrol in Play App Signing.
- [ ] Check R8/minify on a real device: release builds shrink code, and `tflite_flutter` / `camera` / `sqflite` have not been run on a phone. If recognition or storage fails only in release, add keep rules.
- [ ] Run on an Android emulator or phone (no emulator image is installed yet; `flutter run` on a USB phone with debugging on is the quickest).
- [ ] Camera permission declared (done); runtime request works on a real phone; notification permission (Android 13+) handled by the reminder switch.
- [ ] `tflite_flutter` and `camera` verified on a real Android device. Not verified.
- [ ] Adaptive icon and feature graphic (original art).

## Subscriptions
- [ ] Create the three subscriptions (base plans monthly US$6.99, 3 months US$14.99, annual US$39.99 with a US$1.99 first-month offer; no weekly, no free trial) in Play Console and link them in RevenueCat; use the Android public key (`REVENUECAT_ANDROID_KEY`).
- [ ] Billing fees: the plan assumes about 15% total; the fee schedule changed in 2026, so re-check support.google.com/googleplay/android-developer (service fees).
- [ ] Cancel/manage link works (Settings > Manage subscription opens the Play subscriptions page).
- [ ] License testers added; test purchase, trial, restore, cancel.

## Policy forms
- [ ] **Data safety** form matches `docs/data-inventory.md` (data shared with service providers; no data sold; no ads; encrypted in transit; users can delete on-device data in the app). Verify the current wording of each question.
- [ ] Privacy policy URL on the store listing and in the app.
- [ ] Content rating questionnaire; target audience (not directed at children: verify implications).
- [ ] Declarations: ads (none), app access (provide test instructions as for Apple), financial features (none), health (none; keep the disclaimer).
- [ ] Contact details shown on the listing (some account types must show an address: verify "trader status").

## Before submit
- [ ] Same quality gates as the iOS checklist (tests, audit, backend deployed, attestation via Play Integrity implemented, no dev flags).
