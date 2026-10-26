# Fine connecting lines, numbered annotations, sticky scroll context and reduced motion for ShenTarot's reading page

Scope: references and techniques for a "connected-card explanations" reading page (desktop first, phone second). The spread stays pinned as context while the reading scrolls. Each explanation is tied to its card, and to related cards, by fine ink-like SVG lines and numbered markers. Research date: 2026-10-26.

Liveness legend:
- **[LOADED]**: I fetched the page during this research and it returned content.
- **[SEARCH-ONLY]**: the URL came from search results and I did not fetch it, so it is not confirmed to load.

Code-provenance legend:
- **[DOC]**: taken from or closely paraphrasing the cited documentation.
- **[AUTHORED]**: my own synthesis written for these notes, not copied from a source. Test it before shipping.

## 1. References (live URL, code/breakdown, interaction, observations, benefit/limits, implementation status, license)

### Takeaway
No single reference does exactly "a sticky spread plus per-card explanations with connecting lines". The strongest stack combines:
- the sticky-graphic scrollytelling pattern (Pudding/Scrollama), which pins the spread with CSS while lightweight IntersectionObserver triggers decide which card is active;
- a measured SVG overlay, either LeaderLine-style or hand-rolled, that draws a fine line from the active explanation to its card;
- CSS anchor positioning for numbered markers, where supported.

Reputation evidence is thin. The only tarot site with a confirmed Awwwards SOTD is Tarot-o-bot (2019, score 7.3), and it is a card-draw toy, not an annotated reading.

### Cited Findings

**R1. Scrollama (open-source library and demos)** [LOADED]
- What it is: an IntersectionObserver-based scrollytelling library. Current version 3.2.0, MIT license (© 2022 Russell Samora) — [GitHub russellsamora/scrollama](https://github.com/russellsamora/scrollama)
- API: `setup({ step, offset (default 0.5), progress, threshold (default 4px), once, debug, parent, container, root })`. Callbacks are `onStepEnter`/`onStepExit` with `{element, index, direction}` and `onStepProgress` with `{element, index, progress}`. A step can override the offset with `data-offset`. `resize()` is largely unnecessary now that a built-in ResizeObserver exists — [GitHub](https://github.com/russellsamora/scrollama)
- Sticky guidance: the README recommends CSS `position: sticky` for the pinned graphic, in either a side-by-side or a full-screen overlay layout. It suggests pixel offsets on mobile and warns against `vh` units because the browser chrome resizes the viewport — [GitHub](https://github.com/russellsamora/scrollama)
- Demos [SEARCH-ONLY individually; listed in the README]: https://russellsamora.github.io/scrollama/sticky-side, …/sticky-overlay, …/progress, …/mobile-pattern — [GitHub](https://github.com/russellsamora/scrollama)
- Interaction: native scrolling. Text steps pass a pinned graphic, and each step fires enter/exit/progress events.
- Benefit: the scroll is not hijacked, and the library is small.
- Limitation: it only reports which step is active. Drawing lines and anchoring markers is left to you.
- Implementation status: documented.

**R2. The Pudding, "Sticky scrollytelling" (breakdown plus CodePens)** [LOADED]
- Authors and date: Elaina Natario and Russell Samora, June 2018 — [pudding.cool/process/scrollytelling-sticky](https://pudding.cool/process/scrollytelling-sticky/)
- Technique: `position: sticky` does the pinning, and JavaScript only handles step triggers (enter-view.js, Scrollama or Waypoints). The authors argue this is smoother and less buggy than locking with scroll listeners — [same](https://pudding.cool/process/scrollytelling-sticky/)
- Caveat: a sticky element sticks only within its parent, and the parent's edges set its thresholds. That lets you control overlap between several sticky panels — [same](https://pudding.cool/process/scrollytelling-sticky/)
- Fallback: unsupported browsers render the element static in source order. `@supports (position: sticky)` can switch to a fallback layout — [same](https://pudding.cool/process/scrollytelling-sticky/)
- Code: [CodePen collection XBWPqE](https://codepen.io/collection/XBWPqE/) and [github.com/the-pudding/blog_scrollytelling-sticky](https://github.com/the-pudding/blog_scrollytelling-sticky) [SEARCH-ONLY/linked from article; license not checked]

**R3. The Pudding, "Responsive scrollytelling best practices"** [LOADED]
- Author and date: Russell Samora, April 2017 — [pudding.cool/process/responsive-scrollytelling](https://pudding.cool/process/responsive-scrollytelling/)
- Scrolly or stacked: keep the scrolly format only when transitions carry meaning. Otherwise stack standalone graphics, especially on mobile — [same](https://pudding.cool/process/responsive-scrollytelling/)
- Avoid steppers and tap/swipe interfaces that override default scrolling — [same](https://pudding.cool/process/responsive-scrollytelling/)
- Use few steps on phones, because pacing becomes fatiguing sooner there — [same](https://pudding.cool/process/responsive-scrollytelling/)
- Don't use `vh`. Set step heights from `window.innerHeight` instead — [same](https://pudding.cool/process/responsive-scrollytelling/)
- Remove hover interactions on touch devices and replace them with fixed annotations — [same](https://pudding.cool/process/responsive-scrollytelling/)
- Related: [How to implement scrollytelling with six different libraries](https://pudding.cool/process/how-to-implement-scrollytelling) [SEARCH-ONLY] and [Introducing Scrollama](https://pudding.cool/process/introducing-scrollama/) [SEARCH-ONLY]. The latter calls its example "desktop-centric" per the search snippet.

**R4. LeaderLine (anseki/leader-line), a library for lines between DOM elements** [LOADED]
- License and status: MIT. The repository was archived (read-only) on 2025-04-11 — [GitHub anseki/leader-line](https://github.com/anseki/leader-line)
- Features: path types straight, arc, fluid (default), magnet and grid. `dash` with `animation: true` defaults to 1000 ms linear. `show`/`hide` effects are `none`, `fade` and `draw`. `position()` re-positions a line after scroll, animation or container changes. Automatic resize handling can be disabled with `LeaderLine.positionByWindowResize = false` — [GitHub](https://github.com/anseki/leader-line)
- Benefit: endpoint math and socket selection are done for you.
- Limitations: the project is archived (unmaintained). The SVG is appended outside your component tree. You must call `position()` yourself on scroll inside containers.
- Implementation status: documented.
- Forks exist (leader-line-new and others) [SEARCH-ONLY; licenses not checked] — [jsDelivr README](https://cdn.jsdelivr.net/npm/leader-line-new@1.1.9/README.md)

**R5. Codrops, "SVG Drawing Animation" (2013)** [SEARCH-ONLY]
- The article uses SVG line drawings to precede the appearance of illustrations as they enter the viewport. It credits Jake Archibald's stroke-dashoffset technique. Article: [tympanus.net/codrops/?p=18012](https://tympanus.net/codrops/?p=18012). Demo: [tympanus.net/Development/SVGDrawingAnimation/](https://tympanus.net/Development/SVGDrawingAnimation/index.html)
- I found no Codrops demo that connects separate DOM elements with lines on scroll. The 2013 piece is the closest match by name, and it predates modern APIs.
- Codrops demos are generally under its own license; I did not verify the terms for this demo.

**R6. Flavio Copes, "Animated SVG connection lines" (2026-07-22)** [LOADED]
- Interaction: diagram edges draw themselves when the diagram scrolls into view. The demo uses an IntersectionObserver at `threshold: 0.25`, reveals once, then unobserves — [flaviocopes.com](https://flaviocopes.com/animated-svg-connection-lines/)
- Line draw: the article sets `--edge-len` and animates `stroke-dashoffset` from `var(--edge-len)` to 0 in about 0.4 s. A solid "draw" line runs once, then a dashed base line stays. Edges are staggered with `nodeDelay + 200 + i*20` ms — [same](https://flaviocopes.com/animated-svg-connection-lines/)
- Endpoints come from node position plus half its width and height, not from `getBoundingClientRect`. Curves are cubic béziers, and lengths come from `getTotalLength()` or are precomputed — [same](https://flaviocopes.com/animated-svg-connection-lines/)
- Reduced motion: JavaScript checks `matchMedia('(prefers-reduced-motion: reduce)')` and shows final states. CSS hides `.edge-draw-line` and removes transitions — [same](https://flaviocopes.com/animated-svg-connection-lines/)
- Also found, not fetched: a DEV tutorial on dashed SVG paths that connect sections on scroll — [dev.to/emilcheva](https://dev.to/emilcheva/connect-sections-by-drawing-dashed-svg-paths-on-scroll-3bcb) [SEARCH-ONLY]

**R7. Chrome for Developers, CSS anchor positioning** [LOADED]
- Syntax:
  - `anchor-name: --x` marks an anchor.
  - `position-anchor: --x` links a positioned element to it.
  - `top: anchor(bottom)` or `anchor(--x bottom)` sets offsets.
  - `justify-self: anchor-center` centers the element.
  - `anchor-size()` sizes from the anchor.
  - `position-area` (renamed from `inset-area`) places elements on a nine-cell grid.
  - `@position-try` with `position-try-fallbacks` (renamed from `position-try-options`) sets fallbacks; `flip-block`/`flip-inline` are built-in options.
  - `position-visibility` handles anchors in subscrollers.
  - Source: [developer.chrome.com/blog/anchor-positioning-api](https://developer.chrome.com/blog/anchor-positioning-api)
- The article was written for Chrome 125, and the renamed properties shipped in Chrome 129. The page lists support as Chrome/Edge 125, Firefox 147 and Safari 26. The OddBird polyfill is described as incomplete, with some outdated syntax. Feature-detect with `@supports (anchor-name: --a)` — [same](https://developer.chrome.com/blog/anchor-positioning-api)
- Accessibility: anchoring creates no semantic relationship. The page suggests `aria-details` on the anchor that points to the annotation, and says screen-reader support for `aria-details` "is still developing" — [same](https://developer.chrome.com/blog/anchor-positioning-api)

**R8. MDN, CSS scroll-driven animations, plus support data** [LOADED]
- Reference properties: `animation-timeline`, `animation-range` (start/end), `scroll-timeline`, `view-timeline` (axis, inset, name) and `timeline-scope`. Functions: `scroll()` and `view()`. The spec is still a draft. The MDN example feature-detects with `@supports not (scroll-timeline: --main-timeline)` — [MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_scroll-driven_animations)
- `animation-timeline` support per caniuse: Chrome 115+, Edge 115+, Firefox 159+, Safari 26.0+ (macOS) and iOS Safari 26.0+ — [caniuse](https://caniuse.com/mdn-css_properties_animation-timeline)
- Note: the version numbers above come from caniuse's rendered table as summarized by the fetch tool. Re-check them before relying on them.

**R9. Chrome, "A case study on scroll-driven animations performance"** [SEARCH-ONLY]
- The case study says the CSS API uses minimal main-thread resources and stays smooth under heavy JavaScript load, where a scroll-listener version janks — [developer.chrome.com/blog/scroll-animation-performance-case-study](https://developer.chrome.com/blog/scroll-animation-performance-case-study)
- The Chrome article notes that Scroll and View Timelines shipped in Chrome 115 and can run off the main thread — [developer.chrome.com/articles/scroll-driven-animations](https://developer.chrome.com/articles/scroll-driven-animations)
- Cached versions of the case study disagree on Firefox/Safari support. Use caniuse (R8) instead.

**R10. Tarot-o-bot by illo (Awwwards SOTD), verified** [LOADED]
- Award: Awwwards Site of the Day, 24 July 2019. SOTD score 7.3/10 (Design 7.42, Usability 7.11, Creativity 7.56, Content 6.89). Dev score 7.07 (Accessibility 6.33). No honorable mention is listed. Live URL given: https://illo.tv/tarotobot (I did not fetch it) — [awwwards.com/sites/tarot-o-bot](https://www.awwwards.com/sites/tarot-o-bot)
- Interaction (per search summary): it draws three illustrated cards and gives a reading.
- Relevance: tone and illustration only. It has no connected annotations.
- Other tarot items on Awwwards are "Elements" or inspiration entries, not SOTD winners: [Roadmap tarot cards](https://www.awwwards.com/inspiration/roadmap-tarot-cards-become-rstlss) and [Page loader](https://www.awwwards.com/inspiration/page-loader) [SEARCH-ONLY]

**R11. Museum annotated-image precedents** [SEARCH-ONLY]
- Rijksmuseum Night Watch: a 44.8-gigapixel zoomable image built from 528 exposures, published May 2020 — [DutchNews](https://dutchnews.nl/2020/05/rijkmuseum-places-most-detailed-ever-night-watch-photo-online). Another source gives about 717 gigapixels and 8,400 photos; this conflicts and is probably a later capture — [iamexpat](https://www.iamexpat.nl/lifestyle/lifestyle-news/see-rembrandts-night-watch-online-hyper-resolution)
- Q42's "Rijksmuseum from home" explains 18 paintings with text and audio, using Q42's Micrio "ultra-resolution storytelling" zoom tool — [q42.nl](https://www.q42.nl/en/work/rijksmuseum-from-home)
- Implementation status: inferred. I did not inspect it, and the Micrio license is proprietary (inferred).
- North Carolina Museum of Art: a bilingual annotated image viewer with 43 annotated hotspots on a single artifact, built for touch kiosks — [Urban Insight](https://www.urbaninsight.com/project/north-carolina-museum-art-annotated-image-viewer)
- Te Papa "Encounters": tapping fills the screen, pinch-zoom reveals detail, and animated hotspots open facts — [Springload](https://www.springload.co.nz/work/te-papa-encounters/)
- None of these was confirmed to use numbered markers with drawn leader lines.

**R12. European Data Visualisation Guide: scrollytelling taxonomy** [SEARCH-ONLY]
- The guide names five scrollytelling techniques drawn from an analysis of 50 articles, including "graphic sequence" and "pan and zoom". Pan and zoom, where scroll chooses which portion of a large visual is shown, maps to zooming into one card of the spread — [data.europa.eu guide](https://data.europa.eu/apps/data-visualisation-guide/scrollytelling-introduction)

**Journalism (NYT/Reuters)**
- My searches did not surface a specific, verifiable Reuters or NYT piece that uses leader lines on a sticky graphic. Reuters was mentioned only via an Online Journalism Blog tag page ([Beirut blast](https://onlinejournalismblog.com/tag/beirut-blast/)) [SEARCH-ONLY]. See Gaps.

### Inferences
- The best fit for ShenTarot is R2/R1 layout plus R6-style line draw plus R7 markers. A two-column grid places the spread in a sticky left column and the explanations scrolling on the right. The active explanation's number connects by one hairline gold path to the card's numbered marker. Related cards get fainter secondary paths.
- LeaderLine is attractive for prototyping, but it is archived, so a roughly 60-line hand-rolled overlay (§2) is safer for production.
- Tarot-o-bot is the only verified award evidence. Do not claim the "connected explanations" pattern is award-validated.

### Gaps
- No NYT, Reuters or Pudding story found with drawn leader lines from scrolling text to a pinned image. Such stories exist anecdotally, but I could not cite one.
- Codrops license terms and any modern "connect elements" Codrops demo are unverified.
- Not fetched: illo.tv/tarotobot, the Scrollama demo pages, the Codrops demo, and the museum sites.
- The Pudding GitHub repository license is unchecked.

## 2. Techniques with concise code (web)

### Takeaway
- Draw lines in one absolutely positioned SVG overlay that covers the reading grid.
- Compute endpoints from `getBoundingClientRect()` relative to the overlay.
- Recompute in one `requestAnimationFrame` (rAF) per frame, triggered by ResizeObserver, scroll and active-step changes. Read all rects first, then write all paths.
- Use CSS (`position: sticky`, scroll-driven animations, anchor positioning) where supported, with `@supports` fallbacks.

### Cited Findings
- Dash draw pattern: set dasharray and dashoffset to the path length, then animate the offset to 0 — [Flavio Copes](https://flaviocopes.com/animated-svg-connection-lines/); originally credited to Jake Archibald in [Codrops 2013](https://tympanus.net/codrops/?p=18012)
- `position: sticky` pins only within its parent — [Pudding](https://pudding.cool/process/scrollytelling-sticky/)
- Anchor positioning syntax and `@supports (anchor-name: --a)` — [Chrome](https://developer.chrome.com/blog/anchor-positioning-api)
- Scroll-driven feature detection and the `scroll()`/`view()` timelines — [MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_scroll-driven_animations)
- Scroll-driven animations stay smooth when the main thread is busy — [Chrome case study](https://developer.chrome.com/blog/scroll-animation-performance-case-study)

### Code (all [AUTHORED] unless marked)

**A. Layout: sticky spread with scrolling reading**
```css
.reading { display:grid; grid-template-columns: minmax(320px,44%) 1fr; gap: 4rem; position:relative; }
.spread  { position: sticky; top: 2rem; align-self:start; height: fit-content; } /* parent must not have overflow:hidden/auto */
.links   { position:absolute; inset:0; pointer-events:none; overflow:visible; } /* SVG overlay, aria-hidden="true" */
@media (max-width: 760px){
  .reading { grid-template-columns: 1fr; }
  .spread  { top: 0; z-index:2; background: var(--parchment); /* compact strip of thumbnails */ }
}
```

**B. Lines between DOM elements (measure, then draw; batched in rAF)**
```js
const svg = document.querySelector('.links'), host = document.querySelector('.reading');
let raf = 0;
const schedule = () => { if (!raf) raf = requestAnimationFrame(draw); };
function draw() {
  raf = 0;
  const h = host.getBoundingClientRect();                 // READ phase
  const pairs = [...document.querySelectorAll('[data-card-ref]')].map(note => {
    const card = document.getElementById(note.dataset.cardRef);
    return [note.querySelector('.num').getBoundingClientRect(), card.getBoundingClientRect(), note];
  });
  for (const [a, b, note] of pairs) {                     // WRITE phase
    const x1 = a.left - h.left, y1 = a.top + a.height/2 - h.top;
    const x2 = b.right - h.left, y2 = b.top + b.height/2 - h.top;
    const mx = (x1 + x2) / 2;
    const p = svg.querySelector(`[data-for="${note.id}"]`);
    p.setAttribute('d', `M${x1},${y1} C${mx},${y1} ${mx},${y2} ${x2},${y2}`);
  }
}
new ResizeObserver(schedule).observe(host);
addEventListener('scroll', schedule, { passive: true });
document.fonts.ready.then(schedule);                      // web-font reflow shifts endpoints
```
Note: because the spread is sticky, its card rects change with scroll while the notes move, so the scroll listener is required. Keep it passive and rAF-throttled.

**C. Ink line draw (stroke-dasharray/dashoffset)**
```css
.link { fill:none; stroke: var(--gold); stroke-width: .75; vector-effect: non-scaling-stroke; opacity:.35; }
.link.is-active { opacity:1; stroke-dasharray: var(--len); stroke-dashoffset: var(--len);
                  animation: ink 700ms cubic-bezier(.3,.6,.2,1) forwards; }
@keyframes ink { to { stroke-dashoffset: 0; } }
@media (prefers-reduced-motion: reduce){ .link.is-active { animation:none; stroke-dashoffset:0; } }
```
```js
p.style.setProperty('--len', p.getTotalLength());  // set after updating d
```
Using `pathLength="1"` with `--len:1` avoids `getTotalLength()` calls. This is an inference from the SVG spec; verify cross-browser.

**D. IntersectionObserver for the active step (Scrollama-equivalent)**
```js
const io = new IntersectionObserver(entries => {
  for (const e of entries) if (e.isIntersecting) setActive(e.target);
}, { rootMargin: '-45% 0px -45% 0px' });   // a band around the viewport middle, like Scrollama offset 0.5
document.querySelectorAll('.note').forEach(n => io.observe(n));
```
Or use Scrollama directly: `scrollama().setup({ step: '.note', offset: 0.5 }).onStepEnter(({element}) => setActive(element))` [DOC-ish, per README].

**E. CSS scroll-driven reveal with fallback**
```css
@supports (animation-timeline: view()) {
  @media (prefers-reduced-motion: no-preference) {
    .note { animation: rise linear both; animation-timeline: view(); animation-range: entry 0% cover 30%; }
    @keyframes rise { from { opacity:.25; translate: 0 12px; } to { opacity:1; translate:0 0; } }
  }
}
/* No @supports, or reduced motion: notes are simply fully visible. */
```
Path `d` updates still need JavaScript. Scroll-timelines can animate `stroke-dashoffset` but cannot recompute geometry.

**F. Numbered markers with CSS anchor positioning (progressive)**
```css
.card-3 { anchor-name: --card-3; }
.marker-3 { position:absolute; position-anchor: --card-3; position-area: top right;
            position-try-fallbacks: flip-inline; }
@supports not (anchor-name: --a) { .marker { position: static; } /* or JS-positioned */ }
```
The property names follow Chrome's renamed syntax (`position-area`, `position-try-fallbacks`) [DOC].

**G. View Transitions for switching between spread and card detail**
```js
if (document.startViewTransition && !matchMedia('(prefers-reduced-motion: reduce)').matches)
  document.startViewTransition(() => openCard(id)); else openCard(id);
```
```css
.card-3 { view-transition-name: card-3; }
```
This is [AUTHORED]. I did not fetch View Transitions documentation in this pass (see Gaps).

**H. Ink reveal using mask/clip**
```css
.card-art { mask-image: linear-gradient(to bottom, #000 var(--p,0%), transparent calc(var(--p,0%) + 12%)); }
@supports (animation-timeline: view()) {
  .card-art { animation: inkmask linear both; animation-timeline: view(); animation-range: entry 10% cover 40%; }
  @property --p { syntax:'<percentage>'; inherits:false; initial-value:0%; }
  @keyframes inkmask { to { --p: 100%; } }
}
```
`clip-path: inset(0 0 var(--hide) 0)` is a cheaper alternative. A registered custom property (`@property`) is needed for interpolation. This is an inference; animating mask gradients repaints and is likely not composited.

### Inferences
- Animate only `opacity`, `transform`/`translate` and `stroke-dashoffset` on a few paths.
- Don't add `will-change` to many SVG paths. Reserve it for the sticky spread if needed.
- Never interleave `getBoundingClientRect` reads with `setAttribute` writes in the same loop, because that causes layout thrash.
- On phones, pinning the whole spread consumes too much height. Use a compact sticky thumbnail strip, built with Flutter `PinnedHeaderSliver` or CSS sticky. Number the cards, and replace long lines with short ticks or an "active card" highlight. This follows the Pudding advice to simplify on mobile.

### Gaps
- I did not fetch the MDN View Transitions or mask-image pages, so G and H are unverified authored code.
- No measured performance numbers for SVG-overlay recomputation on scroll were found.

## 3. Accessibility: reading order, aria, focus, reduced motion, no scroll hijacking, performance

### Takeaway
Lines are decoration. The relationship must exist in the DOM and in the text:
- each explanation is a `<section>` headed "3 · The Tower (crossing)";
- it carries an `aria-describedby` or `aria-details` link to the card;
- the SVG is `aria-hidden`.

Respect `prefers-reduced-motion` by showing final states, never by hiding content. Keep native scrolling.

### Cited Findings
- Anchor positioning creates no semantic relationship. Chrome suggests `aria-details` from the anchor to the annotation, and notes that screen-reader support for `aria-details` "is still developing" — [Chrome](https://developer.chrome.com/blog/anchor-positioning-api)
- `popover` and `<dialog>` get browser-managed focus navigation, so they don't need to sit next to their anchor in the DOM — [Chrome](https://developer.chrome.com/blog/anchor-positioning-api)
- Avoid steppers and tap/swipe interfaces that override default scrolling; remove hover-dependent reveals on touch — [Pudding responsive](https://pudding.cool/process/responsive-scrollytelling/)
- Reduced-motion pattern: skip the draw overlay and show final states in both JavaScript and CSS — [Flavio Copes](https://flaviocopes.com/animated-svg-connection-lines/)
- Scrollama uses IntersectionObserver rather than scroll events, as its performance rationale — [Scrollama](https://github.com/russellsamora/scrollama)
- CSS scroll-driven animations avoid main-thread jank — [Chrome case study](https://developer.chrome.com/blog/scroll-animation-performance-case-study)
- Awwwards' accessibility sub-score for Tarot-o-bot was its lowest at 6.33, a reminder that award sites aren't accessibility models — [Awwwards](https://www.awwwards.com/sites/tarot-o-bot)

### Inferences ([AUTHORED] patterns)
- Markup:
  ```html
  <button id="card-3" aria-describedby="n3-title">…</button>
  <section id="n3" aria-labelledby="n3-title"><h3 id="n3-title"><span class="num">3</span> The Tower — crossing</h3>…<p>Related: <a href="#card-1">1 · The Star</a></p></section>
  ```
  Put related-card relationships into text links, not only lines.
- DOM order should be reading order: the spread first, as a list of cards in position order, then the explanations in the same order. Keep the visual numbering identical to the DOM order.
- Focus: clicking or focusing a card scrolls its explanation into view with `scrollIntoView({behavior: reduced ? 'auto' : 'smooth', block: 'start'})` and moves focus to the heading (`tabindex="-1"`). Provide a visible `:focus-visible` ring in gold, with at least 3:1 contrast against parchment. Keep `scroll-margin-top` at least as large as the sticky header height.
- Under reduced motion, keep the active line drawn instantly; it is a meaningful pointer. Drop the dash animation, the scroll-linked reveals and View Transitions.
- Contrast: a 0.75px gold line on parchment will likely fail 3:1. Under WCAG 1.4.11 that is acceptable only if the line is not the sole carrier of information, which the numbers and text links ensure. Consider a darker "ink" stroke for the active line.
- Performance checklist:
  - passive scroll listener with one rAF;
  - batch reads, then writes;
  - ResizeObserver on the grid plus `document.fonts.ready`;
  - only a handful of paths;
  - `vector-effect: non-scaling-stroke`;
  - avoid filters on the overlay.

### Gaps
- No verified screen-reader support matrix for `aria-details` was found beyond Chrome's caveat.
- WCAG text was not fetched here; the 1.4.11 reference is from general knowledge.

## 4. Mapping to Flutter (phone app)

### Takeaway
Use these equivalents in Flutter:
- **Pinned spread:** `CustomScrollView` with a `PinnedHeaderSliver` (or `SliverPersistentHeader(pinned: true)`) holding a compact spread strip.
- **Explanations:** a `SliverList` below the header.
- **Lines:** a `CustomPainter` overlay that reads `GlobalKey` render boxes and repaints on a `ScrollController` notification.
- **Reduced motion:** `MediaQuery.disableAnimationsOf(context)`.

### Cited Findings
- `PinnedHeaderSliver` keeps its child pinned at the top of a `CustomScrollView`. Its child can change size. For a pinned header it is preferable to `SliverPersistentHeader` because it needs no delegate or size prediction. Siblings are `SliverResizingHeader` (min/max extent) and `SliverFloatingHeader` — [api.flutter.dev PinnedHeaderSliver](https://api.flutter.dev/flutter/widgets/PinnedHeaderSliver-class.html)
- The advanced sample drives header opacity from a scroll `NotificationListener` (`flutter create --sample=widgets.PinnedHeaderSliver.2`) — [same](https://api.flutter.dev/flutter/widgets/PinnedHeaderSliver-class.html)

### Inferences ([AUTHORED] Dart sketch)
```dart
class LinkPainter extends CustomPainter {
  LinkPainter(this.links, this.overlayKey, {required this.progress, required Listenable repaint})
      : super(repaint: repaint);                       // repaint on scroll without rebuild
  final List<(GlobalKey from, GlobalKey to)> links; final GlobalKey overlayKey; final double progress;
  @override
  void paint(Canvas c, Size s) {
    final origin = overlayKey.currentContext!.findRenderObject() as RenderBox;
    Offset? at(GlobalKey k, Alignment a) {
      final b = k.currentContext?.findRenderObject() as RenderBox?;
      if (b == null || !b.attached) return null;
      return origin.globalToLocal(b.localToGlobal(a.alongSize(b.size)));
    }
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = .75..color = const Color(0xFFB08D3C);
    for (final (f, t) in links) {
      final a = at(f, Alignment.centerLeft), b = at(t, Alignment.centerRight);
      if (a == null || b == null) continue;
      final mx = (a.dx + b.dx) / 2;
      final path = Path()..moveTo(a.dx, a.dy)..cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
      for (final m in path.computeMetrics()) c.drawPath(m.extractPath(0, m.length * progress), paint); // ink draw
    }
  }
  @override bool shouldRepaint(LinkPainter o) => o.progress != progress || o.links != links;
}
```
- Wrap the scroll view in a `Stack` with `IgnorePointer(child: CustomPaint(painter: LinkPainter(..., repaint: scrollController)))`. Passing the `ScrollController` as `repaint` repaints only the painter each frame.
- Off-screen sliver children have no render box, which is why `at()` returns null. Draw lines only for the active note, or fade them at the viewport edges.
- Active step, the IntersectionObserver equivalent: in `NotificationListener<ScrollNotification>`, compute each note's `localToGlobal().dy` against the viewport midline. Or use the `visibility_detector` package (pub.dev; not verified in this pass).
- The draw animation is `AnimationController` to `progress` (Path `computeMetrics`/`extractPath` = stroke-dashoffset). Scroll-linked progress means mapping `controller.offset` into a 0–1 range, as with `animation-timeline`.
- Reduced motion: `if (MediaQuery.disableAnimationsOf(context)) progress = 1;`. Skip `Hero` flights and use `Duration.zero`.
- Hero is the analogue of View Transitions (card thumbnail to detail). `ClipPath`/`ShaderMask` with a `LinearGradient` is the analogue of mask-image ink reveals.
- Accessibility: wrap the painter in `ExcludeSemantics`. Give each note `Semantics(label: '3, The Tower, crossing')` and set `sortKey: OrdinalSortKey(i)` so VoiceOver order matches the numbering. Make "Related: 1 · The Star" a tappable button that scrolls via `Scrollable.ensureVisible`.

### Gaps
- I did not fetch the Flutter API page for `MediaQuery.disableAnimationsOf`, which is from general knowledge, or check the `visibility_detector` license.
- The Flutter version that introduced `PinnedHeaderSliver` was not stated on the API page. From general knowledge it arrived in Flutter 3.24 (2024); verify.
