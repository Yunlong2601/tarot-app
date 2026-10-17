# Qonversion: data and cost notes

Read 2026-10-17 from Qonversion's own pages. They change: re-check before publishing the privacy policy or store forms.

## Cost
- Pro plan: free while monthly tracked revenue (MTR) is US$7,000 or less, all features included (analytics, A/B experiments, paywall builder, webhooks, integrations). Above US$7,000 it is **0.8% of all tracked revenue**, not just the part above (US$64 at US$8,000). Source: https://www.qonversion.io/pricing
- For this app that is US$0 until roughly 2,500 annual subscribers' worth of revenue a month; it does not change break-even (`docs/unit-economics.md`).

## Data the SDK sends to Qonversion
| Source | What it says |
|---|---|
| App Store privacy page (https://documentation.qonversion.io/docs/app-store-privacy) | Identifiers: User ID and Device ID. Purchases: App Store purchase history. Other Data: device OS, make, model, resolution. Usage data and diagnostics: not collected. Suggested purposes: Analytics and App Functionality. |
| Play data safety page (https://documentation.qonversion.io/docs/google-play-data-safety) | User ID, Device ID, purchase history, device OS/make/model. Collection is mandatory (users can't opt out). Qonversion itself doesn't share data; sharing depends on integrations you turn on. Sent over HTTPS. |
| Privacy policy, updated 2026-07-21 (https://qonversion.io/privacy-policy) | Also lists IP address, device push token, Advertiser ID, Apple receipt / Google purchase token, transactions, device type, OS version, carrier, country, locale, time zone, last app use, plus any user properties the app sends. Stored in Google Cloud and DigitalOcean data centres in London, UK. Acts as a service provider; deletion on the developer's instruction (EU: compliance@qonversion.io). No retention period stated. |

## What this changes for us
- Privacy policy draft, data inventory and Play data safety draft now name Qonversion and the extra device data.
- App Store Connect App Privacy answers are already published with the RevenueCat-era set. With Qonversion they likely need **Other Data** (device info) and a check of **Identifiers > Device ID**, for Analytics and App Functionality. Owner updates them before submitting a Qonversion build.
- Advertising ID: we never ask for IDFA (no tracking prompt), so iOS sends none. On Android, check the merged manifest of the migrated build for `com.google.android.gms.permission.AD_ID`; remove it or declare it.
- Do not turn on Qonversion integrations (ad networks, analytics tools) without updating these docs: they become "sharing".
- In-app `app/assets/legal/privacy.txt` and `site/privacy.html` still say RevenueCat; update them together with the code swap.
