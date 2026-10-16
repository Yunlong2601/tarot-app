# Design notes (UI)

Reference: the owner's wireframe screens (landing, tabs, library, you, paywall, sign-in, guide quiz). We build our own version with our own art, text and name; nothing is copied from another app.

## Structure (done)
- **Tabs:** Read, Guide, Library, You.
- **Read** (landing): hero backdrop, "SHENTAROT", "Hold the cards. We explain them.", one big button. The arrows next to it switch between **Photo reading** (scan a physical deck, then the existing scan flow) and **Digital card reading** (app draws cards; tap each face-down card to flip). A spread chip opens a picker.
- **Guide:** how to use the app, plus a short tarot primer (original text). The "Guide match" quiz from the wireframe is NOT built (owner: the guide teaches how to use the app).
- **Library:** Spreads | Cards switch. Spreads are one, three and Celtic Cross; picking a free one returns to Read with it selected, Premium ones open the paywall. Cards is the 78-card browser.
- **You:** guest card (+ "Sign in" demo), Reading History, Premium, restore/manage, reminder, legal, delete data.
- **Sign-in:** a **demo page only** (closable, skippable, buttons do nothing but explain). There are no accounts. Before release either build real sign-in (needs Sign in with Apple if any third-party login is offered, in-app account deletion, privacy-policy and backend changes) or remove the "Sign in" button in `you_screen.dart`.
- **Not built from the wireframe:** credits, Invite friends, Share & earn, topic-based spreads (Love, Career, Growth, Classics), daily guidance card, language picker, "Match later" quiz. If credits or referral rewards are added, check the stores' rules on rewards and in-app purchase of digital goods first (verify in the guidelines).

## Landing artwork and video
- Add your own portrait image as `app/assets/hero/hero.jpg` (about 1170x2532). Until then a painted starry placeholder shows (`lib/features/read/hero_background.dart`).
- Only use art you made or have the rights to. AI-generated art: check the generator's terms and keep a record of how it was made.
- Video: planned. Add the `video_player` package, put a short looping, muted MP4 (a few MB) under `app/assets/hero/`, and play it behind the same gradient in `HeroBackground`; keep the still image as the poster and fallback, and respect the device's "reduce motion" setting.

## Look
Dark theme with a gold accent (`lib/app/theme.dart`). The card back used in digital readings is drawn in code (`CardBack`), original design.

## Brand polish (done)
- `lib/app/brand.dart`: drawn logo mark (card + eye), gradient wordmark "SHENTAROT", lockup, card back with glow, and a gently floating fan of card backs. Animations stop when the device asks to reduce motion.
- Serif headlines (Georgia on iOS, system serif on Android); body stays system sans. Glow around the onboarding icons and cards.
- The landing shows the card fan until you add `assets/hero/hero.jpg`.
- To look at the app without tapping: `flutter build ios --simulator`, then `xcrun simctl install booted build/ios/iphonesimulator/Runner.app` and `xcrun simctl launch booted com.example.shentarot`, `xcrun simctl io booted screenshot out.png`.

## Reading flow (owner's second wireframe set, built 2026-10-16)
Read -> **Ask** (question, starters, wording nudge, or skip) -> **Select a Spread** (carousel, best match for the question marked Recommended, layout diagram, free / free trial / Premium badge) -> **draw**: Digital (tap the deck to place cards into the numbered slots, then flip each) or Photo (scan or pick manually, slot by slot) -> reading with a layout view for 5+ cards and section titles (In short, one block per card, To reflect on, A small step). Library > Spreads is the same catalog by category (Love, Career, Growth, Classics); tapping one starts Ask with it already chosen.

Spread catalog: 14 spreads, defined in `app/lib/data/spreads.dart` and `backend/src/spreads.ts` (same ids and position labels; a backend test keeps wording about the user's own side only).

Free rules: **One-Card** and **Past, Present, Future** are free (one reading per day). Any other spread is Premium, with **one free trial reading per install** (tracked on the phone and enforced by the backend).

Changed from the wireframe on purpose: "Ex, Reconciliation" became "Healing & Reconnection" with positions about the user; "Their Feelings & Thoughts About Me" became "What I Bring to This Connection"; the "Three-Card Yes/No Method" is not offered (the cards cannot answer yes or no); "Love & Relationship" is a trial spread, not free. Not built: the Guide-match quiz, credits, referrals, a streaming reading screen (we show a spinner), Wirth/other named variants beyond the five-card cross.

## Theme: black and gold (owner decision, 2026-10-16)
Neutral black (`#0B0B0B`) and charcoal surfaces with a pale warm gold accent (`#EBD48C`), per the owner's wireframes. Defined in `app/lib/app/theme.dart` (`AppColors`): no purple or violet anywhere. Headlines are bold sans like the wireframes (the earlier serif experiment was removed). Selected chips, segments and tabs use a dark gold tint with gold text. The app icon, adaptive icon and launch screen are black and gold too (regenerate with `flutter test tool/make_icon_test.dart && dart run flutter_launcher_icons`).

## Disclaimer placement (owner decision, 2026-10-16)
The entertainment-only disclaimer appears **only inside the Terms of Use** (You > Terms of Use, boxed at the top). It is not on any other screen, including readings. Risk to be aware of: the project rules said a disclaimer should be visible wherever readings appear and the stores may expect it; the owner chose to keep it in the Terms only. The backend still returns a `disclaimer` field that the app ignores, so one line can be restored in `reading_screen.dart` if a store reviewer asks.
