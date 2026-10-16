# Google Play release guide (ShenTarot)

Developer account owner: yunlong2601@gmail.com (private; do not publish). Store policies and console menus change: verify each item against Play Console Help and the Policy Center before relying on it. Nothing here has been done in Play Console yet.

## Already done in the repo
- Application ID: `com.shentech.shentarot` (permanent once published; `com.example.*` is not allowed). Change it before the first upload if you want another one: `app/android/app/build.gradle.kts` (namespace, applicationId) and the folder/package of `MainActivity.kt`.
- **Upload key** created on the owner's Mac: `~/shentarot-keys/upload-keystore.jks` plus `key.properties` (passwords inside). `app/android/key.properties` is a symlink to it and is git-ignored. **Back up the whole `~/shentarot-keys` folder somewhere safe (not in the repo).** With Play App Signing, a lost upload key can be reset through Play support, but it is slow and painful.
- Release build is signed with that key, shrunk (R8) with keep rules for TensorFlow Lite (`app/android/app/proguard-rules.pro`). Command: `cd app && flutter build appbundle --release --dart-define-from-file=config/live.json --dart-define=REVENUECAT_ANDROID_KEY=goog_...` -> `build/app/outputs/bundle/release/app-release.aab`.
- Permissions are minimal: CAMERA, INTERNET, ACCESS_NETWORK_STATE, VIBRATE (reminders), POST_NOTIFICATIONS, BILLING. Libraries also tried to add RECORD_AUDIO, READ_PHONE_STATE and storage permissions; those are removed in `AndroidManifest.xml`. `allowBackup` is off, so history stays on the phone (matches the privacy policy).
- Target SDK 36, min SDK 24 (Flutter 3.47 defaults; check Play's current minimum target level before upload).
- AI content reporting: each reading has a flag button that opens a pre-filled email report (Play expects an in-app way to report offensive AI-generated content; verify the current wording of the AI-Generated Content policy).
- Privacy policy URL: https://yunlong2601.github.io/shentarot-legal/privacy.html

## Verified on an Android emulator (2026-10-16)
The signed release build (R8 shrinking on) was installed on an Android 35 emulator and driven through onboarding, Read, Ask, spread picker, Photo reading, the camera screen, a scan (photo captured, model run, "not sure" sheet shown), Card of the Day, Library and Guide: no crash, TensorFlow Lite initialised. Not verified: scanning a real card on a real phone, notifications, purchases, the reminder, Play billing, and a real backend reading. The emulator camera shows only a cartoon scene.
Drive it yourself: `~/development/android-sdk/emulator/emulator -avd shentarot_pixel` then `adb install -r app/build/app/outputs/flutter-apk/app-release.apk`.

## What only you can do
1. **Play Console identity checks** for your account (individual vs organisation; verify what is required for a Singapore individual).
2. **Closed-testing requirement for new personal accounts**: Google has required a minimum number of testers opted in for a minimum number of days before you can apply for production. Check the current numbers (it has been 12 testers for 14 days) in Play Console Help; recruit testers now (classmates, friends with Android phones).
3. **Deploy the backend** (`backend/README.md`) and decide on attestation: the app needs `API_BASE_URL`. Play Integrity is not implemented; for a closed test you may set `ALLOW_UNATTESTED_INSTALLS=true` with a low Anthropic spend limit and `GLOBAL_DAILY_TOKEN_CAP` (never in production). Remove it before the public release.
4. **RevenueCat + Play subscriptions**: create the three subscriptions in Play Console with ids `shentarot_weekly`, `shentarot_monthly`, `shentarot_annual` (base plans; a 7-day free-trial offer on annual), link Play to RevenueCat (service credentials), create the Android app and give me the public `goog_` key.
5. **Business setup**: payments profile, tax and payout details (Singapore; verify), a support email for the listing.
6. **Assets** (Play Console): ready in `store/play/`: `icon-512.png`, `feature-graphic.png` (1024x500, no text), and 4 phone screenshots in `store/play/screenshots/` taken from the emulator build (landing, Card of the Day, Library, Guide). Google wants 2 to 8; check the current size rules. Retake them later with the final art and a real reading.

## Create the app in Play Console (order)
1. All apps > Create app: name **ShenTarot: AI Scan & Read** (30 character limit; verify), English (US), App, Free (with in-app subscriptions).
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
5. Monetization > Subscriptions: create the three products (see above) and set prices (US$3.99 / 7.99 / 39.99; Play can convert to local currencies).

## Content rating answers (draft, verify in the questionnaire)
Category: utility/reference or "other" (not a game). Violence, sexuality, language, controlled substances: none. User-generated content that other users see: no. Shares location: no. Digital purchases: yes. Gambling: no. Astrology/fortune telling content: answer honestly if asked (the app interprets tarot cards for entertainment). Expect a Teen (12+/13+) type rating; check the result matches the 13+ audience.

## Versioning and updates
`pubspec.yaml` `version: 1.0.0+1` : the number after `+` is the Android versionCode and must increase with every upload (`1.0.0+2`, ...). Use the same app signing key forever (Play App Signing holds the real one; you keep the upload key).

## Test a release build before uploading
`flutter build apk --release`, then `adb install`. R8 shrinking can break plugins only in release; test the camera, the card model, history and notifications on a real Android phone (see `docs/test-plan.md`).
