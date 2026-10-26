# Editorial and mystical web design references for ShenTarot (layout and typography)

Method note: pages were fetched with curl/WebFetch on 2026-10-26 and their HTML/CSS was grepped for font-family, grid, column, mask and writing-mode declarations. **No screenshots were rendered**, so "observed" below means observed in the delivered HTML/CSS or the visible text, not a visual review. Visual claims beyond that are marked as inferred. Unless a reference says otherwise, sites are inspiration only (no license to copy code, fonts or imagery).

## For each reference: URL, code/breakdown, treatment worth studying, what was observed, usability, evidence level, license

### Takeaway
Ten references are usable, in three tiers. **Strongest fit for ShenTarot:** The Public Domain Review (an archive of public-domain imagery; free serif; asymmetric grids; small caps; subgrid), London Review of Books (literary multi-column and old-style figures) and Jen Simmons Labs (open-source editorial grid and vertical-type experiments). **Useful code sources:** Codrops LinesToLayout and TextClipScroll (MIT repos) and the Wellcome Collection repo (MIT). **Tarot/astrology-specific:** Tarot-o-bot (verified Awwwards SOTD), plus the Ephemeris and MysBlavatsky Framer templates. Of these, Ephemeris turned out to be sans-serif led, so it is a weak typographic model.

### Cited Findings

**1. The Public Domain Review (archive / online journal). Strongest overall fit.**
- Live: https://publicdomainreview.org loaded (HTTP 200; title "The Public Domain Review – Online journal dedicated to …") — [PDR](https://publicdomainreview.org)
- Fonts (inspected): the page loads Google Fonts `Alegreya:400,400i,500,500i,700,700i` and `Open Sans:300,400,600`. In its CSS, Open Sans is the dominant family (188 declarations) and Alegreya is the serif (12). Both are free Google Fonts — [PDR](https://publicdomainreview.org)
- Layout (inspected in `/styles.318174652ccfc70d8dba.css`): asymmetric column ratios such as `grid-template-columns: 3fr 7fr 3fr` (6×), `1fr 3fr 1fr` (12×), `2fr 7fr 2fr`, `3fr 5fr 3fr`, `4fr 1fr`, plus `font-variant: small-caps` (13×). This is a classic editorial "wide margins around a narrow text measure" system — [PDR](https://publicdomainreview.org)
- Subgrid (inspected): `.pdr-mini-list li{display:grid;grid-row:span 6;grid-template-rows:subgrid}` aligns title, author and date rows across sibling list items — [PDR](https://publicdomainreview.org)
- Fades (inspected): `mask-image:linear-gradient(180deg,transparent 0,#000 1.75rem,#000 calc(100% - 1.75rem),transparent)` softens the edges of scroll areas instead of using hard borders — [PDR](https://publicdomainreview.org)
- Relevance: PDR curates public-domain historical imagery, the same status as the 1909 Rider-Waite-Smith art. Its framing of archival images (captions, small caps, generous margins) maps directly onto card-art presentation (inference).
- Limitations (inferred): its sans-dominant UI is lighter than ShenTarot's dark brand, and it is not a dark-mode reference.
- License: site is inspiration only. Alegreya and Open Sans are free on Google Fonts.

**2. London Review of Books (literary magazine).**
- Live: https://www.lrb.co.uk loaded (200) — [LRB](https://www.lrb.co.uk)
- Fonts (inspected): self-hosted `QuadraatPro.woff2` (serif text) and `IdealSans-Medium.woff2`. The fallback stack is `Quadraat,TimesNewRoman,…,Baskerville,Georgia,serif`. Both are commercial faces, not free — [LRB](https://www.lrb.co.uk)
- Typographic detail (inspected in `main.css`): `column-count:2` (8×) collapsing to `column-count:1` (responsive), `font-variant-numeric:oldstyle-nums`, `text-wrap:balance`, `grid-template-columns:subgrid`, and a `.smallcapslede` class (small-caps opening words of an article) — [LRB](https://www.lrb.co.uk)
- Worth studying: the small-caps lede and old-style numerals for reading text (for example the "card meaning" body copy), and multi-column text on desktop only.
- Limitations: multi-column reading on screen forces vertical back-scrolling. LRB collapses to one column on small screens, which is the right pattern for the phone (inference).
- License: inspiration only. Fonts are commercial.

**3. Jen Simmons Labs (web layout experiments with open source code).**
- Live: https://labs.jensimmons.com loaded (200, "Web Design Experiments by Jen Simmons"). It lists examples including `initial-letter.html`, `initial-letter-2/5.html`, `multicolumn-1..3.html`, `article-on-grid-1.html`, `coversheet-1..3.html`, `futurismo-1/2.html`, `clip-path.html`, `grid-content-1-rotated.html` and `regions-1a..g.html` — [Jen Simmons Labs](https://labs.jensimmons.com)
- Code (inspected in `assets/css/styles.css`): an asymmetric 5-track grid, `grid-template-columns: auto 1fr 1fr 1fr 0.5fr`, with headings spanning `grid-column: 1 / 4`, `3 / 6`, `3 / -1`, and a vertical heading using `writing-mode: vertical-lr; grid-column: 3 / 4; grid-row: 2 / 5; justify-self: end;`. The font is futura-pt via Typekit (`use.typekit.net/smi4hhm.css`) — [Jen Simmons Labs](https://labs.jensimmons.com)
- Worth studying: open/asymmetric compositions, vertical type running alongside imagery (a natural fit for a card's Roman numeral or name running up the card edge), and initial-letter drop caps.
- Evidence: inspected (view source).
- Limitations: the experiments date from 2016–2017 and are demos rather than production pages. No license file was found, so treat them as learning material.

**4. Wellcome Collection (museum of medicine, life and art; open-source site).**
- Live: https://wellcomecollection.org returned HTTP 202 with an empty body to curl (likely bot protection), so it was **not loaded**. The repo is public: https://github.com/wellcomecollection/wellcomecollection.org (license **MIT**; last push 2026-10-26) — [GitHub repo](https://github.com/wellcomecollection/wellcomecollection.org)
- Fonts (inspected in `common/views/themes/base/fonts.ts`): `Inter` (Regular, SemiBold) and a proprietary `Wellcome` bold display face, self-hosted — [fonts.ts](https://github.com/wellcomecollection/wellcomecollection.org/blob/main/common/views/themes/base/fonts.ts)
- Worth studying (inferred, page not rendered): museum-grade handling of object captions and catalogue metadata, which suits card "catalogue entries" (number, arcana, element, upright/reversed).
- License: the code is MIT and can be adapted. The Wellcome display font is proprietary; do not reuse it.

**5. Rijksmuseum (museum).**
- Live: https://www.rijksmuseum.nl/en loaded (200) — [Rijksmuseum](https://www.rijksmuseum.nl/en)
- Fonts (inspected): custom `RijksText` (`Rijksmuseum-Normal/Bold/Italic.woff2`), proprietary — [Rijksmuseum](https://www.rijksmuseum.nl/en)
- Worth studying (inferred): treating artworks as the hero with restrained type. The layout was not inspected beyond fonts.
- License: inspiration only.

**6. The Paris Review (literary magazine).**
- Live: https://www.theparisreview.org loaded (200). Fonts come through a Typekit JS kit (`typekit.net/clx4psi.js`); the families could not be resolved from the HTML — [Paris Review](https://www.theparisreview.org)
- Worth studying (inferred): the interview/"Art of" archive structure, i.e. numbered issues and long-form serif reading.
- Evidence: fonts only partially inspected. Layout details were not verified.

**7. Codrops: Lines to Content Layout Animation (demo plus MIT repo).**
- Repo: https://github.com/codrops/LinesToLayout (license **MIT**). Demo: http://tympanus.net/Development/LinesToLayout/ (loaded). Article: https://tympanus.net/codrops/?p=60052 — [GitHub](https://github.com/codrops/LinesToLayout)
- Treatment: per the README, a "typography row view with inline images" switching to a large image preview. That is directly applicable to a numbered index of the 78 cards, with big serif names and inline card thumbnails, expanding to a reading page. The demo CSS uses a system sans stack and `font-size: 15vw` for display rows (inspected) — [GitHub](https://github.com/codrops/LinesToLayout)
- Limitations: it is animation-heavy, and the type would need restyling to the brand serif.

**8. Codrops: TextClipScroll and other typography repos (MIT).**
- TextClipScroll: "Experimental on-scroll typography effects using SVG clip-paths" (article https://tympanus.net/codrops/?p=75256). Other recently updated Codrops type repos include OnScrollTypographyAnimations, ScrollBlurTypography and KineticTypePageTransition — [GitHub API search, org:codrops typography](https://github.com/codrops/TextClipScroll)
- Evidence: listed via the GitHub API. Article and demo **not fetched**. Use them for selective moments (the reveal of the reading) rather than for body layout.

**9. Tarot-o-bot (tarot web experience). Verified Awwwards SOTD.**
- Awwwards page: https://www.awwwards.com/sites/tarot-o-bot. Its title reads "Tarot-o-bot - Awwwards SOTD" and the page shows the date Jul 24, 2019 — [Awwwards](https://www.awwwards.com/sites/tarot-o-bot)
- Live: https://illo.tv/tarotobot redirects to https://tarotobot.illo.tv/ (200, title "Tarot-o-bot") — [Tarot-o-bot](https://tarotobot.illo.tv/)
- A search summary says it draws three illustrated cards to "predict your digital future" — [Awwwards](https://www.awwwards.com/sites/tarot-o-bot)
- Use: a reference for the three-card draw interaction and illustration-led presentation, not for editorial typography (layout not inspected; inferred).

**10. Ephemeris (Framer template, astrology and tarot).**
- Listing: https://www.framer.com/marketplace/templates/ephemeris/ (title "Ephemeris — Free Website Template for Framer"). The listing mentions "Expressive typography, atmospheric imagery", reading pages, twelve sign pages with a sign finder, and a journal. Preview: https://ephemeris.framer.website/ — [Framer](https://www.framer.com/marketplace/templates/ephemeris/)
- Fonts (inspected on the preview): **Montserrat** and **Hanken Grotesk**, both free Google Fonts and both sans. It is therefore not a serif-editorial model, though its IA (readings, zodiac pages, journal) is relevant — [Ephemeris preview](https://ephemeris.framer.website/)
- License: the page title says "Free". `https://www.framer.com/marketplace/license/` returned 404, so the exact terms were **not verified**.

**11. MysBlavatsky Healing (Framer template, astrology/spiritual).**
- https://www.framer.com/marketplace/templates/mysblavatsky-healing/ loaded (200). A search summary describes 20 page layouts (6 CMS), "warm earth tones, expressive type and art-led layouts", and a design-system page. Booking and payments are not built in — [Framer](https://www.framer.com/marketplace/templates/mysblavatsky-healing/)
- Fonts, price and license were **not verified**.

**12. Co–Star (astrology brand). Brand reference only.**
- https://www.costarastrology.com returns a client-rendered shell (`<div id="app">` plus Bootstrap 3.3.7 CSS). Fonts could not be extracted from the bundle — [Co–Star](https://www.costarastrology.com)
- Secondary sources describe a minimal black-and-white, text-led style, and a co-founder said it "feels like paper" — [34th Street](https://www.34st.com/article/2019/01/costar-app-astrology-horoscope-aesthetic-minimalism-tech-social-media-banu-guler); [Pratt IxD critique](https://ixd.prattsi.org/2022/02/design-critique-co-star-iphone-app/)

**Also checked, with weak evidence:**
- Sabat Magazine (occult magazine), https://www.sabatmagazine.com (200). It is a Squarespace cover page; fonts are futura-pt, brandon-grotesque and Helvetica Neue (all sans). Thematically on-topic but not an editorial-serif model — [Sabat](https://www.sabatmagazine.com)
- Butterick's Practical Typography, https://practicaltypography.com (200). Fonts are `advocate-c41` and `triplicate`, Butterick's own commercial faces. It is a reference for typographic rules rather than layout — [Practical Typography](https://practicaltypography.com)
- Typewolf (https://www.typewolf.com) and Kinfolk (https://www.kinfolk.com) loaded (200), but no fonts or layout could be extracted.
- Harper's and The Pattern did not load (connection failure). aesop.com returned 403 (Cloudflare challenge). Fonts In Use tag URL failed.

### Inferences
- For ShenTarot's dark brand, PDR plus LRB give the reading typography (serif text, small-caps ledes, old-style numerals, asymmetric margins). Jen Simmons Labs gives the "open" composition, vertical type and drop caps. Codrops LinesToLayout gives a code-ready numbered card index.
- None of the verified references is a strong dark, gold-on-black editorial site. That combination will need to be synthesized rather than copied.

### Gaps
- Pages were not visually rendered, so overlapping layers, arcs, connecting lines and parchment texture could not be confirmed on any reference.
- No verified site using CSS-mask deckled/torn edges or mix-blend ink was found within the research budget.
- Framer template license terms (the license page 404'd), template prices, and the fonts of Paris Review, Kinfolk, Typewolf and Co–Star are unconfirmed.
- No Godly or Siteinspire entries were retrieved; the search returned irrelevant results.

## How are the layouts built (techniques with verified snippets)

### Takeaway
The verified techniques are CSS Grid with asymmetric `fr` tracks, subgrid row alignment, `writing-mode: vertical-lr` inside the grid, multi-column text that collapses on mobile, old-style numerals and small caps, `text-wrap: balance`, gradient `mask-image` fades, and SVG clip-path type (Codrops). Named grid lines, `clamp()` type, SVG ornaments, `mix-blend-mode` ink and deckled masks were **not** found in the inspected sources.

### Cited Findings
- Asymmetric editorial tracks — [PDR CSS](https://publicdomainreview.org):
  ```css
  .article { display:grid; grid-template-columns: 3fr 7fr 3fr; }   /* also 1fr 3fr 1fr, 2fr 7fr 2fr */
  ```
- Subgrid rows across list items — [PDR CSS](https://publicdomainreview.org):
  ```css
  .pdr-mini-list li { display:grid; grid-row: span 6; grid-template-rows: subgrid; }
  ```
- Edge fade on scrollers — [PDR CSS](https://publicdomainreview.org):
  ```css
  mask-image: linear-gradient(180deg, transparent 0, #000 1.75rem, #000 calc(100% - 1.75rem), transparent);
  ```
- Vertical heading inside an asymmetric grid — [Jen Simmons Labs CSS](https://labs.jensimmons.com):
  ```css
  header { display:grid; grid-template-columns: auto 1fr 1fr 1fr 0.5fr; }
  header h1:nth-child(2) { writing-mode: vertical-lr; grid-column: 3 / 4; grid-row: 2 / 5; justify-self: end; }
  ```
- Literary text features — [LRB CSS](https://www.lrb.co.uk):
  ```css
  .article-copy { column-count: 2; font-variant-numeric: oldstyle-nums; }
  @media (max-width: …) { .article-copy { column-count: 1; } }
  .smallcapslede { font-variant: small-caps; }  h1 { text-wrap: balance; }
  ```
- SVG clip-path typography on scroll — [Codrops TextClipScroll](https://github.com/codrops/TextClipScroll) (repo listed; code not read).
- Viewport-sized display rows — [Codrops LinesToLayout demo](http://tympanus.net/Development/LinesToLayout/): `font-size: 15vw`.

### Inferences
- For deckled edges and ink, the standard approaches are an SVG `feTurbulence` + `feDisplacementMap` filter, a PNG/SVG `mask-image` with a rough edge, and `mix-blend-mode: multiply` for ink on parchment. Each of these is a general technique, **not verified on any reference here**.
- Named grid lines (`[full-start] minmax(1rem,1fr) [content-start] …`) would cleanly express PDR's `3fr 7fr 3fr` margins plus full-bleed card art. This is a recommendation, not observed.

### Gaps
- No inspected source used `clamp()`, named lines, `initial-letter` in production CSS, SVG ornaments or mix-blend. Jen Simmons Labs has `initial-letter` demo pages that were listed but not opened.

## Typography pairings and translation to Flutter plus desktop web

### Takeaway
Among the verified pairings, only **Alegreya + Open Sans (PDR)** is free and serif-led. LRB (Quadraat + Ideal Sans), Rijksmuseum (RijksText) and Wellcome (Wellcome + Inter) use commercial or proprietary faces. The tarot Framer template uses free sans faces (Montserrat + Hanken Grotesk). For ShenTarot, a free Google serif pair carried by both the web CSS and Flutter is the practical route.

### Cited Findings
- PDR: Alegreya (serif) and Open Sans, both Google Fonts — [PDR](https://publicdomainreview.org)
- LRB: Quadraat Pro and Ideal Sans, both commercial — [LRB](https://www.lrb.co.uk)
- Wellcome: Inter (free) and the proprietary Wellcome display face — [fonts.ts](https://github.com/wellcomecollection/wellcomecollection.org/blob/main/common/views/themes/base/fonts.ts)
- Rijksmuseum: RijksText, proprietary — [Rijksmuseum](https://www.rijksmuseum.nl/en)
- Ephemeris: Montserrat and Hanken Grotesk, both free sans — [Ephemeris preview](https://ephemeris.framer.website/)
- Jen Simmons Labs: futura-pt (Adobe Fonts) — [Labs](https://labs.jensimmons.com)
- Butterick: Advocate and Triplicate, both commercial — [Practical Typography](https://practicaltypography.com)

### Inferences
- A suggested free stack, not taken from the references: a high-contrast Google serif for display (for example Cormorant Garamond or EB Garamond), Alegreya or EB Garamond for reading text (the Alegreya choice is validated by PDR), and a restrained sans (Inter or Open Sans) for UI labels.
- In Flutter, bundle the same .ttf/variable files as assets, rather than fetching at runtime, for offline scanning. Map them into `TextTheme` (displayLarge = serif display; bodyMedium = serif text; labelSmall = sans with letter-spacing for small-caps-like labels). Use `FontFeature.oldstyleFigures()` and `FontFeature.enable('smcp')` where the font supports them. This mirrors LRB's old-style numerals and small-caps ledes.
- On desktop web, use the PDR-style asymmetric grid plus LRB-style 2-column reading. On the phone, collapse to one column and keep the vertical card-name type (Jen Simmons pattern) as an accent only.

### Gaps
- Whether the candidate Google serifs ship `smcp`/`onum` features was not checked.
- The fonts of Co–Star, Paris Review, Kinfolk and Typewolf are unresolved.
