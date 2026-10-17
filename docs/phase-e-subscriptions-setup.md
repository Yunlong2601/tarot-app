# Phase E: subscriptions setup (iOS first)

The app code is done (`app/lib/core/subscription_service.dart`, paywall, settings). It sells nothing until you create the products and keys below. Store rules and menu names change: verify each step in the current Apple, Google and Qonversion docs.

Subscription service: **Qonversion** (owner decision 2026-10-17, replacing RevenueCat before launch, with no subscribers to migrate). Pricing read on qonversion.io/pricing that day: free up to US$7,000 monthly tracked revenue, then 0.8% of all tracked revenue, with every feature (webhooks included).

## What the code expects
- Qonversion entitlement id: `premium`, attached to all three products.
- Qonversion products with exactly these ids, each linked to the App Store / Google Play product of the same id: `shentarot_annual`, `shentarot_quarterly`, `shentarot_monthly` (no weekly). The app reads them with `products()`, not offerings, and labels them by id. Credit packs (v1.1) use the ids in `app/lib/core/credit_service.dart`.
- Annual product has a paid introductory offer: **US$1.99 for the first month** (Apple: introductory offer "Pay up front", 1 month, $1.99; new subscribers only). No free trial. The paywall reads the offer from the store product, never hardcoded.
- Plan description in both stores (all three plans): "All spreads, follow-ups, 50 readings a day".
- Prices come from the store (localised). Base prices in App Store Connect: annual $39.99 with $1.99 for the first month, 3 months $14.99, monthly $6.99 USD; weekly is not offered.
- The app calls `identify(id)` with the anonymous install ID (or the account ID when signed in). The backend asks the Qonversion REST API v4 for the user behind that identity (`GET /v4/identities/{id}`, then `GET /v4/users/{user_id}/entitlements`) to decide whether a request is premium. It fails closed.
- Free months (referral and creator rewards, v1.1) are manual grants: `POST /v4/users/{user_id}/entitlements` with `premium` for 30 days.

## I need to do (owner), iOS
1. Apple Developer Program membership and the **In-App Purchase** capability on the Runner target (bundle id `com.shentech.shentarot`).
2. App Store Connect subscriptions: **done** (group "Premium", three products, prices, intro offer; see `docs/app-store-submission-guide.md` section 2b). Accept the Paid Applications agreement and fill tax/banking.
3. Qonversion account and project "ShenTarot": **created 2026-10-17**. Still to do in Settings > App Store: the **shared secret** (required for purchase validation; App Store Connect > App Information > App-Specific Shared Secret), then bundle id, the App Store Connect **In-App Purchase key** (.p8, key id, issuer id) and the app-specific shared secret if it asks, and turn on **Apple server notifications** (App Store Server Notifications V2, URL from Qonversion, set in App Store Connect > App Information).
4. **Done 2026-10-17** (project "ShenTarot"): entitlement `premium`; products `shentarot_annual` (Subscription With Promo Period, Annual), `shentarot_quarterly` (Regular Subscription, 3-month) and `shentarot_monthly` (Regular Subscription, Month), each with the same App Store product id and linked to `premium`. Google Play ids still empty.
5. Settings > Developer > Keys: the **Project Key** (it ships in the app) and a Secret Key named "Default" (`sk_…`, server only) already exist. Copy the secret yourself into the Worker (step 6); it is never shown to me.
6. Backend: `npx wrangler secret put QONVERSION_SECRET_KEY`.
7. Run the app with the key:
   ```bash
   cd app
   flutter run --dart-define=API_BASE_URL=https://<your-worker> \
               --dart-define=QONVERSION_PROJECT_KEY=xxx
   ```
   Keys passed with `--dart-define` are baked into the build. The Qonversion Project Key is designed to ship in the app; **never** put the `sk_` secret key or any LLM key in the app.
8. Test with a **sandbox tester** (App Store Connect > Users and Access > Sandbox). Check: purchase, the $1.99 first month, restore on a second install, and cancel via Settings > Manage subscription.

## Android (later)
Add the Android app to the same Qonversion project (Play service-account credentials, real-time developer notifications) and link the same three product ids to the Play products. The same Project Key works for both platforms.

## Not verified
- Never run against Qonversion or the stores: only unit/widget tests with a fake service, backend tests with a fake Qonversion API, and an iOS simulator build.
- Intro offers: a free trial shows as "N days free", a paid offer as "$X for your first month". Check in sandbox that the Pay up front offer appears as expected (Qonversion reads it from StoreKit).
- "Your first month ends on …" on the You tab is worked out from the entitlement (no renewals yet and a period far shorter than a year). Confirm in sandbox.
- Manage subscription opens the store's subscriptions page (Qonversion has no per-user management URL).
- Webhook payloads follow Qonversion's docs (documentation.qonversion.io/docs/webhooks, read 2026-10-17); only needed for v1.1 credits, referral and creator.

## Test purchases on the Mac without App Store Connect (StoreKit file)
`app/ios/ShenTarot.storekit` defines the three subscriptions locally: product ids `shentarot_annual` (US$39.99, intro offer $1.99 for the first month, pay up front, group level 1), `shentarot_quarterly` (US$14.99, every 3 months, level 2) and `shentarot_monthly` (US$6.99, level 3), with the store names and description.

To use it in Xcode: open `app/ios/Runner.xcworkspace`, Product > Scheme > Edit Scheme > Run > Options > StoreKit Configuration > choose `ShenTarot.storekit`. Run on the simulator or your own iPhone. Xcode's Debug > StoreKit > Manage Transactions lets you approve, fail, expire or refund purchases.

Limits (not verified): the app still needs a Qonversion project key whose products use these ids; Qonversion then loads prices from the local StoreKit file in this test mode, and purchases validated against Xcode's test store may not reach Qonversion's servers (check Qonversion's StoreKit testing guide). Prices in the file are placeholders; real prices are set in App Store Connect.
