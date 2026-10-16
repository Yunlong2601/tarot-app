# Play "Data safety" answers (draft)

Source of truth: `docs/data-inventory.md`. Google's definitions and the form wording change: read each question in Play Console and verify. "Collected" means data leaves the device. Google lets you treat data that is only processed in memory and not retained ("ephemeral processing") differently; confirm how it applies before choosing. Service providers who process data on your behalf are generally not "sharing" (verify), but declare them honestly.

## Does the app collect or share any of the required user data types? Yes.

| Data type (Google category) | Collected | Shared | Optional | Purpose | Notes |
|---|---|---|---|---|---|
| Other user-generated content (the optional question text, the follow-up question and the earlier reading text sent for a follow-up) | Yes | Processed by Anthropic (AI provider) on our behalf; not sold | Yes (a question is optional; a reading works without one) | App functionality | Not stored by us. Anthropic's retention applies (check their current policy). |
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
