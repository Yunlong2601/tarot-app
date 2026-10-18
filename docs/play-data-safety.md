# Play "Data safety" answers (draft)

Source of truth: `docs/data-inventory.md`. Google's definitions and the form wording change: read each question in Play Console and verify. "Collected" means data leaves the device. Google lets you treat data that is only processed in memory and not retained ("ephemeral processing") differently; confirm how it applies before choosing. Service providers who process data on your behalf are generally not "sharing" (verify), but declare them honestly.

## Does the app collect or share any of the required user data types? Yes.

| Data type (Google category) | Collected | Shared | Optional | Purpose | Notes |
|---|---|---|---|---|---|
| Other user-generated content (the optional question text, the follow-up question and the earlier reading text sent for a follow-up) | Yes | Processed by Anthropic (or OpenAI as backup) on our behalf; not sold | Yes (a question is optional; a reading works without one) | App functionality | Not stored by us, except a reading the user chooses to share (Create link): the reading text and, only if switched on, the question are kept for up to a year as a public page the user can remove. Anthropic's retention applies to the AI request (check their current policy). Answer: collected, optional, not ephemeral, App functionality; user-initiated sharing of a link is generally not "sharing" under Play's definitions, but verify the current wording. |
| Other user-generated content? The user's own AI API key (Premium, optional) | Decide with care: it passes through our server per request but is never stored. Google's "ephemeral processing" may apply; verify the current definition before answering | Sent to the provider the user picked (Anthropic or OpenAI) on the user's instruction | Yes | App functionality | Stays in Keychain/Keystore on the phone; never logged. |
| Device or other IDs (an app-generated random install ID, stored hashed on our server) | Yes | Shared with RevenueCat (subscriptions) as the app user ID | No | App functionality, fraud prevention and security | No advertising ID. |
| Purchase history (subscription status) | Yes (RevenueCat / Google Play) | RevenueCat | No | App functionality | We never see payment card details. |
| App activity > Other actions (daily request counts and token usage tied to the hashed ID) | Yes | No | No | App functionality, fraud prevention | Keep for the period stated in the privacy policy (90 days). |
| Approximate/precise location, contacts, photos, files, audio, health, financial info, personal info (name, email), web history, crash logs/diagnostics | **No** | | | | The camera image is processed on the device and is never saved or sent. |

## Security practices
- Data encrypted in transit: **Yes** (HTTPS).
- Users can request data deletion: **Yes**. On-device history and notes: delete in You > Delete all my data or uninstall. Server-side usage rows (hashed ID): by email to the support address.
- Independent security review: No.
- Follows Play Families policy: No (not for children).

## Permissions to explain (Play Console > App content)
- CAMERA: recognise the tarot card the user holds up (core feature).
- POST_NOTIFICATIONS: the optional daily reminder (local notification).
- BILLING: subscriptions.

## When the build with sign-in is uploaded (not before)
The form must match the build Google reviews. Until a build with Google sign-in turned on (`GOOGLE_SERVER_CLIENT_ID` set) is uploaded, keep "My app does not allow users to create an account".

Then change (or re-import `store/play/data_safety_with_accounts.csv`, which has exactly these changes on top of the current answers):
- Account creation: **OAuth** (instead of "does not allow accounts").
- Delete account URL and Delete data URL: https://yunlong2601.github.io/shentarot-legal/delete-account.html
- Personal info > **User IDs**: collected (not shared), optional, purposes App functionality and Account management, not ephemeral. This is our random account id; we store no name or email.
- Email address: **not** collected (the Google/Apple token may contain one; the server never stores or logs it).
- Also publish the updated `web/public/privacy.html` and `web/public/terms.html` to the legal site at the same time.

## Launch with the credit wallet on (no sign-in yet)
Import `store/play/data_safety_launch_wallet.csv`. On top of `data_safety_now_no_accounts.csv` it adds **Photos** (the creator-program screenshot): collected, not shared, optional, not ephemeral, for App functionality and Fraud prevention; deleted after 30 days. Post links, invite codes and credit records fall under the already-declared Other user-generated content, App activity and Purchase history. RevenueCat's device data (such as OS and app version, country, IP) is processed by a service provider; check whether Play's current definitions need "Device or other IDs" purposes to include Analytics (subscription statistics).
