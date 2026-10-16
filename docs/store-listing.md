# Store listing copy (draft)

Decision (owner, 2026-10-16): store name **ShenTarot: AI Scan & Read**. Home-screen name is "ShenTarot". The name has no "card"/"scanner", so the subtitle and keywords carry them. Positioning: people who own a physical deck and don't know how to read what they drew. Limits (third-party sources, confirm in the consoles): Apple name 30, subtitle 30, keywords 100; Google title 30, short description 80, full 4,000. `scripts/check_listing.py` counts every field below.

Claims in this copy must stay true. Remove any line for a feature that is not shipped. Recognition is a baseline model not yet tested on real photos, and subscriptions are not live: **do not publish this copy until the real-device tests in `docs/test-plan.md` pass.**

## Apple App Store
- **Name:** ShenTarot: AI Scan & Read
- **Subtitle:** Tarot card scanner and reader
- **Keywords (comma-separated, no spaces):** reading,meanings,interpretation,spread,journal,daily,deck,reflection,oracle,cards,celtic,cross
- **Promotional text:** Hold a card up to your camera and find out what it means for the question on your mind.
- **Description:**

Got a tarot deck but not sure what you drew? ShenTarot scans your card, tells you which card it is, and explains it in plain language.

HOLD THE CARDS. WE EXPLAIN THEM.
- Point your camera at a card and ShenTarot recognises it on your phone. Your photo is never saved or uploaded.
- Not sure it saw the right card? Pick it from the full 78-card list in a few taps.
- Ask a question, choose a spread for it (love, career, growth or classics), and get a thoughtful reading of your cards.

BUILT FOR BEGINNERS, USEFUL FOR EVERYONE
- Free: one reading every day (one card or Past, Present, Future), plus a free trial reading of any longer spread.
- Free: one AI reading a day with any of the 14 spreads (including the Celtic Cross), scanning, journal, Card of the Day, library, lessons.
- Premium: unlimited readings (fair use), follow-up questions, a clarifier card, and a look back a week later.
- A card library with keywords and upright and reversed meanings for all 78 cards.
- Daily reminder, if you want one.

PRIVATE BY DESIGN
- No account needed.
- Your reading history and journal stay on your phone.
- Your question is used only to write your reading and is not stored on our servers.

ShenTarot is for entertainment and self-reflection only. Readings are written by AI, are not predictions, and are not medical, legal, financial or other professional advice.

SUBSCRIPTION INFO
Premium is an auto-renewing subscription (weekly, monthly or annual; the annual plan may include a free trial). Payment is charged to your Apple ID at confirmation of purchase. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your Apple ID account settings. Privacy Policy: https://yunlong2601.github.io/shentarot-legal/privacy.html  Terms of Use (Apple standard EULA; verify the URL): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

- **Support URL:** https://yunlong2601.github.io/shentarot-legal/
- **Category:** Lifestyle (primary), Entertainment (secondary): decide.

## Google Play
- **Title:** ShenTarot: AI Scan & Read
- **Short description:** Scan your tarot cards and get a plain-language reading of what they mean.
- **Full description:** use the App Store description above, replacing the subscription paragraph with: "Premium is an auto-renewing subscription billed through Google Play. Cancel any time in Google Play > Payments & subscriptions. Privacy Policy: https://yunlong2601.github.io/shentarot-legal/privacy.html". Add the words "tarot card reader", "tarot scanner" and "tarot card meanings" naturally once or twice; Google reads this text for search.

## Screenshot plan (lead with the scan, then the explanation)
1. Camera frame over a card: "Hold the cards. We explain them."
2. "Which card is it?" confirmation sheet.
3. A reading with the cards and the explanation.
4. Card library with meanings.
5. Three-card spread (Premium).
6. Journal and history.
Use only the public-domain card art in the app; no stock photos of other decks.

## Notes and risks
- "Rider-Waite" is deliberately **not** used here (trademark question; see `docs/step1-plan.md` legal notes). Ask whether a plain mention in the description is acceptable before adding it.
- Search words in the name and subtitle must describe the app truthfully; do not add unrelated popular terms (store rules on keyword stuffing: verify).
- Competitors that also scan: Taroter, Thoth Tarot School and others (`docs/competitor-naming.md`). Differentiator to push: explanation for your question + journal + beginner-friendly.
