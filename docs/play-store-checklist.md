# Google Play release checklist

Verify every item in Play Console Help and the Policy Center (Subscriptions, Data safety, Families, User Data, Payments) before relying on it. iOS is being done first; this starts after.

## Account and testing requirement
- [ ] Play Console developer account ($25 one-off, already paid). Individual accounts may need identity verification.
- [ ] **Closed testing requirement for new personal accounts** (a minimum number of testers for a minimum number of days before production access): confirm the current numbers in Play Console help and recruit testers early; this sets the timeline.
- [ ] Payments profile and Singapore tax/bank details (verify).

## Project
- [ ] Application ID (replace `com.example.veilscan`), name, version code, upload key and Play App Signing.
- [ ] Android SDK installed (Android Studio); release `appbundle` builds: `flutter build appbundle --dart-define=...`. Not tried yet.
- [ ] Camera permission declared (done); runtime request works on a real phone; notification permission (Android 13+) handled by the reminder switch.
- [ ] `tflite_flutter` and `camera` verified on a real Android device. Not verified.
- [ ] Adaptive icon and feature graphic (original art).

## Subscriptions
- [ ] Create the three subscriptions (base plans weekly, monthly, annual with a 7-day free-trial offer) in Play Console and link them in RevenueCat; use the Android public key (`REVENUECAT_ANDROID_KEY`).
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
