# Data inventory (what the app and backend handle)

Single source for the privacy policy, Apple privacy labels and Google Data safety form. Update this first whenever data handling changes. Last checked against the code: 2026-10-16 (phase-f branch).

| Data | Collected? | Where it goes | Why | Linked to a person? | Retention |
|---|---|---|---|---|---|
| Card photo (camera) | Processed only | Device memory; temp file deleted right after recognition | Identify the card | No | Never stored or uploaded |
| Card IDs + orientation + spread | Yes | App -> our server -> Anthropic (LLM), or OpenAI as fallback / when the user's own key is OpenAI | Generate the reading | Not stored by us | Not stored by us; Anthropic's retention applies (verify current policy) |
| Optional question text | Yes, only if typed | App -> our server -> Anthropic | Generate the reading | Not stored by us | Not stored by us; Anthropic's retention applies |
| Optional "Look first" note (what the user notices in the cards) | Yes, only if typed | App -> our server -> Anthropic | Personalise the reading | Not stored by us | Not stored by us; Anthropic's retention applies |
| Follow-up question + the earlier reading text (Premium) | Yes, when the user asks a follow-up | App -> our server -> Anthropic | Answer the follow-up in context | Not stored by us | Not stored by us; Anthropic's retention applies |
| User's own AI API key (optional, Premium) | Yes, only if the user adds one | Device secure storage (Keychain/Keystore); sent per request in a header to our server, then to the chosen provider (Anthropic or OpenAI) | Bill the user's own provider account; unlimited readings | Not stored or logged by us (backend logs redact `sk-` strings) | On the device until the user removes it or uses Delete all my data |
| Anonymous install ID (random UUID) | Yes | App -> our server (hashed with a secret salt) and RevenueCat (as the app user ID) | Rate limits, free daily limit, restore purchases | Pseudonymous | Server keeps the hash with daily usage rows; RevenueCat keeps purchase records per its policy |
| Usage rows: date, spread, model, input/output token counts | Yes | Our D1 database | Cost control, abuse prevention | Pseudonymous (hashed ID) | Decide a limit (suggest 90 days) and add a cleanup job |
| IP address | Seen by Cloudflare; a salted hash is used for a per-minute counter | Cloudflare KV, expires in about 2 minutes | Abuse prevention | Pseudonymous | About 2 minutes (counter); Cloudflare's own logs per its policy |
| Purchase / subscription status | Yes | Apple / Google, RevenueCat; our server asks RevenueCat | Unlock Premium, restore | Via install ID | Per store and RevenueCat policies |
| Reading history, journal notes, look-back answers | Yes | Device only (SQLite) | Feature | n/a | Until the user deletes it or uninstalls |
| Reminder time, onboarding flag, daily count | Yes | Device only | Feature | n/a | Until uninstall |
| Analytics | **No** (TelemetryDeck was planned but is not implemented) | n/a | n/a | n/a | If added, update this file, the policy and the store forms |
| Ads / ad IDs / third-party trackers | No | n/a | n/a | n/a | n/a |
| Creator program: post link, platform, screenshot of the post | Yes, only if the user sends a post | Our D1 (link, platform, result, likes the owner counted, owner key) and a private R2 bucket (the screenshot); the screenshot is looked at only by the owner | Check the post, give credits and the free month | Yes (owner key, RevenueCat app user id) | Screenshot deleted after 30 days; link and result kept until the account is deleted (account deletion also removes credits, referral records and creator posts for the account and its installs) |
| Shared reading page: spread, cards, reading text, the question only if "Show my question" is on | Yes, only when the user taps Create link on a reading | Our KV (`share:<token>`) with a salted hash of the install id (to allow deletion); served as a public, noindex page at `/s/<token>` | Let the user show a reading to friends | No name or account; hashed install id only | 365 days (KV expiry), or until Stop sharing / deleting the reading / Delete all my data |
| Optional account (Google / Apple sign-in) | Yes, only if the user signs in | Our D1: random account id, provider, salted hash of the provider user id; linked to the hashed install ids; account id shared with RevenueCat as the app user id | Premium across devices, per-account limits | Yes (account id) | Until the user deletes the account (in app, or by email via the deletion page) |
| Email, name, location, contacts | No (the Google/Apple token may contain an email; it is never stored or logged) | n/a | n/a | n/a | n/a |

Third parties: Anthropic (LLM), Cloudflare (hosting), RevenueCat (subscriptions), Apple / Google (payments). Servers are outside Singapore, so the policy must say data is sent overseas (PDPA transfer rules: verify at pdpc.gov.sg).
