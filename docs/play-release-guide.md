# Google Play release guide (ShenTarot)

Developer account owner: yunlong2601@gmail.com (private; do not publish). Store policies and console menus change: verify each item against Play Console Help and the Policy Center before relying on it. Nothing here has been done in Play Console yet.

## Already done in the repo
- Application ID: `com.shentech.shentarot` (permanent once published; `com.example.*` is not allowed). Change it before the first upload if you want another one: `app/android/app/build.gradle.kts` (namespace, applicationId) and the folder/package of `MainActivity.kt`.
- **Upload key** created on the owner's Mac: `~/shentarot-keys/upload-keystore.jks` plus `key.properties` (passwords inside). `app/android/key.properties` is a symlink to it and is git-ignored. **Back up the whole `~/shentarot-keys` folder somewhere safe (not in the repo).** With Play App Signing, a lost upload key can be reset through Play support, but it is slow and painful.
- Release build is signed with that key, shrunk (R8) with keep rules for TensorFlow Lite (`app/android/app/proguard-rules.pro`). Command: `cd app && flutter build appbundle --release --dart-define-from-file=config/live.json --dart-define=QONVERSION_PROJECT_KEY=...` -> `build/app/outputs/bundle/release/app-release.aab`.
- Permissions are minimal: CAMERA, INTERNET, ACCESS_NETWORK_STATE, VIBRATE (reminders), POST_NOTIFICATIONS, BILLING. Libraries also tried to add RECORD_AUDIO, READ_PHONE_STATE and storage permissions; those are removed in `AndroidManifest.xml`. `allowBackup` is off, so history stays on the phone (matches the privacy policy).
- Target SDK 36, min SDK 24. Google requires new apps and updates to target API 36 from 31 Aug 2026 (developer.android.com/google/play/requirements/target-sdk, read 2026-10-16): **met**.
- Play Billing Library: the app now uses the Qonversion SDK (`qonversion_flutter` 11.12.0, since 2026-10-17) instead of RevenueCat. Google requires Billing Library 8 or later from 31 Aug 2026 (developer.android.com/google/play/billing/deprecation-faq, read 2026-10-16). Qonversion pulls in `com.android.billingclient:billing:8.1.0` (checked with `./gradlew :app:dependencies` in `app/android`, 2026-10-17): **met**.
- 16 KB page size: every arm64 native library in the release APK (Flutter, TensorFlow Lite, CameraX, datastore, jni) has LOAD alignment 2**14 or 2**16, and `zipalign -c -P 16 4` passes. Google requires 16 KB support for apps targeting 35+ and blocks non-compliant updates from 1 Feb 2027 (developer.android.com/guide/practices/page-sizes): **met**.
- Advertising ID: none. `com.google.android.gms.permission.AD_ID` is explicitly removed; answer **No** in the Play Console declaration.
- Version: `1.0.0+1` (versionName 1.0.0, versionCode 1) in `app/pubspec.yaml`. Raise the number after `+` for every upload.
- Final bundle (2026-10-17): `app/build/app/outputs/bundle/release/app-release.aab`, about 87 MB, signed by CN=ShenTech (upload key), pointed at the live server via `config/live.json`. Rebuild with the Qonversion project key once it exists.
- AI content reporting: each reading has a flag button that opens a pre-filled email report (Play expects an in-app way to report offensive AI-generated content; verify the current wording of the AI-Generated Content policy).
- Privacy policy URL: https://yunlong2601.github.io/shentarot-legal/privacy.html

## Verified on an Android emulator (2026-10-17, signed release build, live server)
Onboarding, Read, Ask, spread picker, Photo reading, manual card picker with orientation, Look first (shows reversed cards), a real AI reading from the live server laid out card by card, Premium buttons opening the paywall, Privacy Policy and Terms from the paywall, You tab (no demo Sign in, no own-key row), Reading History. Fixed during the pass: the paywall promised "Unlimited readings" (the server allows Premium 20 a day), renewal text named both stores, Back after a reading walked back through the question screens, history dates were day/month. Not verified: follow-up, clarifier and journal against the live server (they need Premium, which needs RevenueCat), purchases, notifications, a real card scan.

### Clean screenshots
The emulator status bar shows a notification icon. Turn on Android's demo mode before taking screenshots (clean clock, full battery, no icons):
```bash
adb shell settings put global sysui_demo_allowed 1
```
```bash
adb shell am broadcast -a com.android.systemui.demo -e command enter
```
```bash
adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941
```
```bash
adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
```
Exit with `-e command exit`. Take screenshots with `adb exec-out screencap -p > shot.png`.

## Earlier emulator check (2026-10-16)
The signed release build (R8 shrinking on) was installed on an Android 35 emulator and driven through onboarding, Read, Ask, spread picker, Photo reading, the camera screen, a scan (photo captured, model run, "not sure" sheet shown), Card of the Day, Library and Guide: no crash, TensorFlow Lite initialised. Not verified: scanning a real card on a real phone, notifications, purchases, the reminder, Play billing, and a real backend reading. The emulator camera shows only a cartoon scene.
Drive it yourself: `~/development/android-sdk/emulator/emulator -avd shentarot_pixel` then `adb install -r app/build/app/outputs/flutter-apk/app-release.apk`.

## What only you can do
0. Before any store build or production deploy, run `bash scripts/release-check.sh` from the repo root (it also runs before `npm run deploy`). It fails if a beta-only switch (`ALLOW_UNATTESTED_INSTALLS`, `TESTER_INSTALL_IDS`) is in the production config, or if tester mode is not forced off in release builds.
1. **Play Console identity checks** for your account (individual vs organisation; verify what is required for a Singapore individual).
2. **Closed-testing requirement for new personal accounts**: Google has required a minimum number of testers opted in for a minimum number of days before you can apply for production. Check the current numbers (it has been 12 testers for 14 days) in Play Console Help; recruit testers now (classmates, friends with Android phones).
3. **Backend**: done and live (test mode, installs allowed without attestation, cap 500,000 tokens a day). Play Integrity is not implemented yet; it can be added once the app exists in Play Console (it needs the app's Google Cloud project link). Keep test mode only for the closed test.
4. **Qonversion + Play subscriptions** (the app reads plans by Qonversion product id, so the ids must match exactly):
   - Play Console > Monetize > Subscriptions: create three subscription products: `shentarot_annual` (base plan `annual`, 1 year, US$39.99, plus an introductory offer `first-month`: one single-payment phase of 1 month at US$1.99, eligibility **"never had any subscription in this app"**; no free trial), `shentarot_quarterly` (base plan `quarterly`, 3 months, US$14.99, no trial) and `shentarot_monthly` (base plan `monthly`, 1 month, US$6.99, no trial). No weekly product.
   - Qonversion: add the Android app (package `com.shentech.shentarot`) to the same project, upload the Play service-account credentials and turn on Real-time developer notifications, then link products `shentarot_annual`, `shentarot_quarterly` and `shentarot_monthly` to the Play products (base plans) and attach all three to the entitlement **`premium`**.
   - The same Qonversion **Project Key** works for iOS and Android. Set the Qonversion secret on the backend (`npx wrangler secret put QONVERSION_SECRET_KEY`). Then I rebuild the bundle with the key.
5. **Business setup**: payments profile, tax and payout details (Singapore; verify), a support email for the listing.
6. **Assets** (Play Console): ready in `store/play/`: `icon-512.png`, `feature-graphic.png` (1024x500, no text), and 4 phone screenshots in `store/play/screenshots/` taken from the emulator build (landing, Card of the Day, Library, Guide). Google wants 2 to 8; check the current size rules. Retake them later with the final art and a real reading.

## Create the app in Play Console (order)
1. All apps > Create app: name **ShenTarot: AI Lens** (30 character limit; 18 used), English (US), App, Free (with in-app subscriptions).
2. Set up your app > fill every section:
   - **App access**: no login needed; all features reachable. Reviewer note: free reading daily; for Premium use a license tester account; the camera scan can be skipped via "Can't scan? Pick a card manually".
   - **Ads**: no ads.
   - **Content rating**: questionnaire (see below).
   - **Target audience**: 13+ (select 13-15, 16-17, 18+; not children). Not designed for children, so the Families policy does not apply.
   - **Data safety**: use `docs/play-data-safety.md`.
   - **Government / financial / health apps**: none. Health: no (add nothing; the app is for entertainment and reflection).
   - **Advertising ID**: not used. (Verify that no library requires the AD_ID permission; the current release manifest does not list it.)
   - **News app**: no. **Data deletion URL**: optional; the support page `https://yunlong2601.github.io/shentarot-legal/`.
3. Store listing: copy from `docs/store-listing.md` (Google Play section). Category: Lifestyle (or Entertainment: decide). Contact email: a public support address of your choice; website: the legal site.
4. Testing > Internal testing: upload the signed AAB, add yourself as a tester, install from the Play link and test the real billing and the camera. Then Closed testing with your recruited testers. Only then Production.
5. Monetization > Subscriptions: create the three products (see above) and set prices (US$39.99 / 14.99 / 6.99; Play can convert to local currencies).

## Content rating answers (draft, verify in the questionnaire)
Category: utility/reference or "other" (not a game). Violence, sexuality, language, controlled substances: none. User-generated content that other users see: no. Shares location: no. Digital purchases: yes. Gambling: no. Astrology/fortune telling content: answer honestly if asked (the app interprets tarot cards for entertainment). Expect a Teen (12+/13+) type rating; check the result matches the 13+ audience.

## Versioning and updates
`pubspec.yaml` `version: 1.0.0+1` : the number after `+` is the Android versionCode and must increase with every upload (`1.0.0+2`, ...). Use the same app signing key forever (Play App Signing holds the real one; you keep the upload key).

## Test a release build before uploading
`flutter build apk --release`, then `adb install`. R8 shrinking can break plugins only in release; test the camera, the card model, history and notifications on a real Android phone (see `docs/test-plan.md`).
