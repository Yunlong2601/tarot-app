# Reading credits and the Starter Pack: status and owner setup

Built 2026-10-17, **switched off** (app flag `CREDITS`, server `CREDITS_ENABLED`). Server migration `0004_credits.sql` is NOT applied to the live database yet.

## How it works (ShenTarot's version)
- 1 credit = one extra AI reading after the free daily one, or one follow-up / clarifier for a free user. Premium doesn't need credits.
- The server holds the balance (per account, or per install without one), so it can't be edited on the phone. Each store purchase is added once, even if the store retries.
- A credit is given back automatically if the reading fails. Credits never expire.
- The paywall shows the Starter Pack under the memberships: "Not ready to subscribe? Starter Pack: 5 reading credits for $X, one time."
- Without an account, credits belong to this phone and are lost if the app is deleted (same as referral months); signing in keeps them. Say this in the small print once accounts are on.

## Owner setup
1. App Store Connect: In-App Purchases > + > **Consumable**, product id `shentarot_credits_5`, name "Starter Pack (5 readings)", price about US$2.99.
2. Play Console: Monetize > In-app products > Create product `shentarot_credits_5`, same name and price, Active.
3. RevenueCat: import the product (no entitlement needed). Webhook set up as in `docs/referral-setup.md` step 4 (same URL and secret).
4. Tell me to switch on: I apply migration 0004, set `CREDITS_ENABLED=true`, deploy, and build with `--dart-define=CREDITS=true`.
5. Store forms: Play Data safety already declares Purchase history; Apple's privacy label already covers purchases. Re-check both after switching on.
