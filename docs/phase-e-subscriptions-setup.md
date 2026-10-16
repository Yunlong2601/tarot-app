# Phase E: subscriptions setup (iOS first)

The app code is done (`app/lib/core/subscription_service.dart`, paywall, settings). It sells nothing until you create the products and keys below. Store rules and menu names change: verify each step in the current Apple, Google and RevenueCat docs.

## What the code expects
- RevenueCat entitlement id: `premium`.
- One **current offering** with packages of type **Annual**, **Monthly**, **Weekly** (use RevenueCat's standard package types so the paywall can label them).
- Annual product has a **7-day free trial** introductory offer; the paywall reads the trial from the store product, never hardcoded.
- Prices come from the store (localised). Set base prices in App Store Connect (plan: weekly $3.99, monthly $7.99, annual $39.99 USD, to re-set per storefront).
- The RevenueCat **app user ID** is the anonymous install ID (stored on device), and the backend looks up the same ID via the RevenueCat REST API to decide whether a request is premium. No accounts.

## I need to do (owner), iOS
1. Apple Developer Program membership; real **bundle ID** (replace `com.example.shentarot` in Xcode; Runner target > Signing & Capabilities; also the RunnerTests ids).
2. In App Store Connect create the app, a **subscription group**, and three auto-renewing subscriptions (weekly, monthly, annual with a 7-day free-trial introductory offer). Accept the Paid Applications agreement and fill tax/banking.
3. In Xcode add the **In-App Purchase** capability to the Runner target.
4. Create a RevenueCat project and an **iOS app**, add the **App Store Connect API key / In-App Purchase key** RevenueCat asks for, import the three products, create entitlement `premium` attached to all three, create an offering marked **current** with Annual/Monthly/Weekly packages.
5. Copy the iOS **public SDK key** (starts with `appl_`) and a **secret API key** (v1 REST, for the backend).
6. Backend: `npx wrangler secret put REVENUECAT_SECRET_KEY`.
7. Run the app with the keys:
   ```bash
   cd app
   flutter run --dart-define=API_BASE_URL=https://<your-worker> \
               --dart-define=REVENUECAT_IOS_KEY=appl_xxx
   ```
   Keys passed with `--dart-define` are baked into the build. The RevenueCat public SDK key is designed to ship in the app; **never** put the secret key or any LLM key in the app.
8. Test with a **sandbox tester** (App Store Connect > Users and Access > Sandbox). Check: purchase, trial, restore on a second install, and cancel via Settings > Manage subscription.

## Android (later)
Create the Play Console subscriptions, a RevenueCat Android app and pass `REVENUECAT_ANDROID_KEY`. Same entitlement and offering.

## Not verified
- Never run against RevenueCat or the stores: only unit/widget tests with a fake service, and a successful iOS simulator build.
- Intro-offer detection assumes a free-trial intro price of 0; check how a "pay as you go" or "pay up front" offer appears.
- Restore needs a real sandbox account to confirm.
