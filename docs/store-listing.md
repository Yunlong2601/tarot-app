# Store listing copy

## 1.0.1 App Store listing (draft, 2026-10-23)

Applied to the 1.0.1 version in App Store Connect once 1.0 is approved (1.0's text is locked while it is in review). Based on `docs/app-improvement-report.md`: lead with the whole-spread photo (competitors scan one card), free meanings, no surprise charges, original art. Check each claim is still true before submitting.

- **Name:** ShenTarot: AI Lens (unchanged)
- **Subtitle:** Tarot card scanner and reader (unchanged)
- **Keywords (96/100):** meanings,spread,photo,journal,daily,deck,yes,no,oracle,cards,celtic,cross,learn,reading,beginner
- **Promotional text (105/170):** Lay out your cards, take one photo, and get a reading about your question. All 78 card meanings are free.
- **Description (2632/4000):**

Shuffled your deck and not sure what the cards are saying? Take one photo of your spread. ShenTarot names every card and reads them together for the question on your mind.

ONE PHOTO, YOUR WHOLE SPREAD
- Laid out three cards or a full Celtic Cross? One photo names every card and whether it is reversed. You check the cards before your reading.
- Prefer one card at a time? Point the camera at a card; it is recognised on your phone and that photo is never uploaded.
- Or pick cards from the 78-card list in a few taps.

A READING ABOUT YOUR QUESTION, NOT A TEXTBOOK DEFINITION
- Ask anything, choose a spread (Yes or No, love, career, growth or the classics) and get a reading that ties each card to its place and to your question.
- Honest about hard cards. Readings point to what you can do, never just what you want to hear.

FREE MEANS FREE
- All 78 card meanings, upright and reversed, are free. No account needed.
- 10 reading credits to start, plus a free credit every day (2 when you sign in with Apple).
- Need more? Buy a small credit pack once, or go Premium.
- No ads. No surprise charges: cancel anytime, and we can remind you 2 days before a trial ends.

PREMIUM
- Every spread, including the 5, 7 and 10-card Celtic Cross.
- 90 to 150 reading credits every month by plan; unused credits roll over.
- Follow-up questions, a clarifier card and a look back a week later.

PRIVATE BY DESIGN
- Your reading history and journal stay on your phone.
- Your question is used only to write your reading and is not stored on our servers.
- A spread photo is sent once to name the cards, then deleted.

THE ORIGINAL 1909 ART
The card pictures are Pamela Colman Smith's 1909 illustrations, in the public domain. Not AI-generated.

IN YOUR LANGUAGE
English, 简体中文, 繁體中文, 日本語, 한국어, Español, Português, Français, Deutsch, Italiano, Русский, Türkçe, Bahasa Indonesia, ไทย, Tiếng Việt and العربية.

ShenTarot is for entertainment and self-reflection only. Readings are written by AI, are not predictions, and are not medical, legal, financial or other professional advice.

SUBSCRIPTION INFO
Premium is an auto-renewing subscription (monthly, every 3 months or annual; the annual plan may start with a lower first-month price). Payment is charged to your Apple ID at confirmation of purchase. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your Apple ID account settings. Credit packs are one-time purchases and never expire.
Privacy Policy: https://shentarot.com/privacy
Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

**Screenshot order for 1.0.1:** 1. a spread photo with the cards named ("One photo, your whole spread"), 2. a reading that quotes the question, 3. the free card library ("All 78 cards free"), 4. the Yes or No spread, 5. languages. The current screenshots show the old 4-tab layout.

---

# Earlier draft (1.0)

Store name (App Store Connect record, 2026-10-17): **ShenTarot: AI Lens** (18 characters; it replaced the 2026-10-16 pick "AI Scan & Read"). Home-screen name is "ShenTarot". The name has no "card"/"scanner", so the subtitle and keywords carry them. Positioning: people who own a physical deck and don't know how to read what they drew. Limits (third-party sources, confirm in the consoles): Apple name 30, subtitle 30, keywords 100; Google title 30, short description 80, full 4,000. `scripts/check_listing.py` counts every field below.

Claims in this copy must stay true. Remove any line for a feature that is not shipped. Recognition is a baseline model not yet tested on real photos, and subscriptions are not live: **do not publish this copy until the real-device tests in `docs/test-plan.md` pass.**

## Apple App Store
- **Name:** ShenTarot: AI Lens
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
- Free: two AI readings every day with the one-card and three-card spreads, plus one free try of a longer spread. Scanning, Card of the Day, the card library and lessons are free too.
- Premium: all spreads, follow-ups, 50 readings a day (all 14 spreads including the Celtic Cross), plus a clarifier card and a look back a week later.
- A card library with keywords and upright and reversed meanings for all 78 cards.
- Daily reminder, if you want one.

PRIVATE BY DESIGN
- No account needed.
- Your reading history and journal stay on your phone.
- Your question is used only to write your reading and is not stored on our servers.

ShenTarot is for entertainment and self-reflection only. Readings are written by AI, are not predictions, and are not medical, legal, financial or other professional advice.

SUBSCRIPTION INFO
Premium is an auto-renewing subscription (monthly, every 3 months or annual; the annual plan may start with a lower first-month price). Payment is charged to your Apple ID at confirmation of purchase. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your Apple ID account settings. Privacy Policy: https://yunlong2601.github.io/shentarot-legal/privacy.html  Terms of Use (Apple standard EULA; verify the URL): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

- **Support URL:** https://yunlong2601.github.io/shentarot-legal/
- **Category:** Lifestyle (primary), Entertainment (secondary): decide.

## Google Play
- **Title:** ShenTarot: AI Lens
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
