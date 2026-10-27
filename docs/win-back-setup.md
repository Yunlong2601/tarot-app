# Win-back offers (App Store Connect)

Tier 3 #28. Apple shows these itself to people who cancelled: in Settings > Subscriptions (iOS 14.3+) and in its own win-back sheet (iOS 18+). No app code is needed while streamlined purchasing is on (the default). Check Apple's current help page before you start: https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers

Each subscription must already be approved by App Review, so do this after 1.0 is live.

## Offers to create

For each of `shentarot_monthly`, `shentarot_quarterly` and `shentarot_annual` (check the exact ids in App Store Connect)
(App Store Connect > your app > Subscriptions > the group > the product > Win-Back Offers > +):

| Offer | Eligibility | Price | Wait between offers |
|---|---|---|---|
| `winback_recent` | Paid at least 1 month; last subscribed 1 to 3 months ago | Annual: first month $1.99, pay up front. Monthly: first month $1.99. Quarterly: first 3 months $7.99, pay up front | 6 months |
| `winback_lapsed` | Paid at least 1 month; last subscribed 4 to 12 months ago | Same as above | 6 months |

Rules to know (Apple's page, checked 2026-10-27):
- Up to 5 active win-back offers per storefront, at least 3 days long.
- A customer is only eligible for the product they most recently lapsed from in each group.
- The offer price and offer ID cannot be changed after you create it. Pick carefully.
- Turn on "Wait Between Offers" so nobody learns to cancel for a discount.

## Measuring

RevenueCat > Charts > Reactivations, filtered by offer. Expect a few percent of lapsed annual subscribers and more of monthly ones (RevenueCat 2026 benchmarks: about 5% annual, about 20% monthly).

## Later (needs app code)

Showing a win-back offer on our own paywall needs RevenueCat iOS SDK 5.10+ and an In-App Purchase Key uploaded to RevenueCat. It is not yet confirmed that `purchases_flutter` 10.16 exposes `eligibleWinBackOffers`; check before building it.
