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
