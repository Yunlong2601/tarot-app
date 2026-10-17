# Accounts and sign-in: plan (not built)

> **Provider change (2026-10-17):** subscriptions move from RevenueCat to **Qonversion** (owner decision; the app and backend code migration is in progress). RevenueCat steps, keys and webhooks below are on hold: do not create a RevenueCat project. This doc is rewritten for Qonversion once the code lands.

Status 2026-10-17: proposal for the owner. Nothing is built. Store rules below are from memory and must be checked against the current Apple App Review Guidelines and Google Play policies before building.

## Recommendation
- **Sign in with Apple + Sign in with Google**, both optional. Keep **"Continue without an account"**: the free reading, scanning and history all work without one. Skip email/password (password resets, breaches, support load). An email magic link can come later.
- Apple: if an iOS app offers a third-party social login (Google), it must also offer Sign in with Apple or an equivalent privacy-preserving option (guideline 4.8; verify current wording). So offer both on iOS; on Android, Google alone is enough, Apple optional.
- **Where accounts live:** our own Cloudflare Worker + D1 (already deployed). The app gets an Apple identity token or Google ID token, sends it to `POST /v1/account/signin`, the Worker verifies the signature against Apple's / Google's public keys, creates or finds the account, and returns our own short-lived session token (same HS256 JWT we use now, with `sub` = account id). No Firebase: one less vendor, nothing new in the privacy policy except the sign-in provider. Effort is higher than Firebase Auth, but the code stays in one place.

## What changes
- **Anonymous install ID → account:** on first sign-in the current install's usage rows are linked to the account (D1 `accounts` and `account_installs` tables). Daily caps then count per account, so signing in on two phones doesn't double the free reading.
- **Subscriptions:** RevenueCat `logIn(accountId)` on sign-in, `logOut()` on sign-out. Premium then follows the account across devices and platforms (an Apple subscription unlocks Premium on Android too). Restore Purchases stays for people without accounts.
- **What syncs (proposal):** only the account id, sign-in provider and subscription status by default. Reading history and journal **stay on the phone** in v1; cloud sync of history is a separate, opt-in feature later (it means storing questions and readings on our server, a big privacy change).
- **Deletion (required by both stores):** "Delete account" in the You tab deletes the account row, its links and usage rows on our server, logs out of RevenueCat, and tells the user that an active subscription must be cancelled in the store. Apple: Sign in with Apple tokens must be revoked on deletion (verify). Google Play: also a **web page** where people can ask for deletion without the app (a simple form or email link on the legal site).
- **Docs to update:** privacy policy (account id, email if the provider shares it, Apple's private relay email), terms, `docs/data-inventory.md`, Play **Data safety** (currently "no accounts": add "Personal info > Email address" if collected, "User IDs", account deletion URL), Apple **privacy label** (Contact Info > Email if kept, Identifiers > User ID, linked to the user).

## Abuse and cost controls
- Daily caps per account and per install (whichever is stricter), so making new accounts doesn't reset limits on one phone.
- Rate limit sign-in attempts per IP. Verify tokens fully (issuer, audience, expiry, nonce for Apple).
- Accounts don't replace Play Integrity / App Attest; keep them on the plan.

## Effort and risks
- About 2 to 3 focused work sessions: backend endpoints + D1 migration + token verification + tests; app sign-in buttons (`sign_in_with_apple`, `google_sign_in` packages), session storage in secure storage, RevenueCat login/logout, Delete account flow; doc and store-form updates.
- Risks: store review of the deletion flow; Google Sign-In setup errors (SHA-1 of the Play app-signing key must be registered); privacy-label changes; support requests ("I lost my account").

## What you (the owner) must set up first
1. **Google Cloud project** (can be the one Play creates): OAuth consent screen, an **Android OAuth client** with package `com.shentech.shentarot` and the SHA-1 of both the upload key and Play's app-signing key, and a **Web client id** (used by the server to check tokens).
2. **Apple** (after enrollment): enable Sign in with Apple on the App ID; for Android/web use, a **Services ID** and a key.
3. Decide: (a) accounts at all for v1, or after launch; (b) is history cloud sync wanted later.
