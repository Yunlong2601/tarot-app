# Phase E: subscriptions setup (iOS first)

The app code is done (`app/lib/core/subscription_service.dart`, paywall, settings). It sells nothing until you create the products and keys below. Store rules and menu names change: verify each step in the current Apple, Google and RevenueCat docs.

## What the code expects
- RevenueCat entitlement id: `premium`.
- One **current offering** with packages of type **Annual**, **Three Month**, **Monthly** (no weekly) (use RevenueCat's standard package types so the paywall can label them).
- Annual product has a paid introductory offer: **US$1.99 for the first month** (Apple: introductory offer "Pay up front", 1 month, $1.99; new subscribers only). No free trial. The paywall reads the offer from the store product, never hardcoded.
- Plan description in both stores (all three plans): "All spreads, follow-ups, 50 readings a day".
- Prices come from the store (localised). Set base prices in App Store Connect (plan: annual $39.99 with $1.99 for the first month, 3 months $14.99, monthly $6.99 USD; weekly is not offered).
- The RevenueCat **app user ID** is the anonymous install ID (stored on device), and the backend looks up the same ID via the RevenueCat REST API to decide whether a request is premium. No accounts.

## I need to do (owner), iOS
1. Apple Developer Program membership; real **bundle ID** (replace `com.shentech.shentarot` in Xcode; Runner target > Signing & Capabilities; also the RunnerTests ids).
2. In App Store Connect create the app, a **subscription group**, and three auto-renewing subscriptions (annual at level 1, 3 months at level 2, monthly at level 3; annual with a 7-day free-trial introductory offer). Accept the Paid Applications agreement and fill tax/banking.
3. In Xcode add the **In-App Purchase** capability to the Runner target.
4. Create a RevenueCat project and an **iOS app**, add the **App Store Connect API key / In-App Purchase key** RevenueCat asks for, import the three products, create entitlement `premium` attached to all three, create an offering marked **current** with Annual, Three Month and Monthly packages (no weekly).
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
- Intro offers: price 0 shows as "N days free", any other price as "$X for your first month". Check in sandbox that the Pay up front offer appears as expected.
- Restore needs a real sandbox account to confirm.

## Test purchases on the Mac without App Store Connect (StoreKit file)
`app/ios/ShenTarot.storekit` defines the three subscriptions locally: product ids `shentarot_annual` (US$39.99, intro offer $1.99 for the first month, pay up front, group level 1), `shentarot_quarterly` (US$14.99, every 3 months, level 2) and `shentarot_monthly` (US$6.99, level 3). Use the same product ids when you create the products in App Store Connect.

To use it in Xcode: open `app/ios/Runner.xcworkspace`, Product > Scheme > Edit Scheme > Run > Options > StoreKit Configuration > choose `ShenTarot.storekit`. Run on the simulator or your own iPhone. Xcode's Debug > StoreKit > Manage Transactions lets you approve, fail, expire or refund purchases.

Limits (not verified): the app reads plans through RevenueCat, so you still need a RevenueCat project whose products use these ids and an offering marked current; RevenueCat then loads prices from the local StoreKit file in this test mode (confirm in RevenueCat's StoreKit testing guide). Prices in the file are placeholders; real prices are set in App Store Connect.
