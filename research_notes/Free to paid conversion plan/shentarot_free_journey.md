# ShenTarot free-user journey audit (from code, credits ON)

Scope: read-only code audit of the worktree `zealous-bartik-6d72b9`. App paths are relative to `app/`, backend paths to `backend/`. English on-screen text = the `tr('...')` key (all 15 translation files contain every credit/paywall key checked; see Q4). Sources are cited as file:line. Live config: `app/config/live.json` sets `"CREDITS": true`, `"APPLE_SIGNIN": true`; backend `backend/wrangler.toml:14` sets `CREDITS_ENABLED = "true"` and `:23` sets `APPLE_CLIENT_IDS`, which turns on the guest limit.

## Q1. Walkthrough: where a free user meets credits, costs, locks and the paywall

### Takeaway
A free user meets the credit balance only as a small grey line on three screens (Today, Draw tab, Photo reading). The screens where a credit is actually spent (Card of the Day "Go deeper", spread picker, "Get my reading", the Look-first dialog) never state the cost. The only explicit "1 credit" labels are on follow-ups and the clarifier. When credits are known to be zero, every reading button goes straight to the paywall with no message.

### Cited Findings

**App start / onboarding**
- On every launch the app calls `claimDailyCredit()` (POST /v1/credits/daily), then refreshes the balance — [lib/main.dart:55](app/lib/main.dart), [lib/app/app_state.dart:77-83](app/lib/app/app_state.dart).
- Onboarding is 2 pages. Page 2 title: "Readings that fit your question". Body with credits on: "Ask what is on your mind and get a thoughtful, plain-language reading of your cards. Start with 10 free readings, then get a free one every day." — [lib/features/onboarding/onboarding_screen.dart:26-31](app/lib/features/onboarding/onboarding_screen.dart). It does not say "credits", and does not mention 2 a day when signed in.
- "Get started" opens the Account screen once if sign-in is available — [onboarding_screen.dart:101-111](app/lib/features/onboarding/onboarding_screen.dart). Its copy: "Sign in (optional)" / "Sign in to keep Premium when you change or add a phone. You can use ShenTarot fully without an account." / "We do not store your name or email. Your readings and journal stay on this phone either way." / "Continue with {0}" / "Continue without an account" — [lib/features/you/account_screen.dart:90-137](app/lib/features/you/account_screen.dart). **It does not mention the extra daily credit for signing in**, which is the main free-user reason to sign in.
- No paywall is shown during onboarding (no `/paywall` push in onboarding) — [onboarding_screen.dart](app/lib/features/onboarding/onboarding_screen.dart).

**Today tab**
- Shows the Card of the Day section ("Draw your Card of the Day for a question to carry with you today. Free, every day." / button "Draw today's card"), then a 12pt grey `creditLine`, then `AnnualUpgradeCard` (only for monthly/quarterly subscribers) — [lib/features/today/today_screen.dart:40-47](app/lib/features/today/today_screen.dart), [lib/features/guide/today_section.dart:37-47](app/lib/features/guide/today_section.dart).
- `creditLine` (credits on), [app_state.dart:110-141](app/lib/app/app_state.dart):
  - credits > 0: "{0} credits · {1}, unused credits roll over" where {1} is "1 new credit every day" (guest, server reports 1) or "{0} new credits every day" (signed in, 2).
  - credits = 0, free: "No credits left. {0} new credits arrive tomorrow, or go Premium."
  - Premium: "{0} new credits every month, and {1} a day".
- Fresh guest example: "11 credits · 1 new credit every day, unused credits roll over" (10 welcome + 1 daily; backend grants both on first claim — [backend/src/index.ts:231-241](backend/src/index.ts)).

**Card of the Day**
- Free, drawn on device, no AI and no credit — [app_state.dart:514-534](app/lib/app/app_state.dart). Screen: "Card of the Day", "Take a breath, then tap the card to turn it over.", "Light: {0}.  Shadow: {1}.", "To reflect on today: {0}" — [lib/features/read/daily_card_screen.dart:49-103](app/lib/features/read/daily_card_screen.dart).
- Button "Go deeper: reading for this card" calls `startReading(single)` directly — this **spends 1 credit with no cost shown** and skips the question screen — [daily_card_screen.dart:114-120](app/lib/features/read/daily_card_screen.dart).

**Draw tab (Read home) and question screen**
- Draw tab: "No deck with you?" / "Take a breath and hold your question in mind." / button "Digital card reading", then the same grey `creditLine` — [lib/features/read/read_home_screen.dart:42-72,107](app/lib/features/read/read_home_screen.dart).
- Scan (middle tab button) sets photo mode and opens `/ask` — [lib/features/today/today_screen.dart:56-59](app/lib/features/today/today_screen.dart). Photo reading screen also shows `creditLine` — [lib/features/scan/scan_screen.dart:169](app/lib/features/scan/scan_screen.dart).
- Question screen ("Your question", "What would you like to ask the cards?", "Skip: general reading") shows no credit or cost information — [lib/features/read/ask_screen.dart:121-333](app/lib/features/read/ask_screen.dart).

**Spread picker**
- Chips show "{label} · {n}" with a lock icon on every 5/7/10-card spread for non-Premium users, **even while the free trial is still unused** — [lib/features/read/spread_picker_screen.dart:63-70](app/lib/features/read/spread_picker_screen.dart).
- Premium spread card, trial unused: gift icon + "Uses your one-time free premium reading"; button "Start free reading" — [spread_picker_screen.dart:148-167,216-221](app/lib/features/read/spread_picker_screen.dart).
- Trial used: button "Unlock with Premium" → paywall — [spread_picker_screen.dart:38,207-218](app/lib/features/read/spread_picker_screen.dart).
- Free spread: button "Start reading". No cost shown. If `canStart` is false (credits known = 0) the button silently opens the paywall — [spread_picker_screen.dart:206-209](app/lib/features/read/spread_picker_screen.dart), [app_state.dart:334-341](app/lib/app/app_state.dart).
- Spreads: ≤3 cards free, 5/7/10 Premium — [lib/data/spreads.dart:271-273](app/lib/data/spreads.dart); backend mirrors it — [backend/src/spreads.ts:105-109](backend/src/spreads.ts).
- Learn tab spread list: no lock icons and no trial notice; tapping a premium spread goes to the paywall only if `canStart` fails; otherwise it skips the picker, so **the "Uses your one-time free premium reading" warning is never shown on this path** — [lib/features/library/library_screen.dart:111-117,171-201](app/lib/features/library/library_screen.dart).

**Drawing → reading**
- Draw screen button "Get my reading"; no cost shown — [lib/features/draw/draw_screen.dart:272,323](app/lib/features/draw/draw_screen.dart).
- "Look first" dialog (on by default) — "Before the reading, what do you notice? A colour, a figure, a feeling. Optional." with Cancel / Skip / Read; no cost shown — [lib/features/reading/start_reading.dart:169-217](app/lib/features/reading/start_reading.dart).
- Waiting text: "Reading your cards..." → "Writing your reading..." → "Still working. This can take up to a minute." — [start_reading.dart:230-234](app/lib/features/reading/start_reading.dart).
- After success the app refreshes credits silently; no "1 credit used, N left" confirmation — [start_reading.dart:51](app/lib/features/reading/start_reading.dart).

**Follow-up / clarifier (Reading screen "Ask the reader")**
- With credits (or unknown balance): idea chips fill the box but do not send ("asking costs a credit"); hint "Ask the reader more..."; below: "Each question uses {0}." with {0} = "1 credit"; clarifier: "Draw a clarifier card (1 credit)" — [lib/features/reading/reading_screen.dart:153-305](app/lib/features/reading/reading_screen.dart).
- With zero credits: "Ask a follow-up (Premium)" and "Draw a clarifier card (Premium)" with lock icons → paywall — [reading_screen.dart:217-223,306-311](app/lib/features/reading/reading_screen.dart). The label says Premium although a credit pack would also unlock it.
- Clarifier sheet ("Draw a clarifier card" / "One more card to shed light on this reading." / "Draw one for me" / "I drew one from my deck") does not repeat the cost — [reading_screen.dart:58-80](app/lib/features/reading/reading_screen.dart).
- Server 402 on a follow-up → paywall — [reading_screen.dart:131-133](app/lib/features/reading/reading_screen.dart).
- Journal notes are free ("Your journal" / "Private, kept on this phone. The reader never sees it.") — [reading_screen.dart:319,343-352](app/lib/features/reading/reading_screen.dart).

**History / Your deck / milestones / You tab**
- History screen has no monetization touchpoints — [lib/features/history/history_screen.dart](app/lib/features/history/history_screen.dart).
- Your deck → "This month" card: free users see only the top recurring card; the suit/group breakdown is hidden, with a lock button "See your full month with Premium" → paywall — [lib/features/collection/collection_screen.dart:186-247](app/lib/features/collection/collection_screen.dart).
- Milestones include "Celtic Cross — A full ten-card Celtic Cross", reachable by a free user only through the one-time trial — [lib/features/collection/insights.dart:79-85](app/lib/features/collection/insights.dart).
- You tab profile: "Guest" / "Free plan", stats "{n} readings · streak · {credits} credits" — [lib/features/you/you_screen.dart:140-171](app/lib/features/you/you_screen.dart).
- You tab Premium card: "Go Premium" / "All spreads, follow-ups, 50 readings a day, plus the clarifier card and a look back." → paywall — [you_screen.dart:186-235](app/lib/features/you/you_screen.dart).
- Learn → Guide FAQ: "One and three-card spreads are free (two AI readings a day); the 5, 7 and 10-card spreads are part of Premium, with one free try." and "Premium adds follow-up questions, a clarifier card and a look back a week later." — [lib/features/guide/guide_screen.dart:72,82](app/lib/features/guide/guide_screen.dart).

### Inferences
- A hesitant free user sees no cost at the moment of spending on 4 of the 6 spend points: Go deeper, Start reading, Get my reading, Look first. Only follow-up and clarifier show "1 credit".
- The free trial of a premium spread looks free twice ("one-time free premium reading", "Start free reading"), but it costs a credit (see Q6). A user with 0 credits cannot use the trial; they are sent to the paywall with no explanation.

### Gaps
- Not checked at runtime; layout, the order seen on small screens and whether the grey creditLine is noticed were not verified.

## Q2. What the paywall shows

### Takeaway
The paywall leads with outdated "50 readings a day" copy, then a correct credit bullet. It lists 3 subscription plans with Annual pre-selected and its US$1.99 intro, a "Not ready to subscribe?" credit-pack card, a trust line, Apple legal text, Restore, Privacy and Terms. It has no sign-in path, no "come back tomorrow" path, and no header saying why the user landed there.

### Cited Findings
- Header: close X, card fan, wordmark, title "Unlock Premium" — [lib/features/paywall/paywall_screen.dart:154-172](app/lib/features/paywall/paywall_screen.dart).
- Benefit bullets — [paywall_screen.dart:174-183](app/lib/features/paywall/paywall_screen.dart):
  1. "All spreads, follow-ups, 50 readings a day"
  2. "90 to 150 new credits every month by plan (free: 1 a day, 2 when signed in), and unused credits roll over"
  3. "A clarifier card to shed light on a reading"
  4. "A look back a week later, with a reminder"
  5. "Helps keep ShenTarot running"
- Plans come from RevenueCat, ordered Annual → 3 Months → Monthly, and the first (Annual) is pre-selected — [lib/core/subscription_service.dart:339-349](app/lib/core/subscription_service.dart), [paywall_screen.dart:66](app/lib/features/paywall/paywall_screen.dart).
- Row title: "{title} · {price} {period}", e.g. "Annual · $39.99 per year"; Annual gets a "Best value" badge; subtitle joins the trial label, "just {0}/month" (Annual) or "{0}/month" (3 Months), and "save {0}% vs monthly" — [paywall_screen.dart:236-251,378-389](app/lib/features/paywall/paywall_screen.dart). With the stated prices that is "$1.99 for your first month · just $3.33/month · save 52% vs monthly" (52% computed by `annualSaving`, [paywall_screen.dart:368-374](app/lib/features/paywall/paywall_screen.dart); the preview plans list the same numbers, [paywall_screen.dart:528-554](app/lib/features/paywall/paywall_screen.dart)).
- Intro label: "{0} for your first {1}" — [subscription_service.dart:366-374](app/lib/core/subscription_service.dart).
- CTA: "Start {0} free trial" (free trial), "Start for {0}" (paid intro → "Start for $1.99"), or "Subscribe" — [paywall_screen.dart:261-277](app/lib/features/paywall/paywall_screen.dart).
- Terms line: "{0}, then {1} {2}. Cancel any time at least 24 hours before the first period ends." (paid intro) / "...before the trial ends." (free trial) / "{price} {period}." — [paywall_screen.dart:280-304](app/lib/features/paywall/paywall_screen.dart).
- Trust line: "No surprise charges: cancel anytime, and we can remind you 2 days before it ends." (with intro) or "No surprise charges: cancel anytime." — [paywall_screen.dart:305-329](app/lib/features/paywall/paywall_screen.dart). After purchase the app offers the reminder 2 days before the intro ends — [app_state.dart:603-619](app/lib/app/app_state.dart).
- iOS legal: "Payment is charged to your Apple ID account. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your App Store account settings." — [paywall_screen.dart:331-341](app/lib/features/paywall/paywall_screen.dart).
- Links: "Restore Purchases", "Privacy Policy", "Terms of Use"; restore with nothing found → "No active subscription found for this account." — [paywall_screen.dart:342-358,135](app/lib/features/paywall/paywall_screen.dart).
- Credit packs card (between the plans and the CTA) — [paywall_screen.dart:257-259,466-524](app/lib/features/paywall/paywall_screen.dart): title "Not ready to subscribe?"; body "Buy a few credits once. One credit pays for a reading or a follow-up, and credits never expire. Premium costs less per credit and also includes 90 to 150 new credits every month and the 5, 7 and 10-card spreads. Free users get 1 new credit a day, or 2 when signed in. Premium members keep their credits if they reinstall and restore purchases."; buttons "{n} credits · {price}" with "one time" period (e.g. "10 credits · $1.99"), sorted by size — [subscription_service.dart:248-270](app/lib/core/subscription_service.dart). With no store products the button is a disabled "Coming soon".
- Pack purchase success: "You have {0} reading credits." after two 2-second balance checks — [paywall_screen.dart:79-94](app/lib/features/paywall/paywall_screen.dart).
- Optional friend card (referral code, iOS): "Friend's offer: 50% off your first year" — [paywall_screen.dart:415-462](app/lib/features/paywall/paywall_screen.dart). Referrals are off unless built with `REFERRALS` — [lib/app/flags.dart:16](app/lib/app/flags.dart).
- After buying: "Welcome to Premium" screen, "NOW UNLOCKED" perks: "Every spread", "Follow-up questions", "A clarifier card", "Up to 50 readings a day — Read as often as you like", "A look back"; CTA "Start a Premium reading" — [lib/features/paywall/welcome_premium_screen.dart:32-54,189,236](app/lib/features/paywall/welcome_premium_screen.dart).

### Inferences
- Bullet 1 ("50 readings a day") and bullet 2 (90-150 credits a month) describe two different models side by side. A careful reader may wonder whether Premium is 50 a day or about 3-5 a day.
- The pack card's long paragraph (5 sentences) is the only place that explains credits in full. It sits inside the paywall, so a free user who never opens the paywall never learns the rules.
- The paywall is a single generic page. It does not know whether it was opened by "out of credits", "locked spread", "follow-up" or "full month", so it cannot say why the user is there.

### Gaps
- Real store prices, intro eligibility and localized pack titles come from RevenueCat at runtime and were not verified.

## Q3. When credits run out: messages and gentle paths

### Takeaway
With the balance known to be 0, the app shows no "out of credits" message at the moment of tapping. Every reading entry point opens the paywall directly. The only gentle copy is the grey Today/Draw line, "No credits left. {0} new credits arrive tomorrow, or go Premium.". The sign-in nudge dialog exists, but on the credits-on path it is effectively unreachable, and it uses outdated "free reading" wording.

### Cited Findings
- `canStart` with credits on: `(credits > 0 || !creditsKnown) && (spread.isFree || !trialUsed)`; when false, `startReading` pushes `/paywall` with no dialog — [app_state.dart:334-341](app/lib/app/app_state.dart), [start_reading.dart:28-31](app/lib/features/reading/start_reading.dart).
- Server out-of-credit response with the wallet on: `charge()` returns `{ok:false, limit: DAILY_SPEND_GUARD}` (50) when `spend` finds no credit — [backend/src/index.ts:254-264](backend/src/index.ts). The reading route then returns 429 `daily_limit` with `guest: ... paid.limit === GUEST_READINGS_PER_DAY` → **always false with the wallet on** (limit is 50, not 1) — [index.ts:436](backend/src/index.ts).
- App maps 429 daily_limit to "You have used today's free reading." — [lib/core/api_reading_service.dart:254-256](app/lib/core/api_reading_service.dart). Then: Premium gets a snackbar ("You have used today's readings for your plan. Use a credit, or come back after the daily reset (00:00 UTC)."); a guest who could sign in gets `showSignInNudge`; everyone else gets the paywall — [start_reading.dart:121-138](app/lib/features/reading/start_reading.dart).
- Sign-in nudge copy: title "Get a second free reading every day"; body "Guests get 1 free reading a day. Sign in and you get 2, and your Premium follows you to a new phone. Your readings stay on this phone either way."; buttons "Not now" / "Go Premium" / "Sign in" — [start_reading.dart:323-355](app/lib/features/reading/start_reading.dart). It is reached only when the app let the reading start (balance unknown or stale) and the server refused it.
- Follow-up with 0 credits (free): server returns 402 premium_required (not daily_limit) → paywall — [index.ts:560-566](backend/src/index.ts), [reading_screen.dart:131-133](app/lib/features/reading/reading_screen.dart).
- Gentle paths that exist: (a) grey line "No credits left. {0} new credits arrive tomorrow, or go Premium." — [app_state.dart:135-140](app/lib/app/app_state.dart); (b) paywall pack card "Not ready to subscribe?" — [paywall_screen.dart:487-497](app/lib/features/paywall/paywall_screen.dart); (c) paywall bullet "(free: 1 a day, 2 when signed in)" — [paywall_screen.dart:178](app/lib/features/paywall/paywall_screen.dart). The paywall has no sign-in button.
- Error dialogs that say no charge: off-topic dialog ends "No reading or credit was used." — [start_reading.dart:309](app/lib/features/reading/start_reading.dart); network/busy dialog "Can't reach the reader" / "The reader is busy" + "Your cards and question are kept, so you can try again." + Retry — [lib/features/reading/reading_problem.dart:24-52](app/lib/features/reading/reading_problem.dart). Neither network dialog says whether a credit was used (the server refunds; see Q6).

### Inferences
- The most common out-of-credits case for a guest (balance loaded, = 0) skips the sign-in incentive entirely and lands on a paywall whose first bullet says "50 readings a day". This is the harshest path for a hesitant user.
- "arrive tomorrow" is imprecise. Daily credits reset at 00:00 UTC ([backend/src/usage.ts:101-103](backend/src/usage.ts)), which is late afternoon or evening of the same day in the Americas. They are granted only when the app is opened or a reading is charged ([index.ts:695-710](backend/src/index.ts), [main.dart:55](app/lib/main.dart)).
- When the balance is 1, the line reads "No credits left. 1 new credits arrive tomorrow, or go Premium." — a plural bug, since the key does not branch on {0} ([app_state.dart:136-139](app/lib/app/app_state.dart)). Guests are always at 1 a day, so they always see this wording.

### Gaps
- Whether the balance is usually loaded before the user's first tap (which decides between a silent paywall and a server refusal) depends on network timing; not measurable from code.

## Q4. Outdated or inconsistent copy, and cost not shown before spending

### Takeaway
At least 8 visible strings still describe the old pre-credits model ("50 readings a day", "two AI readings a day", "free reading"). Most sit on Premium-selling surfaces: the paywall's first bullet, the You tab Premium card, the Welcome screen and the Guide. They are all translated in 15 languages, so fixing them means updating 15 files.

### Cited Findings
Outdated or inconsistent strings visible with credits ON:
- Paywall bullet 1: "All spreads, follow-ups, 50 readings a day" — [paywall_screen.dart:175](app/lib/features/paywall/paywall_screen.dart). In credit mode, Premium spending is capped at 50 a day but limited by 90-150 credits a month — [backend/src/usage.ts:78,84](backend/src/usage.ts).
- You tab Premium card: "All spreads, follow-ups, 50 readings a day, plus the clarifier card and a look back." (free) / "All spreads, follow-ups, 50 readings a day." (Premium) — [you_screen.dart:225-231](app/lib/features/you/you_screen.dart).
- Welcome Premium perk: "Up to 50 readings a day" / "Read as often as you like" — [welcome_premium_screen.dart:48-52](app/lib/features/paywall/welcome_premium_screen.dart).
- Guide FAQ: "One and three-card spreads are free (two AI readings a day)..." — [guide_screen.dart:72](app/lib/features/guide/guide_screen.dart). Guide FAQ: "Premium adds follow-up questions, a clarifier card..." — [guide_screen.dart:82](app/lib/features/guide/guide_screen.dart). Free users can buy follow-ups with credits ([reading_screen.dart:153](app/lib/features/reading/reading_screen.dart)).
- Locked follow-up labels "Ask a follow-up (Premium)" / "Draw a clarifier card (Premium)" when credits = 0, although credits unlock them — [reading_screen.dart:221,309](app/lib/features/reading/reading_screen.dart).
- Sign-in nudge "Get a second free reading every day" / "Guests get 1 free reading a day. Sign in and you get 2..." uses "reading" rather than "credit", and omits the 10 welcome credits and banking — [start_reading.dart:327-331](app/lib/features/reading/start_reading.dart).
- 429 message "You have used today's free reading." — [api_reading_service.dart:256](app/lib/core/api_reading_service.dart).
- Trial copy "Uses your one-time free premium reading" / "Start free reading" — a credit is still charged (Q6) — [spread_picker_screen.dart:161,220](app/lib/features/read/spread_picker_screen.dart).
- Onboarding "Start with 10 free readings, then get a free one every day." — consistent for guests, but uses "readings" while the rest of the app says "credits", and omits "2 when signed in" — [onboarding_screen.dart:30](app/lib/features/onboarding/onboarding_screen.dart).
- Own-key strings "Premium: unlimited readings with your key" / "Unlimited readings while Premium is active" are behind `OWN_KEY` (off unless built with it), so probably not visible in the live build — [lib/core/user_key_store.dart:6](app/lib/core/user_key_store.dart), [settings_screen.dart:140-147](app/lib/features/settings/settings_screen.dart), [own_key_screen.dart:87](app/lib/features/you/own_key_screen.dart).
- Fallback in `creditLine`: if the server has not answered, `perDay` defaults to 2 — [app_state.dart:125](app/lib/app/app_state.dart). It also shows "No credits left..." before the balance loads, because `creditLine` ignores `creditsKnown` (credits starts at 0) — [app_state.dart:68,132-140](app/lib/app/app_state.dart). A guest offline or at cold start can briefly see "No credits left. 2 new credits arrive tomorrow, or go Premium."
- The declined (422) message is a hardcoded English const, not `tr()`: "A reading could not be made for this question. Try rewording it." — [api_reading_service.dart:266-269](app/lib/core/api_reading_service.dart).
- Dead legacy keys still present in all translations: "Premium: 50 readings a day", "{0} free reading(s) left today", "Free reading used. Sign in for 2 a day, or go Premium.", "Free readings used. Come back tomorrow or go Premium.", old onboarding "Two free readings every day, and a free taste of the longer spreads." — used only when credits are off ([app_state.dart:111-124](app/lib/app/app_state.dart), [onboarding_screen.dart:31](app/lib/features/onboarding/onboarding_screen.dart)). Checked in `assets/i18n/zh_Hans.json`.
- All 21 credit/paywall keys checked (creditLine variants, pack card, "Each question uses {0}.", "1 credit", "No reading or credit was used.", trial copy and others) exist in all 15 locale files — script check over `app/assets/i18n/*.json`.
- Backend comments are also stale: `/v1/followup` is commented "Premium only" ([index.ts:513-515](backend/src/index.ts)); `credit_service.dart` says daily is "(2)" for everyone ([lib/core/credit_service.dart:16](app/lib/core/credit_service.dart)); `FREE_DAILY_CREDITS = 2` is imported but the real amount is `freeReadingsFor` ([usage.ts:74](backend/src/usage.ts), [index.ts:236](backend/src/index.ts)).

Spend points and whether cost is shown before spending:
| Spend point | Cost shown? | Source |
|---|---|---|
| Card of the Day → "Go deeper: reading for this card" | No | daily_card_screen.dart:114-120 |
| Spread picker "Start reading" / "Start free reading" | No ("free" label on a paid action) | spread_picker_screen.dart:216-221 |
| Learn → spread → Scan/Draw sheet | No | library_screen.dart:171-201 |
| Draw "Get my reading" / photo scan completion | No | draw_screen.dart:323; scan_screen.dart:28-81 |
| Look-first dialog "Read" | No | start_reading.dart:210-213 |
| Follow-up send | Yes, "Each question uses 1 credit." | reading_screen.dart:281-292 |
| Clarifier | Yes, "Draw a clarifier card (1 credit)" (not repeated in the sheet) | reading_screen.dart:297-303 |

### Inferences
- The "50 readings a day" claim on the paywall, You card and Welcome screen could be read as overpromising, since Premium credits are 90-150 a month (about 3-5 a day). That makes it both a conversion-trust problem and a likely refund/complaint source.

### Gaps
- Store listing text (App Store description, screenshots) was not in scope; it may repeat the same outdated claims.

## Q5. Premium features a free user can preview vs never sees

### Takeaway
Free users can try premium spreads once, and follow-ups and the clarifier with credits. Three features are shown only as locks or text: the full monthly recap, the look back, and own-key. The look back is never previewed.

### Cited Findings
- Preview / usable by free: one premium-spread reading (trial, credit charged) — [spread_picker_screen.dart:148-167](app/lib/features/read/spread_picker_screen.dart), [backend/src/index.ts:410-417](backend/src/index.ts); follow-ups and the clarifier for 1 credit each — [reading_screen.dart:153-305](app/lib/features/reading/reading_screen.dart).
- Teased with a lock: monthly recap groups and the top cards beyond #1 ("See your full month with Premium") — [collection_screen.dart:186-247](app/lib/features/collection/collection_screen.dart); premium spread chips — [spread_picker_screen.dart:65-70](app/lib/features/read/spread_picker_screen.dart).
- Never seen by free users: the look back ("Looking back" / "About a week has passed. How did this turn out...") — `revisitDue` returns false when not Premium, and the Today "Look back at last week's reading" card depends on it — [app_state.dart:678-685](app/lib/app/app_state.dart), [reading_screen.dart:446](app/lib/features/reading/reading_screen.dart), [today_screen.dart:29-37](app/lib/features/today/today_screen.dart). The 7-day look-back reminder notification is Premium-only — [app_state.dart:652-663](app/lib/app/app_state.dart). Monthly credits and the bigger daily bank are also never previewed.
- Own AI key: Premium-only, behind the `OWN_KEY` build flag ("Available with Premium") — [own_key_screen.dart:74-78](app/lib/features/you/own_key_screen.dart).
- Free-for-all (not gated): Card of the Day, journal notes, history, Your deck, milestones, card library, reminders — [daily_card_screen.dart](app/lib/features/read/daily_card_screen.dart), [reading_screen.dart:316-352](app/lib/features/reading/reading_screen.dart), [collection_screen.dart](app/lib/features/collection/collection_screen.dart).

### Inferences
- The look back is listed as a paywall bullet ("A look back a week later, with a reminder") and a Welcome perk, but a free user has never seen it. A one-time preview (for example on their first reading 7 days later) would make the bullet concrete.

### Gaps
- None material.

## Q6. Backend credit rules and refunds

### Takeaway
The backend matches the stated rules: 10 welcome credits once per owner, 1 a day for guests and 2 when signed in, 1 credit per reading, follow-up or clarifier, banked and never expiring, with a 50-a-day spend cap. Model and network failures refund the credit. Two cases do not: a model refusal (422), and a crisis reply detected in the model output. The one-time premium-spread "free" trial is charged a credit.

### Cited Findings
- Daily amount: `freeReadingsFor` returns `FREE_READINGS_PER_DAY` (2) when signed in or when sign-in is not offered, else `GUEST_READINGS_PER_DAY` (1); sign-in is offered because `APPLE_CLIENT_IDS` is set — [backend/src/index.ts:154-158](backend/src/index.ts), [backend/src/usage.ts:75](backend/src/usage.ts), [backend/wrangler.toml:21-23](backend/wrangler.toml).
- Welcome gift: `WELCOME_CREDITS = 10`, added once per owner key via txn `welcome:${usageKey}` on any grant — [backend/src/credits.ts:12-13](backend/src/credits.ts), [index.ts:233-234](backend/src/index.ts).
- Banking: daily credits stop accruing while 10 days' worth are held (10 for guests, 20 signed in); monthly credits while 2 months' worth are held; bought, referral and creator credits are outside the caps; credits never expire; oldest lot is spent first — [credits.ts:1-13,43-100](backend/src/credits.ts), [index.ts:237-240](backend/src/index.ts).
- Premium monthly credits: annual 150, quarterly 120, monthly 90; spend guard 50 a day for everyone — [usage.ts:78-84](backend/src/usage.ts).
- Charge order: daily spend guard check → grant welcome/daily/monthly → spend 1 credit — [index.ts:254-264](backend/src/index.ts). Readings and follow-ups both cost 1 — [index.ts:431-437,559-567](backend/src/index.ts). A clarifier is sent as a follow-up — [reading_screen.dart:110-129](app/lib/features/reading/reading_screen.dart).
- Premium-spread trial: allowed once per usage key (`countTrial`), then 402 — [index.ts:410-417](backend/src/index.ts), [usage.ts:36-43](backend/src/usage.ts). **The trial reading still goes through `charge()`**, so it costs 1 credit and needs a non-zero balance — [index.ts:431-437](backend/src/index.ts).
- Refunds (`noCharge` = release usage slot + refund lot): upstream/model exception (502) and both output checks failing. In the second case the user gets a stored-text fallback reading and is not charged — [index.ts:441-445,483-488,496-501](backend/src/index.ts). Off-topic model replies are refunded ("No reading or credit was used.") — [index.ts:462-470](backend/src/index.ts). Follow-ups: refunded on bad output (502) and on exceptions — [index.ts:570-574,596-603](backend/src/index.ts). Off-topic and crisis messages caught before the model call are never charged — [index.ts:398-405](backend/src/index.ts).
- **Not refunded:** model refusal → 422 `declined`, slot finalized, credit kept (readings [index.ts:455-458](backend/src/index.ts); follow-ups [index.ts:585-588](backend/src/index.ts)); crisis detected in the model's structured reply → credit kept — [index.ts:471-474](backend/src/index.ts). The service-wide token cap (503) and rate limits (429) are checked before charging, so nothing is spent — [index.ts:418-424,282-288](backend/src/index.ts).
- Credit packs: RevenueCat `NON_RENEWING_PURCHASE` adds `credits_N`; a store refund (`CANCELLATION`) removes the still-unused credits of that purchase — [index.ts:915-931](backend/src/index.ts).
- Sign-in moves install credits to the account key — [index.ts:639-642](backend/src/index.ts). Because the welcome txn is keyed by usage key and the account key is new, the account's first grant adds another `welcome:` gift and a fresh daily claim — [index.ts:233-236,270-274](backend/src/index.ts).

### Inferences
- From the txn keying, a guest who signs in likely gets a second 10-credit welcome gift on the account (20 welcome credits in total). This matters both as an unadvertised sign-in incentive and as an abuse vector (new Apple IDs). Not tested at runtime.
- The server counts the trial per usage key while the app tracks `trialUsed` locally ([app_state.dart:271-272,631](app/lib/app/app_state.dart)). After a reinstall the app shows "Start free reading" again and the server answers 402 → paywall. After sign-in the server would allow a second trial, but the app's local flag blocks it.
- After a 422 decline the user loses a credit and sees only a snackbar with the untranslated text "A reading could not be made for this question. Try rewording it.".

### Gaps
- D1 migrations and RevenueCat dashboard config (product IDs, intro eligibility) were not inspected; `premiumMonthly` plan detection by product was taken from comments and constants only.
