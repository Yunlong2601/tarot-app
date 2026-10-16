# Tarot Scan App: Step 1 Plan

Status: plan only, no code yet. Reply **continue** to start Phase A.
Date: 2026-10-16. Prices and policies below were checked on the web today; every one is marked with where to re-verify.

## Decisions at a glance

| Area | Decision | Why |
|---|---|---|
| Framework | **Flutter** (Dart) | One codebase, one UI engine on both stores, first-class camera + TFLite plugins, RevenueCat has an official Flutter SDK. React Native is equally viable, but Flutter's pixel-identical rendering suits a design-heavy dark/mystical UI and avoids native-module churn. |
| Backend | **Cloudflare Workers** (TypeScript + Hono) with KV + D1 | Free tier is 100k requests/day; paid is a flat $5/month with 10M requests included. No servers, no cold-start bill. Cheaper than Firebase Functions and less ops than FastAPI. |
| LLM | **Claude Haiku 5.5** (`claude-haiku-5-5`), effort `low` | $0.10 per million input tokens, $0.50 per million output. Good prose quality for short readings at a fraction of a cent. Keep the model name in a backend env var so you can A/B a second model later without an app release. |
| Subscriptions | RevenueCat, entitlement `premium` | Products: weekly, monthly, annual + 7-day free trial on annual. Free under $2,500/month tracked revenue (verify fee above that). |
| Deck | Rider-Waite-Smith (RWS) only, 78 cards, upright + reversed | It is by far the most common physical deck, and its 1909 art is public domain. |
| Accounts | **None** in MVP | Not needed: history lives on device, RevenueCat anonymous IDs handle purchases and restore. No accounts also means no account-deletion requirement. |
| Language | English first; strings in ARB files so Chinese can be added later | |
| Analytics | TelemetryDeck (or PostHog EU, no PII) | Anonymous, no IDFA, no fingerprinting, so no ATT prompt. |

## 1. App name candidates

Searched the App Store, the web and tarot deck publishers on 2026-10-16. This is a quick clash check, not a trademark search.

| Name | Clash check | Verdict |
|---|---|---|
| **Veilscan** | No app or deck found with this name. Nearest is "Ouija Board: The Veil". | **Top pick.** Distinct, says "scan", easy to trademark. |
| **Arcana Lens** | No exact app. "Arcanas: Tarot & Moon Calendar" exists, so it is close. | Good, slight confusion risk. |
| **Querent** | No app found. "Querent" is the tarot word for the person asking. | Nice insider name, but a generic term is weak as a trademark. |
| **Tarot Lens** | No exact app found. | Very searchable (ASO), but descriptive and weak to protect. |
| ~~Cardsight~~ | **Clash:** CardSight AI is an existing card-recognition company. | Avoid. |

Also ruled out: Lumina Tarot and Mirror Tarot are both published physical decks.
**Do not put "Rider-Waite" in the app name, icon or keywords.** U.S. Games Systems holds the "Rider-Waite" trademark. Say "classic 1909 Smith-Waite deck" instead, and have your lawyer confirm this.
Verify: USPTO trademark search (tmsearch.uspto.gov), UK IPO, App Store and Play search for the exact name, and domain availability.

## 2. Market research: what to borrow

| App | Model | What it does well | Borrow |
|---|---|---|---|
| **Labyrinthos** (iOS/Android, a long-running market leader) | Mostly free; AI readings via credits (33 free, 333 for $4.99); $9.99 premium for lessons. | Deep, friendly card info (suit, element, numerology, zodiac), journal, many spreads, lessons with quizzes. | Card detail layout with an element/zodiac/number strip; a journal with a note per reading; a gentle "learn" angle that suits the entertainment framing. |
| **Nebula** (top-grossing spiritual app) | Weekly $7.99 with a 3-day trial; monthly $24.99; 3-month $29.99. Hard paywall right after onboarding. | Long personalised onboarding, then a full-screen paywall with the trial as default. "Soft paywall + free trial" is the most common pattern in the category. | Trial toggle on the annual plan, a highlighted "best value" plan, and a paywall shown at the moment of desire (after the first free reading, on tapping a locked spread), not before the user has seen value. Avoid its aggressive pricing and dark patterns. |
| **Taroter: Tarot Cards Scanner** (direct competitor, 4.7★ from 269 ratings) | $4.99/month, $19.99/year, $24.99 lifetime. | Already scans several RWS cards at once and interprets the spread. | Proves demand. Its reviews complain the scanner sometimes returns nothing and the text is only keywords. **Our edge:** a reliable scan with an always-visible manual fallback, plus a full, personalised AI reading and follow-up questions. |

Also worth a look for visual tone: Co-Star (minimal monochrome typography) and CHANI (warm, calm copy).

**Biggest store risk: Apple Guideline 4.3(b), "saturated categories."** Apple has rejected astrology and card-reading apps as belonging to a saturated category, including a card-reading app in 2026 whose reviewer spent under a minute in it. Mitigation: lead every screenshot and the review notes with the physical-card **scan**, which is uncommon, and give the reviewer step-by-step instructions plus a demo video and printable card images to scan. Verify the current text at developer.apple.com/app-store/review/guidelines (section 4.3).

## 3. Card images, meanings, and the recognition model

### Legal image sources

| Source | What it is | Caveats to verify |
|---|---|---|
| Wikimedia Commons, "Rider-Waite tarot deck" category | Scans of the 1909 Pamela Colman Smith deck (e.g. files named `RWS Tarot 06 Lovers.jpg`). | Check each file page says public domain, and that the scan is of a **1909–1920s printing**, not the 1971+ U.S. Games recolouring. |
| Hugging Face `multimodalart/1920-raider-waite-tarot-public-domain` | 78 cards from a 1920 printing, with text descriptions. | No explicit licence on the page; the PD claim rests on the deck's age. Use the images, rewrite the text. |
| sacred-texts.com: A. E. Waite, *The Pictorial Key to the Tarot* (1910/1911) | Waite's own card meanings, public domain. | Fine as a source for meanings; write modern keywords yourself. |
| Roboflow Universe tarot datasets, github `mixvlad/TarotCards` | Labelled photos/images for training. | Licences vary per dataset (often CC BY 4.0, which needs attribution). Many contain photos of the copyrighted U.S. Games edition; use them for training only after your lawyer's OK, and never display them. |

Copyright status: Smith died in 1951 and Waite in 1942. The deck has been public domain in the US since 1966 (no renewal of the original), and in the UK/EU (life + 70) since 1 January 2022. U.S. Games' copyright covers only its new material (1971 recolouring, card backs, box). Verify with your lawyer, especially for the colour scans you pick.
**Displayed art in the app:** use cleaned 1909 PD scans, or commission original art. Never show images from a modern edition.

### Recognition training plan

1. **Pipeline on device:** find the card's four corners (OpenCV quad detection, or a tiny detector), warp it to a flat 224×320 crop, then classify it. To get reversed vs upright, classify the crop and the crop rotated 180°; the higher score wins.
2. **Model:** MobileNetV3-Small or EfficientNet-Lite0, fine-tuned on 78 classes in Keras, exported to **TFLite int8** (about 3–5 MB). One `.tflite` file runs on both platforms through `tflite_flutter`, so no separate Core ML model is needed.
3. **Training data:** 78 PD scans as anchors, plus heavy synthetic augmentation (perspective, glare, shadows, blur, colour shifts to mimic different printings, random table/cloth backgrounds), about 300 images per card. Then add your own phone photos of 2–3 physical RWS-style decks you own, roughly 10 per card, which is the step that closes the gap to real-world use.
4. **Evaluation:** a held-out set of real photos (5 per card from a deck the model never saw). Target ≥ 95% top-1 accuracy and ≥ 99% top-3.
5. **Fallback:** if the top score is below 0.80, or the gap to the second card is under 0.25, show the top 3 guesses plus "Pick manually" (a searchable grid of all 78). Manual picking is always one tap away on the scan screen.
6. **Privacy:** frames are processed in memory and discarded. No photo is saved or uploaded.

Risk: clone decks (cheap prints, "Universal Waite") vary in colour and borders; augmentation plus your own photos should cover most of them. Non-RWS decks (Thoth, Marseille) will fail and drop to manual, which is acceptable for the MVP.

## 4. Architecture

```
Flutter app ──(HTTPS, signed JWT)──> Cloudflare Worker ──> Anthropic API (Haiku 5.5)
  │  camera → TFLite (on device)       │  auth, rate limit, caps
  │  SQLite history                    │  KV: rate-limit counters, meaning cache
  │  RevenueCat SDK                    │  D1: usage log (tokens), entitlement cache
  └─ local notifications               └─ RevenueCat webhook → D1 (premium status)
```

**Auth without accounts:** on first launch the app proves it is a genuine install (App Attest on iOS, Play Integrity on Android) and gets a short-lived JWT bound to an anonymous install ID, which is also the RevenueCat app user ID. The Worker checks premium status **server-side** (RevenueCat webhook + REST lookup), never trusting the client. A reinstall can reset the free daily count; App Attest/Play Integrity make abuse harder, and the cost of abuse is tiny (see section 5).

**Prompt-injection defence:** the user's question goes only in the user turn, wrapped in a tag and labelled as untrusted text to reflect on, never as instructions. The system prompt fixes the task and refuses medical, legal, financial and self-harm predictions. Input is validated (≤ 300 characters, plain text, control characters stripped), output is capped with `max_tokens`, and cards are sent as IDs that the server maps to names, so the client cannot inject card text. A small server-side check rejects output that leaves the reading format.

**Rate limits:** per install ID: free 1 reading/day; premium 20 readings and 30 follow-ups/day; plus 10 requests/minute burst and a per-IP limit. A global daily token budget acts as a kill switch.

### Folder structure

```
tarot-app/
├── app/                      # Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/              # router (go_router), theme, l10n
│   │   ├── core/             # api client, db, analytics, config
│   │   ├── features/
│   │   │   ├── onboarding/
│   │   │   ├── scan/         # camera, detector, classifier, picker
│   │   │   ├── cards/        # card list + detail
│   │   │   ├── reading/      # spreads, reading, follow-ups
│   │   │   ├── paywall/
│   │   │   ├── history/      # history + journal
│   │   │   └── settings/
│   │   └── data/             # repositories, models (freezed)
│   ├── assets/cards/         # PD images + cards.json
│   ├── assets/models/        # tarot_classifier.tflite
│   └── test/
├── backend/                  # Cloudflare Worker
│   ├── src/ (index.ts, auth.ts, ratelimit.ts, reading.ts, prompts.ts, revenuecat.ts)
│   ├── migrations/           # D1 SQL
│   ├── test/
│   └── wrangler.toml         # no secrets; secrets via `wrangler secret put`
├── ml/                       # training notebooks/scripts, augmentation, eval
├── docs/                     # privacy policy, terms, store checklists, test scripts
└── README.md                 # setup, run, dependency audit
```

### SQLite data model (on device)

```sql
CREATE TABLE readings (
  id            TEXT PRIMARY KEY,         -- uuid
  created_at    INTEGER NOT NULL,         -- unix ms
  spread_type   TEXT NOT NULL,            -- single | three | celtic_cross
  question      TEXT,                     -- optional, stays on device
  interpretation TEXT NOT NULL,
  source        TEXT NOT NULL,            -- scan | manual | mixed
  is_favorite   INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE reading_cards (
  reading_id    TEXT NOT NULL REFERENCES readings(id) ON DELETE CASCADE,
  position      INTEGER NOT NULL,         -- 0-based slot in the spread
  card_id       TEXT NOT NULL,            -- e.g. 'major_00_fool'
  reversed      INTEGER NOT NULL,
  scan_confidence REAL,                   -- null if picked manually
  PRIMARY KEY (reading_id, position)
);
CREATE TABLE follow_ups (
  id            TEXT PRIMARY KEY,
  reading_id    TEXT NOT NULL REFERENCES readings(id) ON DELETE CASCADE,
  created_at    INTEGER NOT NULL,
  question      TEXT NOT NULL,
  answer        TEXT NOT NULL
);
CREATE TABLE journal_entries (
  id            TEXT PRIMARY KEY,
  reading_id    TEXT REFERENCES readings(id) ON DELETE SET NULL,
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL,
  body          TEXT NOT NULL,
  mood          TEXT
);
CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE INDEX idx_readings_created ON readings(created_at DESC);
```

Card data (names, keywords, upright/reversed meanings, element, number) ships as a bundled `cards.json`, not in SQLite. "Delete all my data" in Settings drops these tables.

**Backend D1** stores only: `install_id_hash`, date, request count, input/output tokens, model, and premium status from the RevenueCat webhook. **Questions and readings are never stored on the server.**

### Data collected (and why)

| Item | Where | Why |
|---|---|---|
| Question text + card IDs | Sent to backend and Anthropic per request, not stored by us | To generate the reading. Anthropic's API retention applies; check their current policy. |
| Anonymous install ID (hashed on server) | Backend D1 | Rate limits, daily cap, abuse prevention |
| Purchase status | RevenueCat | Unlock premium, restore purchases |
| Token counts per request | Backend D1 | Cost control |
| Anonymous analytics events (onboarding done, scan success/fallback, paywall view, trial start, purchase) | TelemetryDeck | Product decisions |
| Camera frames | Device memory only | Card recognition; never saved or sent |
| History, journal | Device only | Feature |

### Roadmap (about 10 hours/week)

| Phase | Scope | Hours |
|---|---|---|
| A | Flutter project, theme, go_router navigation, all screens with mock data, CI lint | 8 |
| B | `cards.json` for 78 cards, card list/search, card detail, PD image cleanup | 12 |
| C | Camera, corner detection, TFLite model training + eval, confidence logic, manual picker | 35 |
| D | Worker: auth (App Attest/Play Integrity), validation, rate limits, prompts, Haiku call, usage logging; app reading screen | 22 |
| E | RevenueCat products, paywall, restore, manage-subscription link, server-side entitlement webhook, sandbox tests | 18 |
| F | SQLite history + journal, follow-ups, daily-card notification, accessibility (VoiceOver/TalkBack, dynamic type, contrast), polish | 20 |
| G | Unit tests, manual test scripts, privacy policy and terms drafts, store checklists, screenshots | 15 |
| **Total** | | **≈ 130 h ≈ 13 weeks**, plan 16 weeks with buffer |

Phase C carries the most risk; if the model is weak by hour 25, ship with the top-3 + manual flow and improve after launch.

## 5. LLM cost and unit economics

Model: Claude Haiku 5.5, $0.10 / $0.50 per million input/output tokens (Anthropic API price list, cached 2026-10-06; verify at anthropic.com/pricing). Haiku 5.5 thinks by default and thinking tokens bill as output, so I added a thinking allowance and will set effort to `low`.

| Request | Input tokens | Output (incl. thinking) | Cost |
|---|---|---|---|
| Single-card reading | 1,200 | 700 | $0.0005 |
| 3-card reading | 1,800 | 1,100 | $0.0007 |
| Celtic Cross (10 cards) | 3,000 | 2,100 | $0.0014 |
| Follow-up question | 3,000 | 500 | $0.0006 |

**Per user per month:** free user at the cap (30 readings) $0.014; typical premium user (30 readings + 20 follow-ups) $0.04; heavy premium user (80 readings + 120 follow-ups) $0.14. The daily caps bound the worst case at about $0.70/month.

**Caching:** card meanings are bundled in the app, so they cost nothing to show. On the server, cache the static card-meaning snippets with the system prompt; prompt caching only applies above a minimum prefix size, so measure `cache_read_input_tokens` in Phase D before relying on it. The bigger saving is not caching but caps and short outputs.

**Store fees (verify before pricing):** Apple Small Business Program is 15% for developers under $1M a year. Google Play since 30 June 2026 charges a 10% service fee on subscriptions plus a 5% billing fee in the US/UK/EEA, so about 15% too. Prices also include VAT in the UK/EU, so proceeds there are lower. Verify at developer.apple.com/app-store/small-business-program and support.google.com/googleplay/android-developer (service fees).

**Fixed monthly costs:** Apple developer $8.25 ($99/yr), Cloudflare $5, domain/email about $1, free-user LLM about $5 at roughly 700 free users. That is about **$20/month**. If you also spread a $1,000 legal review over the first year, about **$105/month**. Google's $25 is one-off and already paid. Your own time is not counted.

**Break-even subscribers** (after 15% fee and typical LLM cost):

| Plan | Price | Net per subscriber per month | Break-even at $20/mo | At $105/mo |
|---|---|---|---|---|
| Weekly | $3.99 | $14.66 | 2 | 8 |
| Monthly | $7.99 | $6.76 | 3 | 16 |
| Annual (7-day trial) | $39.99 | $2.80 | 8 | 38 |

**Recommended prices:** weekly **$3.99**, monthly **$7.99**, annual **$39.99** with a 7-day free trial, highlighted as "best value, save 58%". Costs are so low that any price covers them, so these are set by the market: above Taroter ($4.99/mo, $19.99/yr), well below Nebula ($7.99/week, $24.99/mo). Plan to test a $29.99 annual price after launch.

## 6. Store compliance built in

Paywall shows the price, billing period, trial length and auto-renew terms next to the buy button, with Privacy Policy and Terms links and a Restore Purchases button on the same screen. Settings has "Manage subscription" (opens the Apple/Google subscription page), restore, privacy, terms, a disclaimer ("For entertainment and self-reflection only…") and "Delete all my data". Camera permission text: "Used to recognise the tarot card you hold up. Photos are never saved or uploaded." No accounts, so no account deletion is needed. The full App Store Connect and Play Console checklists come in Phase G. Verify current rules at developer.apple.com/app-store/review/guidelines (3.1.2 subscriptions, 5.1 privacy) and the Play Console Policy Center (Subscriptions, Data safety).

## 7. Assumptions and risks

- Apple 4.3(b) "saturated category" rejection is the top risk (see section 2).
- Recognition accuracy on cheap clone decks is unproven until Phase C.
- No-account free cap can be reset by reinstalling; accepted because the cost is about $0.0005 per reading.
- RevenueCat's fee above $2,500/month was not confirmed (sources disagree); check revenuecat.com/pricing.
- Your ChatGPT, Antigravity and Claude Pro subscriptions do **not** include API access; the backend needs a separate Anthropic API key with billing.

## I need to do

1. Pick the app name; run the trademark and store-name checks above.
2. Create an Anthropic API account (console.anthropic.com), add billing, set a monthly spend limit, create a key (it goes into the Worker with `wrangler secret put`, never in the app).
3. Create Cloudflare and RevenueCat accounts; enrol in Apple's Small Business Program.
4. Install Flutter, Xcode, Android Studio on your Mac (I will give exact commands in Phase A).
5. Buy or find 2–3 physical RWS-style decks for training photos (Phase C).
6. Book a lawyer to review: image licensing, "Rider-Waite" trademark wording, privacy policy, terms.
7. Set up a support email and a simple website for the privacy and terms URLs.
8. Choose the brand tone (I assume calm, mystical, modern, dark theme) and whether to commission original art.

## Sources

- [Taroter: Tarot Cards Scanner (App Store)](https://apps.apple.com/app/id1597650532)
- [Labyrinthos app review (Bustle)](https://www.bustle.com/life/labyrinthos-tarot-reading-app-review)
- [Nebula review 2026 (Republic World)](https://www.republicworld.com/initiatives/nebula-app-review-2026-features-cost-and-who-its-for-2026-09-16-137105)
- [Nebula paywall (Adapty paywall library)](https://adapty.io/paywall-library/nebula-horoscope-astrology/)
- [Astrology and tarot app patterns (ScreensDesign)](https://screensdesign.com/categories/astrology-tarot-apps/)
- [Tarot Pro (App Store)](https://apps.apple.com/app/id311858101)
- [Rider–Waite Tarot (Wikipedia)](https://en.wikipedia.org/wiki/Rider%E2%80%93Waite_Tarot)
- [Is Rider-Waite-Smith public domain? (Global Spiritual Studies)](https://globalspiritualstudies.com/is-rider-waite-smith-public-domain/)
- [1920 Rider-Waite public-domain dataset (Hugging Face)](https://huggingface.co/datasets/multimodalart/1920-raider-waite-tarot-public-domain/discussions)
- [Rider-Waite dataset mirror (HyperAI)](https://hyper.ai/en/datasets/33623)
- [mixvlad/TarotCards (GitHub)](https://github.com/mixvlad/TarotCards)
- [Apple forum: 4.3(b) rejection of a card-reading app](https://developer.apple.com/forums/thread/840388)
- [Apple rejects horoscope app (iMore)](https://imore.com/apple-rejects-developers-horoscope-app-says-app-store-has-enough)
- [App subscription billing in 2026 (DEV Community)](https://dev.to/mr_manushukla/app-subscription-billing-in-2026-3-platform-changes-that-decide-what-your-app-keeps-54l8)
- [Cloudflare Workers pricing](https://developers.cloudflare.com/workers/platform/pricing/)
- [RevenueCat free plan (CostBench)](https://costbench.com/software/subscription-billing/revenuecat/free-plan/)
- [CardSight AI (name clash)](https://www.einpresswire.com/article/866750935/cardsight-ai-launches-invite-only-beta-for-ai-powered-trading-card-identification-infrastructure-platform)
- [Lumina Tarot deck (name clash)](https://www.tarot.nl/en/product/lumina-tarot)
- [Arcanas: Tarot & Moon Calendar (App Store)](https://apps.apple.com/kr/app/arcanas-ai-%ED%83%80%EB%A1%9C-%EB%A6%AC%EB%94%A9/id6737407513?l=en-GB)

---

## Addendum (2026-10-16): Singapore-based student developer

New context: you are a polytechnic student in Singapore. Nothing below is legal or tax advice. Each item is something to **verify** at the named source.

### Added to "I need to do"
9. **Check your school rules.** Some polytechnics have policies on commercial work, IP ownership and conflicts of interest (more so with scholarships or bonds). Read your student handbook or ask your department before you charge money.
10. **Choose how you publish: individual or business.** Both Apple and Google allow individual accounts. A sole proprietorship registered with ACRA (bizfile.gov.sg) or a company needs more paperwork but keeps your personal name off the store listing. Apple shows the seller name; Apple's organisation account needs a D-U-N-S number. Verify at developer.apple.com (Enrollment) and Play Console help.
11. **Google individual accounts may need a testing period before production.** Google has required newer personal developer accounts to run a closed test with a minimum number of testers for a minimum number of days before applying for production access. This affects the timeline, so confirm the current numbers in Play Console help and recruit testers (classmates) before Phase G.
12. **Tax and payout set-up.** In App Store Connect: accept the Paid Applications agreement, add a Singapore bank account, and complete the tax forms. As a non-US person you will likely file a US W-8BEN form on Apple and Google. Singapore has no general income tax treaty with the US, so ask a tax adviser how withholding applies. In Google: create a payments profile and a merchant account. Subscription income is generally taxable in Singapore; check IRAS (iras.gov.sg) on how to declare it. GST registration is only required above the S$1M turnover threshold (verify).
13. **Prices in Singapore.** Apple and Google let you set prices per storefront. Consumer prices in Singapore include 9% GST, which the stores handle for app sales (verify in the store tax docs). Plan SGD price points (for example S$4.98 weekly, S$9.98 monthly, S$49.98 yearly) after you see the stores' price tiers. My break-even table used USD.

### Compliance notes
- **PDPA (Singapore).** The Personal Data Protection Act applies to organisations that collect personal data, which can include a one-person business. Questions typed by users may contain personal details. Points to check at pdpc.gov.sg: consent and notification of purpose in the privacy policy, a named contact for data queries (the PDPA requires a Data Protection Officer role, which can be you), data breach notification, and the rules for sending data overseas (our backend and the AI provider are outside Singapore). Keep the "no questions stored on our server" design from the plan; it makes compliance easier.
- **Privacy policy** must also match Apple's privacy labels and Google's Data safety form. If you launch in the EU/UK later, GDPR applies on top.
- Google may require you to show a contact address and phone on the store page for some account types (verify "trader status"). A business address or virtual office avoids showing your home address.

### Student-friendly cost notes
- Apple Developer Program is US$99 a year and fee waivers are generally for nonprofits, schools and governments, not individual students (verify). Google's one-off US$25 is already paid.
- Everything else starts free: Cloudflare Workers free tier (100,000 requests/day), RevenueCat free below US$2,500/month tracked revenue (confirm), Flutter and TelemetryDeck's free tier. Check the GitHub Student Developer Pack for extra perks (education.github.com/pack).
- Set a hard monthly spend limit (for example US$10) in the Anthropic console from day one, and a global daily token cap in the Worker.
- Realistic fixed cost until launch: about US$99 (Apple) plus roughly US$1/month for a domain. The ~US$20/month figure in section 5 applies once the app is live.
