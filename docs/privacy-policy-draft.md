# Privacy Policy

> **Provider change (2026-10-17):** subscriptions move from RevenueCat to **Qonversion** (owner decision; the app and backend code migration is in progress). This is a disclosure doc: every RevenueCat mention below must name Qonversion before it is published, after checking what data Qonversion's SDK and servers receive (not checked yet; may differ from RevenueCat). Not changed yet on purpose.

> DRAFT. Not legal advice. Have it reviewed (PDPA; GDPR/UK GDPR if you launch there; Apple and Google requirements) before publishing. Replace the bracketed items. Host the final text at a public URL; both stores require a URL. The same text is bundled in the app at `app/assets/legal/privacy.txt`.

**ShenTarot** ("the app") is provided by ShenTech, Singapore. Contact: shenyunlongbusiness@gmail.com. Effective date: 16 October 2026.

The app is for entertainment and self-reflection only.

## What we handle and why
- **Camera.** When you scan a card, the photo is analysed on your phone to recognise the card. The photo is not saved and is not sent to us or anyone else.
- **Your reading request.** To write a reading we send the cards (names/IDs and whether upright or reversed), the spread type and, if you typed them, your question and what you noticed in the cards ("Look first") to our server, which passes it to an AI provider (Anthropic, or OpenAI as a backup) to generate the text. If you ask a follow-up question (Premium), we also send your follow-up and the earlier reading text from your phone so the answer fits the reading. We do not store your question or the reading on our servers. The AI provider may keep API data for a limited time under its own policy: https://www.anthropic.com/legal/privacy and https://openai.com/policies/privacy-policy. Please do not put sensitive personal information in your question.
- **Your own AI key (optional, Premium).** If you add your own Anthropic or OpenAI API key, it is stored only on your phone in its secure storage (iOS Keychain / Android Keystore). It is sent with each reading to our server, which passes it to that provider for that one request. We never save or log your key. The provider bills your account and handles your request under its own terms and privacy policy. You can remove the key at any time in the app.
- **Account (optional).** If you sign in with Google or Apple, they send us a sign-in token that we check. We keep only a random account ID, which sign-in method you used, and a scrambled (hashed) version of your Google or Apple user ID. We do not store your name or email address. Your account ID is linked to the anonymous ID of each phone you sign in on, and is shared with RevenueCat so Premium follows your account. Delete your account at any time in You > Account > Delete account, or as described at https://yunlong2601.github.io/shentarot-legal/delete-account.html.
- **Anonymous ID.** The app creates a random ID on your phone. We store only a scrambled (hashed) version, together with the date, spread type and the amount of AI text used, to apply daily limits, prevent abuse and control costs. We do not know who you are from this.
- **Network address.** Our hosting provider (Cloudflare) sees your IP address when the app connects. We use a scrambled version of it for a short-lived (about two minutes) request counter to prevent abuse.
- **Purchases.** Subscriptions are handled by Apple or Google and by RevenueCat, which receives your anonymous ID and purchase status so we can unlock Premium and restore purchases. We do not receive your payment details.
- **Stored on your device only.** Your reading history, journal notes, reminder time and settings stay on your phone. You can delete them in Settings > Delete all my data, or by uninstalling the app.
- **Reminders.** The daily reminder is a local notification scheduled on your phone. We do not send push notifications.

## What we do not do
Accounts are optional. No advertising, no tracking across other apps or websites, no sale of data.

## Sharing and overseas transfers
We share data only with service providers needed to run the app: Anthropic and OpenAI (AI), Google and Apple (optional sign-in), Cloudflare (hosting), RevenueCat (subscriptions), and Apple/Google (payments). These providers operate outside Singapore, so your request data is transferred overseas.

## Retention
Usage records (hashed ID, date, spread, token counts) are kept for 90 days. Account records are kept until you delete the account. Everything on your device stays until you delete it.

## Your choices and rights
You can use the app without typing a question. You can delete your on-device data at any time. To ask about, access or correct data we hold (the hashed ID and usage records), or to ask us to delete it, contact shenyunlongbusiness@gmail.com. Our contact for data protection is ShenTech at the email above.

## Children
The app is not directed to children under 13.

## Security
Requests use HTTPS. Secrets are kept on the server, not in the app. No method is perfectly secure.

## Changes
We will update this page and the date above when this policy changes.
