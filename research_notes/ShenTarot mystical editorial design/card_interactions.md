# Card interaction references and implementation for ShenTarot's drawing flow
(choose spread -> shuffle -> browse/pick -> card travels to slot -> flip -> interpret)

Research date: 2026-10-26. Verification legend: **[fetched]** = page content retrieved and read; **[search-only]** = seen in search results, not opened; **[not loaded]** = fetch failed or the page renders client-side so nothing beyond the title came back. Nothing was checked by running demos in a browser, so all "observed" behaviour comes from docs and READMEs, not from using the demos.

## Q1. Reference set (8-12): URLs, interaction to study, benefit/limits, implementation status, license

### Takeaway
The strongest *engineering* references for "card flies to its exact slot" are documented techniques and libraries (Paul Lewis' FLIP, GSAP Flip, View Transitions API, Motion `layoutId`, Flutter `Hero`). Polished open-source *tarot-specific* demos with permissive licenses are scarce. The best card-feel examples (Balatro) have no official technical breakdown, only community reimplementations.

### Cited Findings

**1. "FLIP Your Animations" by Paul Lewis (technique article) [fetched]**
- URL: https://aerotwist.com/blog/flip-your-animations/
- What to study: First (measure start), Last (apply final layout and measure), Invert (transform the element back to where it started), Play (transition the transform back to none). Example: `var invert = first.top - last.top; el.style.transform = \`translateY(${invert}px)\`;` then clear the transform on the next frame. — [aerotwist](https://aerotwist.com/blog/flip-your-animations/)
- Benefit: the measuring happens in the roughly 100 ms after user input that people don't perceive as delay, so the animation itself only touches cheap `transform`/`opacity`. — [aerotwist](https://aerotwist.com/blog/flip-your-animations/)
- Limits: work over ~100 ms makes the UI feel unresponsive; starting a new FLIP while another is running can interrupt it; scaling can distort content. — [aerotwist](https://aerotwist.com/blog/flip-your-animations/)
- License: article, no code license. It describes a technique, so we can reimplement it freely.

**2. GSAP Flip plugin (library) [fetched]**
- Docs: https://gsap.com/docs/v3/Plugins/Flip/
- What to study: the pattern is `Flip.getState(els)` -> change the DOM -> `Flip.from(state, {...})`. It supports **reparenting into another container**, including rotated or scaled containers, "which most FLIP libraries can't". Two different elements can cross-fade if they share a `data-flip-id` and use `fade: true`. — [GSAP docs](https://gsap.com/docs/v3/Plugins/Flip/)
- Robustness: `getState` completes any flip already running on a target before it measures. `Flip.killFlipsOf(targets)`, `Flip.isFlipping(target)` and `Flip.batch()` coordinate flips across components. `absolute: true` handles grid/flex layouts, and `onEnter`/`onLeave` handle cards that appear or disappear. — [GSAP docs](https://gsap.com/docs/v3/Plugins/Flip/)
- Fit for ShenTarot: a deck-to-spread-slot move into a rotated slot (e.g. the crossing card in a Celtic Cross, at 90°) is exactly the "rotated container" case it supports.
- License: after the Webflow acquisition GSAP is "100% FREE including ALL of the bonus plugins … even free for commercial uses" — [yarn package page for gsap-trial](https://classic.yarnpkg.com/en/package/gsap-trial). The docs page itself only links to Terms of Use — [GSAP docs](https://gsap.com/docs/v3/Plugins/Flip/). GSAP's license is its own "standard no-charge" license, not MIT, so the Terms should be read before shipping.

**3. View Transitions API, same-document (web platform) [fetched]**
- Docs: https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API/Using and https://developer.chrome.com/docs/web-platform/view-transitions/same-document
- What to study: `document.startViewTransition(() => updateDOM())`. Elements with a unique `view-transition-name` get their own snapshot group, which by default animates position/transform and scales size between the old and new states. — [MDN](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API/Using)
- Limits:
  - Two elements rendered with the same name at the same moment make `ready` reject, and the transition is skipped. — [MDN](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API/Using)
  - "Only one view transition is allowed to run at a time"; starting a new one makes the old one skip to the end. — [Chrome for Developers](https://developer.chrome.com/docs/web-platform/view-transitions/same-document)
  - The page is frozen while the update callback's promise is pending, so fetch data before calling it. — [Chrome for Developers](https://developer.chrome.com/docs/web-platform/view-transitions/same-document)
  - Old/new snapshots are images, so a 3D flip of live content during the transition needs separate handling (inferred from snapshots being "replaced content"). — [MDN](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API/Using)
- Support: same-document transitions since Chrome 111. `view-transition-class`: Chrome/Edge 125, Firefox 144, Safari 18.2. — [Chrome for Developers](https://developer.chrome.com/docs/web-platform/view-transitions/same-document)
- License: platform API (spec).

**4. Motion (formerly Framer Motion) `layout` / `layoutId` (React library) [fetched]**
- Docs: https://motion.dev/docs/react-layout-animations
- What to study: `layoutId` gives shared-element transitions. A newly mounted element with a matching id animates out from the old one, and `LayoutGroup` keeps sibling components in sync. All of it is done with CSS transforms. — [Motion docs](https://motion.dev/docs/react-layout-animations)
- Benefit over View Transitions: Motion animations are interruptible. The docs contrast this with View Transitions, which snap to the end first. — [Motion docs](https://motion.dev/docs/react-layout-animations)
- License: not stated on the fetched page (gap; Motion is widely reported as MIT but I didn't verify it here).

**5. Flutter `Hero` (shared-element transition) [fetched]**
- Docs: https://docs.flutter.dev/ui/animations/hero-animations; API: https://api.flutter.dev/flutter/widgets/Hero-class.html
- What to study: during the flight the hero moves to the app Overlay, above both routes. Bounds follow `createRectTween`, which defaults to `MaterialRectArcTween`, a curved path. `MaterialRectCenterArcTween` keeps the aspect ratio. — [Flutter docs](https://docs.flutter.dev/ui/animations/hero-animations)
- `flightShuttleBuilder` lets you supply a different widget for the flight, such as a card that flips while it flies. `placeholderBuilder` controls what stays in the origin slot. — [Hero API](https://api.flutter.dev/flutter/widgets/Hero-class.html)
- Limits: it only fires on Navigator push/pop, and "Routes must not contain more than one Hero for each tag". — [Flutter docs](https://docs.flutter.dev/ui/animations/hero-animations), [Hero API](https://api.flutter.dev/flutter/widgets/Hero-class.html). Deck -> spread on **one screen** therefore needs a manual Overlay + AnimationController (see Q2).
- License: Flutter SDK (BSD-3).

**6. HTML5 Deck of Cards by Juha Lindstedt (pakastin) (open-source demo) [fetched repo; demo not loaded]**
- Repo: https://github.com/deck-of-cards/deck-of-cards (~3.1k stars). Demo: https://deck.of.cards/old. The demo renders client-side, so a fetch returned only the title and its behaviour was not verified.
- What to study: a whole-deck choreography API with `deck.shuffle()`, `deck.fan()`, `deck.sort()`, `deck.flip()` and `card.flip()`. It moved from CSS transitions to JS animations (v0.1.3), and `card.animateTo({delay, duration, ease:'quartOut', x, y})` arrived in v0.1.4. — [GitHub](https://github.com/deck-of-cards/deck-of-cards)
- Benefit: the per-card `delay` parameter is the basic tool for staggering shuffle and fan motion. Limitation: it's an old, vanilla-JS DOM project, so use it as a choreography reference, not a dependency.
- License: "LGPL if you use Chris Aguilar's vector playing cards. Otherwise MIT." — [GitHub](https://github.com/deck-of-cards/deck-of-cards). The code ideas are fine to reuse, but don't ship the card art.

**7. Codrops "Card Stack Effects" (accept/reject feedback on a stack) [article not loaded (403); refactor repo fetched]**
- Original demo: http://tympanus.net/Development/CardStackEffects/ (not opened). Original article: http://tympanus.net/codrops/?p=25356 (returned **HTTP 403** to the fetcher). A refactored ESNext port with a live demo: https://github.com/globalroo/CardStackEffects / https://globalroo.github.io/CardStackEffects/ — [GitHub](https://github.com/globalroo/CardStackEffects)
- What to study: animation ideas for "positive (accept) or negative (reject) feedback" on the top card of a stack. — [GitHub](https://github.com/globalroo/CardStackEffects). This maps to the "pick/skip while browsing a stacked deck" step.
- License: the repo is MIT, but it points to Codrops terms: free to integrate in personal or commercial projects, not to republish or sell "as-is". — [GitHub](https://github.com/globalroo/CardStackEffects)

**8. react-spring "Cards Stack" (drag/fling a deck) [index fetched; sandbox not opened]**
- https://codesandbox.io/s/to6uf (listed at https://www.react-spring.dev/examples): animates a stack of cards using `useDrag`, `useSprings` and interpolation. — [react-spring examples](https://www.react-spring.dev/examples)
- What to study: spring physics plus gesture velocity, so a flung card keeps its momentum. This is the reference for "drag a card out of the deck to select it". The library license wasn't verified on the fetched page (gap).

**9. Balatro card feel (commercial game; community breakdowns only) [search-only]**
- No official technical breakdown by LocalThunk turned up in my searches. Sources are community or secondary:
  - A Godot "Balatro card tilt" shader/script tilts the card toward the cursor's relative position and eases back to flat in about 0.1 s when the cursor leaves. — [Godot Shaders](https://godotshaders.com/shader/balatro-card-tilt/)
  - A design-guide write-up describes cards that float and tilt toward the cursor with parallax on the foil, and scoring feedback stacked in layers (card motion, rolling counters, screen shake, particles, rising-pitch audio). The guide's numbers (e.g. ±3° rotation) are the author's own illustrations, not values from the game. — [Blake Crosley guide](https://blakecrosley.com/zh-Hans/guides/design/balatro) (localized version; search-only)
  - A Defold forum community challenge asked people to recreate Balatro card effects. — [Defold forum](https://forum.defold.com/t/community-challenge-recreate-balatro-card-effects-in-defold/76854)
- Licensing: the game is commercial, so study only the feel. Each community shader has its own license (not checked).

**10. Rive Marketplace "Tarot card flip animation" (asset) [search-only]**
- https://rive.app/marketplace/22477-42076-tarot-card-flip-animation, listed under CC BY. — [search result](https://rive.app/marketplace/22477-42076-tarot-card-flip-animation)
- Relevance: Rive has a Flutter runtime, so a designer-authored flip or idle shimmer could live in Rive while layout and travel stay in Flutter. Attribution is required under CC BY. The file itself wasn't inspected.

**11. Small open-source tarot web apps (low reputation, technique only) [search-only]**
- TarotWeb docs describe a CSS `preserve-3d` flip that reveals cards one by one with a **700 ms stagger**. — [Mintlify page](https://www.mintlify.com/RamirezDiazCarlos/TarotWeb/features/animations)
- https://github.com/mixvlad/TarotCards also appeared, but its contents and license were not checked.

### Inferences
- For ShenTarot, the most useful split is: *technique* references (1–5), *choreography* references (6, 8), *feedback/feel* references (7, 9), and *assets* (10).
- Desktop web: GSAP Flip is the most capable option for reparenting into rotated spread slots. View Transitions works for page-level changes (e.g. reading -> interpretation), but it is a poor fit for rapid, interruptible card moves because only one transition can run at a time and a new one snaps the old to its end.

### Gaps
- No verified Codrops tarot demo. The Codrops Card Stack article returned 403, so its date, author and techniques are unverified.
- I found no reference implementations of horseshoe or Celtic Cross *layouts* (as opposed to card motion), no web solitaire, and no Inscryption breakdown within the research budget.
- None of the demos was run in a browser. All "observed" behaviour comes from docs and READMEs.

## Q2. FLIP, View Transitions and Flutter equivalents for "card into slot" (with snippets)

### Takeaway
All three approaches do the same thing: measure the start and end rects, render the card at the end position, and animate a transform from the inverted delta back to zero. Flutter's `Hero` only does this across routes. Within one screen, use an `OverlayEntry` driven by an `AnimationController`, with rects read from `GlobalKey`s.

### Cited Findings
- FLIP order and the 100 ms measuring window. — [aerotwist](https://aerotwist.com/blog/flip-your-animations/)
- GSAP: `const state = Flip.getState(squares); swap(squares); Flip.from(state, {duration: 2, ease: "power1.inOut"});`. Reparenting is supported. — [GSAP docs](https://gsap.com/docs/v3/Plugins/Flip/)
- View Transitions: `document.startViewTransition(() => displayNewImage());`, feature-detect `document.startViewTransition`, unique `view-transition-name` per element. The default animation morphs position and size. — [MDN](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API/Using)
- Hero: flies in the Overlay; `createRectTween` and `flightShuttleBuilder` customize the flight; one Hero per tag per route. — [Flutter docs](https://docs.flutter.dev/ui/animations/hero-animations), [Hero API](https://api.flutter.dev/flutter/widgets/Hero-class.html)

Illustrative snippets. I wrote these; they apply the cited APIs and were not copied from the sources.

```js
// Vanilla FLIP: move a picked card from the fan into spread slot N (WAAPI)
function flyToSlot(card, slot) {
  const first = card.getBoundingClientRect();          // F
  slot.appendChild(card);                              // reparent
  const last = card.getBoundingClientRect();           // L
  const dx = first.left - last.left, dy = first.top - last.top;
  const sx = first.width / last.width, sy = first.height / last.height;
  card.getAnimations().forEach(a => a.cancel());       // interruption: cancel stale anims
  return card.animate([                                // I -> P
    { transform: `translate(${dx}px,${dy}px) scale(${sx},${sy})` },
    { transform: 'none' }
  ], { duration: matchMedia('(prefers-reduced-motion: reduce)').matches ? 0 : 520,
       easing: 'cubic-bezier(.2,.8,.2,1)' }).finished;
}
```

```js
// View Transitions version (good for page-level reading -> interpretation)
card.style.viewTransitionName = `card-${id}`;          // must be unique at any moment
const t = document.startViewTransition(() => slot.appendChild(card));
await t.finished; card.style.viewTransitionName = '';
```

```dart
// Flutter, same screen: Overlay + AnimationController (Hero needs a route change)
Future<void> flyToSlot(BuildContext ctx, GlobalKey from, GlobalKey to, Widget card,
    AnimationController c) async {
  final a = _rect(from), b = _rect(to);
  final tween = MaterialRectArcTween(begin: a, end: b);  // same arc Hero uses
  final entry = OverlayEntry(builder: (_) => AnimatedBuilder(
    animation: c,
    builder: (_, __) { final r = tween.lerp(Curves.easeOutCubic.transform(c.value))!;
      return Positioned.fromRect(rect: r, child: card); }));
  Overlay.of(ctx).insert(entry);
  try { await c.forward(from: 0).orCancel; } on TickerCanceled { /* interrupted */ }
  finally { entry.remove(); }                            // then show card in slot
}
Rect _rect(GlobalKey k) { final box = k.currentContext!.findRenderObject() as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size; }
// Flip during/after flight: Transform(alignment: Alignment.center,
//   transform: Matrix4.identity()..setEntry(3,2,0.001)..rotateY(pi*t), child: t<.5?back:face)
```

### Inferences
- Use `Hero` with a `flightShuttleBuilder` only for navigation, e.g. tapping a placed card to open its full-screen interpretation page. Use Overlay flights for deck -> slot moves on the same screen.
- On the web, compute the destination slot's rect (including the Celtic Cross crossing card's 90° rotation) before the user's pick lands, inside the ~100 ms window.

### Gaps
- No official Flutter documentation for an "in-route shared element" pattern was fetched. The Overlay approach is standard practice, but here it is inferred.

## Q3. Input alternatives, focus, interruption, reduced motion, duplicate picks, haptics

### Takeaway
The platform docs give the building blocks: reduced-motion flags, skip/kill APIs, and single-transition semantics. None of the card demos I reviewed documented keyboard or focus handling, so ShenTarot has to design that part itself.

### Cited Findings
- View Transitions: `transition.skipTransition()` skips the animation but still runs the DOM update. Under reduced motion, Chrome suggests a subtler animation rather than none, because "a preference for 'reduced motion' doesn't mean the user wants _no motion_". — [Chrome for Developers](https://developer.chrome.com/docs/web-platform/view-transitions/same-document)
- If the page is hidden when `startViewTransition` is called, the transition is skipped entirely. — [MDN](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API/Using)
- GSAP: `Flip.killFlipsOf`, `Flip.isFlipping`, and `getState` completing an in-flight flip before measuring. — [GSAP docs](https://gsap.com/docs/v3/Plugins/Flip/)
- Flutter: `MediaQueryData.disableAnimations` follows Android's "Remove animations" setting. **iOS Reduce Motion does not set it**; it is exposed separately as `AccessibilityFeatures.reduceMotion`. — [Flutter API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)
- Hero `transitionOnUserGestures` (default false) controls whether the hero animates during an iOS back-swipe. — [Hero API](https://api.flutter.dev/flutter/widgets/Hero-class.html)

### Inferences
- **Picking alternatives:** make every card in the fan a focusable button. Arrow keys move along the arc, Enter/Space picks, and a visible "Draw for me" button picks a random card for screen-reader and motor-impaired users. Drag should be optional, never the only way to pick.
- **Focus:** after a card lands, move focus to that slot ("Card 2 of 10, Past, face down. Press to reveal"). After the flip, announce the card name through a live region (web) or `SemanticsService.announce` (Flutter).
- **Interruption:** keep one state machine (`idle -> shuffling -> picking -> flying -> placed -> revealing -> revealed`). Ignore or queue input while in `flying`. On the web, cancel stale WAAPI/GSAP animations before starting new ones. In Flutter, use `controller.stop()` and handle `TickerCanceled`.
- **Duplicate picks / accidental redraws:** mark the card id as consumed *synchronously* on pointer-down or at a drag threshold, before the animation starts. Disable the shuffle and redraw actions once the first card is placed, and require an explicit "New reading" confirmation.
- **Reduced motion:** in Flutter, check both `MediaQuery.disableAnimations` and `PlatformDispatcher.instance.accessibilityFeatures.reduceMotion`. Swap travel and flip for a short cross-fade (~150 ms) that keeps the spatial relationship.
- **Haptics (Flutter):** a light `HapticFeedback.selectionClick()` while moving through the fan, `lightImpact` on pick, `mediumImpact` when the card lands. Desktop web has no haptics, so substitute a subtle sound behind an opt-in.

### Gaps
- No fetched card demo documented keyboard or focus handling, so those recommendations are inferred. Flutter `HapticFeedback` docs were not fetched.

## Q4. Shuffle choreography: riffle, overhand, scatter-and-gather; stagger and springs

### Takeaway
Choreography reads as intentional when it represents real state change: the order is actually randomized, and the shuffle ends because the deck is ready. It feels decorative when it loops or blocks input with no meaning. Staggered per-card delays and springs that keep gesture velocity are the core tools.

### Cited Findings
- Per-card `delay`/`duration`/`ease` (`quartOut`) via `card.animateTo()` is how deck-of-cards sequences shuffle and fan. — [GitHub](https://github.com/deck-of-cards/deck-of-cards)
- A tarot web app reveals cards one by one with a 700 ms stagger. — [Mintlify/TarotWeb](https://www.mintlify.com/RamirezDiazCarlos/TarotWeb/features/animations) (search-only)
- Spring physics plus drag velocity (`useDrag` + `useSprings`) for a card stack. — [react-spring examples](https://www.react-spring.dev/examples)
- Balatro-style feel comes from layering several feedback channels (motion, numbers, particles, audio), and the tilt eases back in ~0.1 s. — [Blake Crosley guide](https://blakecrosley.com/zh-Hans/guides/design/balatro) (secondary), [Godot Shaders](https://godotshaders.com/shader/balatro-card-tilt/)

### Inferences
- **Riffle:** split the deck into two half-stacks (translate ±x, rotate ±6°), then interleave cards back to the center with a 15–25 ms stagger that alternates between halves. **Overhand:** move small packets (3–6 cards) from the bottom to the top, 3–4 times. **Scatter-and-gather:** fits a "mystical" tone. Cards drift to random positions and rotations (spring, low stiffness) and then gather to the center with a staggered ease-out.
- Keep a full shuffle to about 1.2–1.8 s and let a tap skip it. Show it only once per reading. Under reduced motion, replace it with a single "deck settles" pulse.
- Fan: lay cards on an arc (angle = lerp(−θ, θ, i/(n−1)), translateY = r·(1−cos angle)) with a ~10 ms per-card stagger. On hover or focus, lift the card on the y-axis and tilt it toward the pointer (Balatro-style), returning in ~100 ms.
- Use springs for responses to the user (drag release, hover lift) and timed curves for authored sequences (shuffle, travel), so sequences have predictable durations for the state machine.

### Gaps
- No primary source (GDC talk, developer blog) breaks down Balatro's or Inscryption's card motion. All durations above are recommendations, not measured values.

## Q5. Reputation claims (Awwwards/Codrops)

### Takeaway
I could verify only that the Codrops Card Stack Effects demo and article URLs exist, as cited by a third-party repo; the article itself returned 403. I found no Awwwards page for any tarot card-interaction site, so no awards should be claimed.

### Cited Findings
- Codrops Card Stack Effects article (p=25356) and demo URL are cited by the refactor repo. — [GitHub](https://github.com/globalroo/CardStackEffects). A direct fetch of the article returned HTTP 403 (not loaded).
- Codrops' GSAP author hub exists and lists GSAP posts, e.g. "Consecutive Scrub Flips" (Feb 27 2024), which is a ScrollTrigger technique, not card travel. — [Codrops hub](https://tympanus.net/codrops/hub/author/gsap) (search-only)
- deck-of-cards' ~3.1k GitHub stars are a verifiable popularity signal. — [GitHub](https://github.com/deck-of-cards/deck-of-cards)

### Inferences
- In the final report, call these "reference implementations" or "documented techniques", not "award-winning".

### Gaps
- No Awwwards pages were found or verified. Codrops article dates and authors are unverified because of the 403.
