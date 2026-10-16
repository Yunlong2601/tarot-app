# Data inventory (what the app and backend handle)

Single source for the privacy policy, Apple privacy labels and Google Data safety form. Update this first whenever data handling changes. Last checked against the code: 2026-10-16 (phase-f branch).

| Data | Collected? | Where it goes | Why | Linked to a person? | Retention |
|---|---|---|---|---|---|
| Card photo (camera) | Processed only | Device memory; temp file deleted right after recognition | Identify the card | No | Never stored or uploaded |
| Card IDs + orientation + spread | Yes | App -> our server -> Anthropic (LLM) | Generate the reading | Not stored by us | Not stored by us; Anthropic's retention applies (verify current policy) |
| Optional question text | Yes, only if typed | App -> our server -> Anthropic | Generate the reading | Not stored by us | Not stored by us; Anthropic's retention applies |
| Optional "Look first" note (what the user notices in the cards) | Yes, only if typed | App -> our server -> Anthropic | Personalise the reading | Not stored by us | Not stored by us; Anthropic's retention applies |
| Follow-up question + the earlier reading text (Premium) | Yes, when the user asks a follow-up | App -> our server -> Anthropic | Answer the follow-up in context | Not stored by us | Not stored by us; Anthropic's retention applies |
| Anonymous install ID (random UUID) | Yes | App -> our server (hashed with a secret salt) and RevenueCat (as the app user ID) | Rate limits, free daily limit, restore purchases | Pseudonymous | Server keeps the hash with daily usage rows; RevenueCat keeps purchase records per its policy |
| Usage rows: date, spread, model, input/output token counts | Yes | Our D1 database | Cost control, abuse prevention | Pseudonymous (hashed ID) | Decide a limit (suggest 90 days) and add a cleanup job |
| IP address | Seen by Cloudflare; a salted hash is used for a per-minute counter | Cloudflare KV, expires in about 2 minutes | Abuse prevention | Pseudonymous | About 2 minutes (counter); Cloudflare's own logs per its policy |
| Purchase / subscription status | Yes | Apple / Google, RevenueCat; our server asks RevenueCat | Unlock Premium, restore | Via install ID | Per store and RevenueCat policies |
| Reading history, journal notes, look-back answers | Yes | Device only (SQLite) | Feature | n/a | Until the user deletes it or uninstalls |
| Reminder time, onboarding flag, daily count | Yes | Device only | Feature | n/a | Until uninstall |
| Analytics | **No** (TelemetryDeck was planned but is not implemented) | n/a | n/a | n/a | If added, update this file, the policy and the store forms |
| Ads / ad IDs / third-party trackers | No | n/a | n/a | n/a | n/a |
| Accounts, email, name, location, contacts | No | n/a | n/a | n/a | n/a (so no account deletion flow is required; re-check store rules if accounts are ever added) |

Third parties: Anthropic (LLM), Cloudflare (hosting), RevenueCat (subscriptions), Apple / Google (payments). Servers are outside Singapore, so the policy must say data is sent overseas (PDPA transfer rules: verify at pdpc.gov.sg).
