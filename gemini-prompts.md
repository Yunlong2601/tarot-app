# ShenTarot: Google Play listing pack (Gemini prompts + text)

Written 2026-10-16. App: **ShenTarot: AI Lens**, US English, Google Play.
Colours read from `app/lib/app/theme.dart` on branch `google-play-prep` (the black-and-gold theme).

## 0. Read this first (policy points that decide the workflow)

1. **Screenshots must be the real app.** Google: "Screenshots must demonstrate the actual in-app or in-game experience" and "Use captured footage of the app or game itself." So Gemini makes only the **background, frame and lighting**. The phone screen inside is a real screenshot you paste in with an editor (Canva, Figma, Photopea). Never let Gemini draw or "improve" app UI.
2. **Feature graphic and icon can be fully generated**, within the rules in section 1.
3. **Text: keep it short and add it yourself.** Gemini often garbles letters. Ask it for empty space, then type captions in the editor using a real font. If you do let Gemini write the word "ShenTarot", zoom in and check every letter.
4. **Card art must be original.** The app uses public-domain 1909 Pamela Colman Smith scans. Gemini art should be abstract or original gold line art (eyes, moons, stars, card backs), never a re-drawing of a modern deck, and not a copy of a specific 1909 card scene either (it tends to drift towards modern recoloured decks). Never write "Rider-Waite" anywhere.
5. **No health, therapy, healing or future-prediction claims.** The app is entertainment and self-reflection only.
6. **Claims must be true in the build you upload.** Before publishing, delete any caption or line for a feature not in that build (scan recognition is still a baseline model; subscriptions must be live in Play Console).

## 1. Asset rules (checked 2026-10-16)

Sources:
- A: Play Console Help, "Add preview assets to showcase your app" https://support.google.com/googleplay/android-developer/answer/9866151?hl=en (no last-updated date on the page)
- B: Android Developers, "Google Play icon design specifications" https://developer.android.com/distribute/google-play/resources/icon-design-specifications
- C: Play Console Help, "Create and set up your app" https://support.google.com/googleplay/android-developer/answer/9859152?hl=en
- D: Play Console Help, "Metadata" policy https://support.google.com/googleplay/android-developer/answer/9898842?hl=en

| Asset | Required? | Rules | Source |
|---|---|---|---|
| App icon | Yes | 512 x 512 px, 32-bit PNG (alpha allowed), sRGB, max 1024 KB. Full square: Google applies the rounded corners (30% radius) and the drop shadow, so do not round corners or add an outer shadow. Prefer no transparency. No text or badges for ranking, price, deals or Play programs. | A, B |
| Feature graphic | Yes | 1024 x 500 px, JPEG or 24-bit PNG (no alpha). Keep logo, name and focal point towards the centre; avoid "cutoff zones" (Google gives no pixel numbers; I use a centre safe box of about 840 x 400, which is my assumption). No "Best", "#1", "Top", "New", "Free", "Discount", "Sale", no rankings or testimonials, no store badges. Device imagery discouraged. | A |
| Phone screenshots | Yes: at least 2 (across device types), up to 8 per device type | JPEG or 24-bit PNG (no alpha). Each side 320 to 3840 px; the long side at most twice the short side. For promotion eligibility: at least 4 screenshots, 9:16 portrait at minimum 1080 x 1920. Real app only; no fingers or hands on the device; tagline at most 20% of the image; no rankings, awards, calls to action ("Download now", "Try now"), store badges, or notifications in the status bar; nothing stretched or blurry; add alt text to each. | A |
| 7-inch tablet screenshots | Optional | Listed under "Large screens": 1080 to 7680 px, 9:16 portrait or 16:9 landscape, and "Exclude additional text that is not part of your core app experience" (so no captions). Must be captured on a tablet (or tablet emulator), not a stretched phone image. Page does not give separate 7-inch vs 10-inch numbers. | A |
| 10-inch tablet screenshots | Optional | Same as 7-inch. | A |
| Title | Yes | 30 characters max. No emojis, no ALL CAPS unless part of the brand, no ranking or price words. | C, D |
| Short description | Yes | 80 characters max. | C |
| Full description | Yes | 4000 characters max. No unattributed testimonials, no keyword lists, no repeated keywords, no ALL CAPS, no emojis or special-character runs. | C, D |

Not verified: Gemini's own output sizes. Gemini usually returns images smaller than or not exactly at these sizes, so always export the final file from your editor at the exact pixel size. You can generate at 16:9 or 21:9 for the feature graphic and crop to 1024 x 500; 9:16 for screenshots; 1:1 for the icon.

## 2. Brand sheet (paste into any prompt when Gemini drifts)

```
Brand: ShenTarot. Mood: quiet, premium, mystical but modern; calm and confident, not spooky, no horror.
Palette (strict): near-black background #0B0B0B, charcoal #151515, warm charcoal #1F1D19,
pale gold #EBD48C (main accent), light gold #F6E8B8 (highlights), deep gold #C9A24D (shadows of gold),
muted warm grey #A9A59B (secondary details). No purple, no blue, no neon, no rainbow.
Style: flat-to-soft-3D gold line art, thin elegant strokes, soft gold glow, subtle film grain,
generous negative space, symmetrical composition.
Motifs allowed: a tarot card outline with an all-seeing eye and rays (the app's logo),
crescent moons, small four-point stars, fine constellations, a fan of face-down card backs
with geometric gold borders.
```

Shared negative list (add to every prompt as "Avoid: ..."):

```
Avoid: any text or letters unless I ask for them; misspelled or garbled words; fake star ratings,
review quotes, award badges, laurels, "#1", "best", "top", "new", "free", "sale";
Google Play, App Store, Android or any brand or competitor logos; hands or fingers holding or tapping
a phone; invented app screens or UI; the words "Rider-Waite" or "Rider"; copies or lookalikes of
any published tarot deck (Rider-Waite-Smith recolours, Thoth, Wild Unknown, Modern Witch, Light Seer's,
or any other); recognisable card scenes such as a fool at a cliff, a tower struck by lightning,
or a skeleton on a horse; skulls, blood, demons, horror; crystal balls with fortune-teller clichés;
medical or healing symbols; purple or neon colour schemes; watermarks; blurry or low-resolution output.
```

## 3. App icon (512 x 512)

Recommendation: your current icon (gold card outline with an eye and rays on black, `play-upload/icon-512.png`) already fits the rules and matches the app's launcher icon. Keep it unless you want a refined version. If you change it, the in-app launcher icon must be regenerated too (a code task; ask me), so users see the same icon on Play and on their home screen.

**Primary prompt**
```
Create a square 1:1 app icon, 1024x1024, for a tarot reading app called ShenTarot.
Centered symbol: a single upright tarot card drawn as a thin pale-gold (#EBD48C) outline with
slightly rounded corners and a fine inner border; inside it an almond-shaped eye with a round iris,
surrounded by short evenly spaced gold rays above and below. Small gold dots in the four inner corners.
Background: fills the entire square edge to edge, near-black #0B0B0B with a very soft warm radial glow
(#1F1D19) behind the card. Flat vector style with a subtle gold glow, no gradients on the lines,
crisp edges, symbol occupies about 65% of the height, perfectly centered and symmetrical.
Do not round the corners of the image, no outer drop shadow, no border around the image, no text.
[paste shared negative list]
```

**Variation 1: crescent and eye**
```
Square 1:1 app icon, 1024x1024, full-bleed near-black #0B0B0B background with a faint warm glow.
Centered: a slim pale-gold (#EBD48C) tarot card outline tilted 8 degrees, with a crescent moon cradling
an open eye at its centre and three tiny four-point stars above. Thin elegant line art, light-gold
(#F6E8B8) highlights, deep-gold (#C9A24D) inner shading. Symmetrical, symbol about 65% of the height.
No text, no rounded image corners, no outer shadow.
[paste shared negative list]
```

**Variation 2: card fan**
```
Square 1:1 app icon, 1024x1024, full-bleed near-black #0B0B0B background.
Centered: three face-down tarot card backs fanned out, outlined in pale gold #EBD48C; the middle card
is in front and carries a small open-eye emblem with rays; the side cards show fine geometric gold borders.
Soft gold rim light, simple shapes that stay readable at 48 pixels. No text, no rounded image corners,
no outer shadow.
[paste shared negative list]
```

**Fix-up edit prompts**
- Too detailed at small size: `Simplify: thicker gold lines (about 3% of the width), remove the small dots and half the rays, keep the eye and card outline only.`
- Gemini rounded the corners or added a frame: `Extend the black background to all four edges and corners of the square. No rounded corners, no border, no outer shadow.`
- Colour drifted: `Recolour all lines to exactly #EBD48C pale gold and the background to #0B0B0B. Remove any purple or blue.`
- Off-centre: `Center the card exactly in the middle, with equal space on left and right and top and bottom.`
- Text appeared: `Remove all letters and text from the image.`

Export: 512 x 512 PNG, sRGB, under 1024 KB, no transparent pixels.

## 4. Feature graphic (1024 x 500)

Plan: art on the right and left edges, centre kept calm. Put "ShenTarot" and a 3-to-5-word line in the centre **as real text in your editor** (recommended), or ask Gemini for it and check the spelling.

Suggested on-graphic text (pick one): `Scan a card. Understand it.` / `Your cards, explained.` / `Hold the cards. We explain them.`
Do not use: Free, New, Best, #1, Top, AI-powered rankings, or any price.

**Primary prompt**
```
Wide banner, 2.05:1 aspect ratio (generate 21:9 or 16:9 and I will crop to 1024x500).
Near-black #0B0B0B background with subtle film grain and a soft warm gold glow in the centre.
Left third: a fan of five face-down tarot card backs with fine geometric pale-gold (#EBD48C) borders,
softly lit, slightly out of focus at the outer edge.
Right third: a single upright tarot card outline in pale gold with an open eye and short rays at its
centre, with a faint gold glow, plus a few tiny four-point stars and a thin crescent moon.
Centre: leave a clean, empty dark area about 45% of the width for a title I will add later.
Keep every important shape inside the central 85% of the width and 80% of the height.
Elegant gold line art, premium and calm, no people, no phones, no text.
[paste shared negative list]
```

**Variation 1: constellation sky**
```
Wide banner, 21:9. Night-black #0B0B0B sky with very fine pale-gold (#EBD48C) constellation lines
and small four-point stars forming a soft arc across the top. Bottom centre: three face-down tarot
cards lying in a row on a dark charcoal (#151515) cloth, gold borders catching warm light.
Leave the middle band empty and dark for a title. Calm, minimal, premium. No text, no people, no phones.
[paste shared negative list]
```

**Variation 2: with title (only if you want Gemini to try the text)**
```
Wide banner, 21:9, near-black #0B0B0B background. Left: the ShenTarot logo, a tarot card outline with an
open eye and rays in pale gold #EBD48C. To its right, centered vertically, the word "ShenTarot" in an
elegant serif typeface, light gold #F6E8B8, and under it in a smaller clean sans-serif, muted grey
#A9A59B: "Your cards, explained." Spell exactly: S-h-e-n-T-a-r-o-t. Only these words, nothing else.
Faint gold stars on the far right. Generous margins, all text in the central area.
[paste shared negative list]
```

**Fix-up edit prompts**
- Garbled letters: `Remove all text from the image and leave that area as clean dark background.` (then add text in the editor)
- Wrong spelling but layout good: `Change the title text to exactly "ShenTarot" (capital S, capital T, no space). Keep font, size and position.`
- Content too close to edges: `Zoom out by 15% and extend the dark background on all sides so nothing important is near the edges.`
- Too busy: `Remove half of the stars and the moon; keep the card fan and the eye card; more empty space in the centre.`
- Looks like a known deck: `Replace the card faces with plain face-down card backs with simple geometric gold borders.`

Export: 1024 x 500, JPEG or PNG without transparency. Check it looks fine with the outer 10% cropped.

## 5. Phone screenshots (2 to 8; aim for 6, at least 4 for promotion eligibility)

### 5a. Capture real screenshots first
The four in `play-upload/screenshots/` are 1080 x 1920 and real, which is good, but they show a notification icon in the status bar (Google says no notifications) and none shows the scan or a full reading, which are the main features. Recapture from the release build on an emulator or phone with a clean status bar (Android demo mode: Developer options, "System UI demo mode", or ask me for the adb commands).

Suggested set and caption (captions are added by you in the editor, max 20% of image height):

| # | Real screen to capture | Caption |
|---|---|---|
| 1 | Camera scan with a card in the frame | Hold up a card. We'll name it. |
| 2 | "Which card is it?" confirm or the card picker | Not sure? Pick from all 78 cards |
| 3 | A reading: "In short" panel and card panels | A clear reading for your question |
| 4 | Spread choice (love, career, growth, classics) | Choose a spread for your question |
| 5 | Card of the Day | A card to reflect on each day |
| 6 | Library card detail (upright and reversed) | Learn every card's meaning |
| 7 | Guide lessons | New to tarot? Start here |
| 8 | History / journal | Keep your readings and notes |

Only use 3 to 8 for features in the build. Mark Premium features honestly if a caption shows one (for example add "Premium" in small text).

### 5b. Gemini makes the background, you place the screenshot
Final canvas: 1080 x 1920 (9:16). Layout: caption block top 15-18%, phone frame below it, about 80% of the canvas width.

**Primary prompt (background with empty phone frame)**
```
Vertical 9:16 poster background, 1080x1920, for an app store screenshot.
Near-black #0B0B0B background with a soft warm gold (#EBD48C at low opacity) radial glow in the
lower centre and a few tiny pale-gold four-point stars near the top corners.
Centered in the lower 80%: a modern, minimal, frameless smartphone seen straight-on, thin dark charcoal
(#151515) bezel, its screen a flat pure black rectangle (completely empty, no interface, no reflections)
so I can paste my own screenshot into it. Top 18% of the image: empty dark space for a caption.
No hands, no people, no text, no logos, no brand-specific phone details.
[paste shared negative list]
```

**Variation 1: no device (screenshot floats on a card)**
```
Vertical 9:16, 1080x1920. Near-black #0B0B0B background with subtle grain. A rounded rectangle panel
(about 82% of the width, 78% of the height, lower part of the image) with a thin pale-gold (#EBD48C)
outline and a soft gold glow, its inside flat pure black and completely empty. Behind the panel, faint
gold line art of a crescent moon and a few stars. Top 18% empty for a caption. No text, no UI, no hands.
[paste shared negative list]
```

**Variation 2: set of matching backgrounds (keeps the 6 to 8 screenshots consistent)**
```
Create 4 vertical 9:16 backgrounds in the same style, as a matching set: near-black #0B0B0B with a soft
gold glow, each with a different small pale-gold line motif in the top corners (1: crescent moon,
2: three stars, 3: open eye with rays, 4: fanned card backs). Each has an identical empty flat-black
phone-sized rectangle with a thin gold outline in the lower 80% and empty space at the top for a caption.
No text, no UI, no hands.
[paste shared negative list]
```

**Placing the screenshot (in your editor)**
1. Open the background at 1080 x 1920.
2. Paste the real screenshot, scale it proportionally (lock aspect ratio) to fit the empty screen; round its corners to match.
3. Type the caption in the top area: serif or clean sans font, light gold #F6E8B8, about 64-80 px, max two lines.
4. Export PNG or JPEG, no transparency, 1080 x 1920.

If you want Gemini to do the placing anyway, upload the background and the screenshot and use:
```
Place the second image exactly inside the empty black phone screen of the first image. Do not redraw,
restyle, sharpen, translate or change any pixel, word or colour of the second image; only scale it
proportionally and round its corners to fit. Keep everything else unchanged.
```
Then compare the result with the original screenshot side by side; if any word or icon changed, discard it and do it in the editor (changed UI breaks the "real app" rule).

**Fix-up edit prompts**
- Gemini drew UI inside the phone: `Make the phone screen a flat, completely empty pure black rectangle. No icons, no text, no reflections.`
- Hand appeared: `Remove the hand and fingers; the phone stands alone on the dark background.`
- Phone looks like a specific brand (camera bump, logo): `Make the phone generic: no logo, no visible cameras, straight-on front view only.`
- Glow too strong: `Reduce the gold glow by half; keep the background almost black.`
- Wrong aspect: `Recompose as a vertical 9:16 image without stretching anything.`

**Alt text (Play asks for it)**: describe what the screen shows, for example "Camera screen recognising a tarot card held up to the phone".

## 6. Tablet screenshots (optional, 7-inch and 10-inch)

Recommendation: skip for launch unless you capture them from a tablet emulator (for example Pixel Tablet). Google wants real tablet captures, 9:16 or 16:9, 1080 to 7680 px, and "no additional text", so captions and Gemini frames are not appropriate here. If you add them later, upload the raw captures (for example 1600 x 2560 portrait; check the long side is at most twice the short side).

If you still want a background behind them (my reading: allowed, since it adds no text, but unverified), use the screenshot prompt in 5b with "tablet" instead of "smartphone" and "9:16" or "16:9", and no caption space.

## 7. Listing text

Character counts were checked with a script on 2026-10-16.

### Title (max 30)
- **Use:** `ShenTarot: AI Lens` (18)
- Alt 1: `ShenTarot: Tarot Card Reader` (28)
- Alt 2: `ShenTarot: Scan Tarot Cards` (27)
- Alt 3: `ShenTarot - AI Tarot Scanner` (28)

The chosen store name is the first one. Alt 1 and 2 carry "tarot" in the title, which may help search; changing the name is your call.

### Short description (max 80)
- **Use:** `Scan your tarot cards and get a clear, plain-language reading of what they mean.` (80)
- Alt 1: `Hold up a tarot card. ShenTarot names it and explains it for your question.` (75)
- Alt 2: `Tarot card scanner and reader for beginners: scan, learn and reflect.` (69)
- Alt 3: `Own a tarot deck? Scan what you drew and read what it means, in plain words.` (76)

### Full description (max 4000; this draft is 2355)

```
Got a tarot deck but not sure what you drew? ShenTarot scans your card, tells you which card it is, and explains it in plain language. It works as a tarot card reader for beginners and a quick reference for people who already know the cards.

Hold the cards. We explain them.
- Point your camera at a card and ShenTarot recognises it on your phone. Your photo is never saved or uploaded.
- Not sure it saw the right card? Pick it from the full 78-card list in a few taps.
- Prefer to draw on screen? Shuffle and draw digital cards instead.
- Ask a question, choose a spread for it (love, career, personal growth or the classics), and get a thoughtful reading of your cards.

Readings you can actually follow
- Each reading starts with a short summary, then explains every card in its position and why it fits your question.
- It ends with a question to reflect on and one small, practical step.
- Before the reading you can note what you notice in the cards yourself, and the reading will take it into account.

Learn tarot as you go
- A card library with keywords and upright and reversed meanings for all 78 cards.
- A Card of the Day to reflect on.
- A short guide to how tarot readings work and how to use spreads.

Free and Premium
- Free: one reading every day (one card or Past, Present, Future), plus a trial reading of a longer spread.
- Premium: all 14 spreads including the Celtic Cross and Horseshoe, 50 readings a day, follow-up questions, a clarifier card, and a journal for your own notes.

Private by design
- No account needed.
- Your reading history and journal stay on your phone.
- Your question is used only to write your reading and is not stored on our servers.
- You can report any reading from inside the app.

ShenTarot is for entertainment and self-reflection only. Readings are written by AI. They do not predict the future and are not medical, psychological, legal, financial or other professional advice.

Subscription info
Premium is an auto-renewing subscription (monthly, every 3 months or annual; the annual plan may start with a lower first-month price), billed through Google Play. It renews automatically until you cancel. Cancel any time in Google Play > Payments & subscriptions > Subscriptions.

Privacy Policy: https://yunlong2601.github.io/shentarot-legal/privacy.html
Terms of Use: https://yunlong2601.github.io/shentarot-legal/terms.html
```

Before you paste it: remove any line for a feature not in the uploaded build (scan, clarifier card, journal, Premium plans, report button). Check the Premium list against what the paywall actually sells. Headings are in sentence case on purpose: Google lists ALL CAPS as a metadata violation.

Words avoided on purpose: heal, healing, therapy, therapist, cure, anxiety relief, mental health, predict, future, destiny, guaranteed, accurate, psychic, best, #1, Rider-Waite.

## 8. Play Console upload checklist

Play Console > your app > **Grow users > Store presence > Main store listing** (menu names as of my check; Google moves them sometimes):

- [ ] App name: `ShenTarot: AI Lens`
- [ ] Short description (section 7)
- [ ] Full description (section 7, after removing unshipped features)
- [ ] App icon: 512 x 512 PNG, under 1 MB
- [ ] Feature graphic: 1024 x 500, JPEG or PNG without transparency
- [ ] Phone screenshots: 4 to 8, each 1080 x 1920, real app, captions under 20% of height, alt text filled in
- [ ] 7-inch / 10-inch tablet screenshots: leave empty unless captured on a tablet
- [ ] Video: optional (YouTube URL), skip for launch

Elsewhere in Play Console (not images, but the listing will not publish without them; see `docs/play-release-guide.md` on `google-play-prep`):
- [ ] **Store settings**: category (Lifestyle or Entertainment, your call), contact email, website/support URL
- [ ] **App content**: privacy policy URL, ads declaration (no ads), app access, content rating questionnaire, target audience, data safety (`play-upload/data_safety_filled.csv`), AI-generated content (the in-app report button)
- [ ] **Monetize > Subscriptions**: products match the paywall before the description mentions them

Final checks before "Send for review":
- [ ] Every image zoomed to 100%: no garbled letters, no extra words
- [ ] No rankings, awards, ratings, "free", "new", "best", store badges, hands or competitor logos
- [ ] No card art that looks like a modern published deck
- [ ] Screenshot UI is unchanged from the real app
- [ ] Re-check the limits in section 1 against the help pages on the day you upload
