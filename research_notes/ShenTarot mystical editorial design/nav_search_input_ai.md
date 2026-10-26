# Navigation, search, inputs, button states and AI-concept presentation for ShenTarot (Mystical & Editorial)

Scope note: 15 references were checked this session, 12 of them in depth. Each item says whether it was **inspected** (page fetched and read this session), **documented** (from the source's own docs, fetched), or **inferred** (my own synthesis or framework knowledge, not verified this session). Links marked "did not load" returned an error to the fetch tool.

Reference index (quick table)

| # | Reference | Live URL | Code / breakdown | License | Status |
|---|---|---|---|---|---|
| 1 | WAI-ARIA APG Disclosure Navigation | https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/examples/disclosure-navigation/ | same page (JS/CSS linked) | W3C Software License per footer, "not intended for production" | documented |
| 2 | APG Modal Dialog (focus trap / return focus) | https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/ | same | W3C | documented |
| 3 | APG Combobox with list autocomplete | https://www.w3.org/WAI/ARIA/apg/patterns/combobox/examples/combobox-autocomplete-list/ | same | W3C, illustrative only | documented |
| 4 | APG Button (toggle, aria-pressed) | https://www.w3.org/WAI/ARIA/apg/patterns/button/ | same | W3C | documented |
| 5 | cmdk (command menu) | https://github.com/pacocoursey/cmdk | README | MIT | documented |
| 6 | Fuse.js (fuzzy, typo-tolerant search) | https://www.fusejs.io/ | https://github.com/krisk/Fuse | Apache-2.0 (repo sidebar; about 20.5k stars) | documented |
| 7 | Codrops LineHoverStyles (ink underline draws) | http://tympanus.net/Development/LineHoverStyles/ | https://github.com/codrops/LineHoverStyles ; article https://tympanus.net/codrops/2021/02/10/simple-css-line-hover-animations-for-links (403, did not load) | MIT | repo documented; article via search snippet only |
| 8 | GOV.UK focus states | https://design-system.service.gov.uk/get-started/focus-states/ | govuk-frontend Sass `govuk-focused-text` | Content OGL v3; code license not checked this session | documented |
| 9 | GOV.UK Character count | https://design-system.service.gov.uk/components/character-count/ | same page | OGL v3 (content), Crown copyright | documented |
| 10 | GOV.UK Phase banner | https://design-system.service.gov.uk/components/phase-banner/ | same page | OGL v3 | documented |
| 11 | iA Writer (Focus Mode, authorship colouring) | https://ia.net/writer | none (commercial app) | proprietary | inspected (marketing page) |
| 12 | Apple HIG: Generative AI | https://developer.apple.com/design/human-interface-guidelines/generative-ai (JS-rendered; read via JSON endpoint https://developer.apple.com/tutorials/data/design/human-interface-guidelines/generative-ai.json) | n/a | Apple docs | documented |
| 13 | Google PAIR Guidebook: Mental Models | https://pair.withgoogle.com/chapter/mental-models/ | n/a | PAIR site (license not checked) | documented |
| 14 | IBM Carbon for AI (AI label + explainability popover) | https://carbondesignsystem.com/guidelines/carbon-for-ai/ | `@carbon/themes`, `@carbon/ai-chat` (license not stated on page; Carbon is generally Apache-2.0, not verified this session) | see note | documented |
| 15 | Are.na (calm, non-feed browsing) | https://www.are.na/about | none | proprietary | inspected |
| 16 | Flutter SearchAnchor | https://api.flutter.dev/flutter/material/SearchAnchor-class.html | Flutter SDK | BSD-3 (Flutter SDK; from knowledge) | documented |

Not loaded / not used: Codrops article page (HTTP 403). `pair.withgoogle.com/guidebook/patterns` and the Apple HIG HTML page returned only a title (client-rendered); I used the chapter page and Apple's JSON endpoint instead. I did not inspect Readwise or Craft this session; no claims are made about them.

---

## Navigation: expressive menus, disclosures, keyboard/focus, touch targets

### Takeaway
Build the top bar and margin "contents" menus as **disclosure buttons (`aria-expanded` + `aria-controls`)**, not ARIA `menu`. Escape closes and returns focus to the button. A full-screen "folio" overlay is a **modal dialog**: trap Tab, close on Escape, return focus. The expressive part (big serif index, ruled lines, a staggered line-by-line reveal) is purely visual. Codrops demos for it exist but are proofs of concept, not production code.

### Cited Findings
- APG disclosure navigation: Tab/Shift+Tab move through the top-level buttons and, when a dropdown is open, through its links. Space or Enter toggles a dropdown. **Escape closes an open dropdown and moves focus to its button.** Moving focus out of the nav region also closes it. Arrow, Home and End keys are optional extras and do not replace Tab — [APG Disclosure Navigation](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/examples/disclosure-navigation/)
- Attributes: `aria-controls` and `aria-expanded` on the `<button>`, `aria-current="page"` on the active link. CSS attribute selectors keep the visual state in sync with `aria-expanded` — [APG Disclosure Navigation](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/examples/disclosure-navigation/)
- APG deliberately **does not use `role="menu"`** for site navigation, because typical navigation doesn't need the full menu keyboard model. It says Escape handling is needed for WCAG 2.1 SC 1.4.13 — [APG Disclosure Navigation](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/examples/disclosure-navigation/)
- APG marks the example code "not intended for production environments" and recommends testing with assistive technology. The footer points to the W3C Software License — [APG Disclosure Navigation](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/examples/disclosure-navigation/)
- Modal dialog: Tab and Shift+Tab cycle within the dialog and wrap at both ends. Escape closes. Initial focus usually goes to the first focusable element. For long or structured content, focus a static title (`tabindex="-1"`) so the top stays in view. On close, focus returns to the invoking element unless that element is gone or the workflow moves on — [APG Modal Dialog](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)
- Codrops "Layout with Reveal Animations and Content Preview" (2021) has line-by-line typographic reveals paired with a menu. The author calls it an animation proof of concept, not a properly made template. "Multibox Menu" (2018) is a full-screen CSS Grid menu with box reveals built on TweenMax — [Codrops 2021](https://tympanus.net/codrops/2021/07/28/layout-with-reveal-animations-and-content-preview), [Codrops Multibox](https://tympanus.net/codrops/2018/10/03/multibox-menu) (from search snippets only, not fetched)

### Implementation notes (inferred unless cited)
Margin/contents disclosure (desktop). This uses the same structure as APG, with editorial styling.
```html
<nav aria-label="Main">
  <button class="nav-toggle" aria-expanded="false" aria-controls="spreads">Spreads</button>
  <ul id="spreads" hidden>
    <li><a href="/spreads/celtic-cross" aria-current="page">Celtic Cross <span class="folio">x</span></a></li>
  </ul>
</nav>
```
```js
btn.addEventListener('click', () => {
  const open = btn.getAttribute('aria-expanded') === 'true';
  btn.setAttribute('aria-expanded', String(!open));
  panel.hidden = open;
});
nav.addEventListener('keydown', e => {
  if (e.key === 'Escape' && btn.getAttribute('aria-expanded') === 'true') {
    btn.click(); btn.focus();             // close and return focus (APG)
  }
});
nav.addEventListener('focusout', e => {   // close when focus leaves the nav (APG)
  if (!nav.contains(e.relatedTarget) && btn.getAttribute('aria-expanded') === 'true') btn.click();
});
```
```css
.nav-toggle::after { content: ""; display:inline-block; width:.5em; height:1px; background:currentColor;
  margin-left:.4em; transition: transform .2s; }               /* fine rule, not a chevron */
.nav-toggle[aria-expanded="true"]::after { transform: rotate(90deg); }
```
- For a static "About this card" section, a native `<details><summary>` needs no JS and exposes expanded state natively (from knowledge). Style the `summary` marker as a small gold fleuron or rule.
- Full-screen "folio" menu (phone): use `<dialog>` with `showModal()`. The browser makes the rest of the page inert and Escape closes it (from knowledge, consistent with APG behaviour). Store `document.activeElement` before opening and restore it on `close`. Stagger the menu items line by line (Codrops-style), gated by `prefers-reduced-motion`.
- Touch targets: keep at least 44×44 pt (Apple) or 48 dp (Material) even when the visible ink is a thin serif word. Pad the hit area, not the type (from knowledge, not re-verified this session).
- **Flutter:** use `MenuAnchor` / `SubmenuButton` for dropdowns, or a custom `OverlayPortal`. Wrap the toggle in `Semantics(expanded: isOpen, button: true)`. Modal routes (`showDialog`, `showGeneralDialog` for a full-screen folio) scope focus to the route, Escape maps to `DismissIntent` by default, and focus returns to the previous route's focus when it pops. `ExpansionTile` or a custom `AnimatedSize` gives the details/summary analogue. Use `FocusTraversalGroup` to order the margin menu (framework knowledge, inferred; verify against the current Flutter version).

### Gaps
- I could not fetch the Codrops pages directly (403 on tympanus.net article URLs), so the reveal-animation details come from search snippets.
- I found no single "editorial margin menu" reference with a published accessibility audit.

---

## Search: command palette, illustrated results, typo tolerance, empty states, accessible combobox

### Takeaway
Use the **APG editable combobox (list autocomplete)** semantics with **Fuse.js-style fuzzy matching**, so "hirophant" still finds The Hierophant. Present results as a ruled list with a small card thumbnail and arcana/suit metadata, not a grid of tiles. cmdk shows the palette's anatomy: Dialog, Input, List, Group, Empty, Loading.

### Cited Findings
- APG combobox: DOM focus stays in the `<input role="combobox" aria-autocomplete="list" aria-controls aria-expanded>`. The highlighted option is exposed with `aria-activedescendant`, and options are `role="option"` inside `role="listbox"`. Down/Up moves through options and wraps. Enter accepts. **Escape closes the list, or clears the input if the list is already closed.** Typing returns visual focus to the textbox and filters — [APG Combobox List Autocomplete](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/examples/combobox-autocomplete-list/)
- Browsers don't scroll `aria-activedescendant` targets into view, so the script must do it (this matters for zoom users). APG uses borders and padding rather than transparency for focus and hover so they survive high-contrast mode, and uses `forced-color-adjust: auto` with `currentcolor` on the SVG arrow. Support varies on mobile and touch, and the example is not production-ready — [APG Combobox List Autocomplete](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/examples/combobox-autocomplete-list/)
- cmdk (MIT) is a "Fast, unstyled command menu React component" that filters and sorts automatically. It accepts a custom `filter(value, search, keywords)` ranking function. `keywords` work as aliases, and `shouldFilter={false}` lets you filter yourself. `Command.Empty` renders when nothing matches and can echo the query through `useCommandState`. `Command.Loading` covers async results. `Command.Dialog` builds on the Radix Dialog, and the README's global-shortcut example uses ⌘/Ctrl+K. Its accessibility was tested with VoiceOver and Chrome DevTools. The README does not call the default matching fuzzy — [cmdk](https://github.com/pacocoursey/cmdk)
- Fuse.js is a zero-dependency fuzzy search library using the Bitap algorithm, with "typo-tolerant matching". Builds are about 8.6 kB (full) or 6.8 kB (basic) gzipped. Apache-2.0, about 20.5k stars — [Fuse.js](https://www.fusejs.io/), [GitHub krisk/Fuse](https://github.com/krisk/Fuse)
- Flutter `SearchAnchor` opens a search-view route with a `builder` (anchor) and a `suggestionsBuilder`, controlled by `SearchController.openView`. **By default the view is full screen only on mobile** (`isFullScreen` overrides this). A non-full-screen view pops on window resize, while a full-screen one persists through rotation — [Flutter SearchAnchor](https://api.flutter.dev/flutter/material/SearchAnchor-class.html)

### Implementation notes
- Index the 78 cards with `name`, `aliases` (for example "Pope" for Hierophant, "Wheel" for Wheel of Fortune), `keywords` (upright and reversed meanings), and `suit`/`arcana`. Fuse can search with weights such as `keys: [{name:'name',weight:3},'aliases','keywords']`. Its `threshold` option, about 0.3–0.4, controls tolerance (from knowledge; the fusejs.io home page does not document threshold).
- Illustrated result row (inferred):
```html
<li role="option" id="opt-hierophant" aria-selected="false" class="result">
  <img src="/cards/05-thumb.webp" alt="" width="40" height="68"> <!-- decorative; name is the label -->
  <span class="result-name">The Hierophant</span>
  <span class="result-meta">Major Arcana · V</span>
</li>
```
```css
.result { display:grid; grid-template-columns:40px 1fr auto; gap:.75rem; padding:.5rem 0;
  border-bottom:1px solid var(--rule); }
.result[aria-selected="true"] { box-shadow: inset 2px 0 0 var(--gold); }  /* margin rule, not a filled pill */
.result-meta { font-variant: small-caps; letter-spacing:.04em; color:var(--ink-muted); }
```
- Empty state: echo the query and offer a nearest match or a browse route, as in cmdk's `Command.Empty` with `useCommandState`. Example copy: `No card called "hierphnt". Did you mean The Hierophant? · Browse the Major Arcana`. Use a small ink vignette, not a big illustration. A polite live region should announce the result count (inferred).
- **Flutter:** on phone, `SearchAnchor` gives the full-screen view for free. On desktop, `RawAutocomplete` (or `SearchAnchor` with `isFullScreen:false`) with custom `optionsViewBuilder` rows. Run the fuzzy match in Dart (`fuzzy` / `string_similarity` packages exist on pub.dev, not verified this session; a small Levenshtein implementation also works for 78 items). Wrap rows in `Semantics(selected: highlighted)` (inferred).

### Gaps
- I did not verify cmdk's exact default matching algorithm. The README describes ranking but doesn't call it fuzzy.
- I did not find an authoritative source on combining images with combobox options. The alt="" choice is my inference from general alt-text practice.

---

## Writing inputs: question field and reflection journal

### Takeaway
Borrow iA Writer's restraint (no chrome, focus on the current sentence) and GOV.UK's honest character count, which appears only near the limit, never blocks typing, and announces politely. Guide reflection with placeholders and suggested prompts, as Apple HIG suggests for open-ended inputs. Protect drafts with local autosave.

### Cited Findings
- iA Writer Focus Mode "highlights the sentence or paragraph you're working on and fades everything else". The interface has "No buttons, no popups, no title bar." Style Check "flags clichés, fillers, and clutter" on device. **It also tracks typed vs pasted text and shows AI-generated text in colour**, separate from the user's own black/white text — [iA Writer](https://ia.net/writer)
- The iA Writer page does not mention autosave or typewriter mode — [iA Writer](https://ia.net/writer) (gap, not a claim that the features are absent)
- GOV.UK Character count shows the remaining count below the textarea. Screen reader users hear it once they stop typing. **It does not block input over the limit**: an error appears and a red border shows only when the limit is exceeded. `data-threshold` (for example 85%) hides the count until near the limit. Without JS, a static "You can enter up to N characters" message shows. `data-count-type="words"` counts words. The guidance says to use it only with good reason, and to raise backend limits if users keep hitting them — [GOV.UK Character count](https://design-system.service.gov.uk/components/character-count/)
- Apple HIG: for open-ended inputs, "consider offering curated suggestions that make it easy to get started" — [Apple HIG Generative AI (JSON)](https://developer.apple.com/tutorials/data/design/human-interface-guidelines/generative-ai.json)

### Implementation notes (inferred unless cited)
```html
<label for="q" class="eyebrow">Your question</label>
<p id="q-hint" class="hint">Open questions work best — "What should I understand about…" rather than "Will I…?"</p>
<textarea id="q" aria-describedby="q-hint q-count" maxlength="" rows="2"
  placeholder="What do I need to see clearly about this change?"></textarea>
<p id="q-count" class="count" aria-live="polite" hidden></p>
```
- Don't use the HTML `maxlength` attribute: GOV.UK's model lets people overshoot and then edit. Show `24 characters left` in small italic below the baseline rule once past about 85%, and switch to the "too many" message with oxblood ink when over.
- Style the field as a ruled line or ledger (bottom border only, serif body, generous leading), not a boxed rounded input. Keep the label visible; the placeholder is only an example.
- Reflection journal: a full-width column of about 60–70ch with a soft fade on non-current paragraphs (iA-style focus, optional). Rotating prompt chips under the field, such as "What surprised you?" and "Where does this card show up this week?", insert text only when tapped.
- Autosave: debounce about 800 ms to local storage keyed by reading ID. Show a quiet "Saved to this device · 14:02" note in the margin. On return, restore and offer "Discard draft". Warn with `beforeunload` only if there is unsaved text that failed to persist.
- **Flutter:** `TextField(maxLength: null, decoration: InputDecoration(border: UnderlineInputBorder(), hintText: ...))` plus a custom `buildCounter` that returns null until the threshold. Leave `maxLengthEnforcement` unset, or count manually, to allow overshoot. Announce with `SemanticsService.announce` after a debounce. Autosave through a `TextEditingController` listener with `Timer` debounce into `shared_preferences` or a local DB. `RestorationMixin` with `RestorableTextEditingController` survives process death on mobile (framework knowledge, inferred).

### Gaps
- No verified source on autosave patterns from iA Writer, Readwise or Craft (not inspected this session).

---

## Button states in an editorial style; card selection; upright/reversed toggle

### Takeaway
Use **ink underline draws** for hover (Codrops LineHoverStyles, MIT), a **letterpress press state** (a slight inset shadow and 1px downward shift, no colour flash), and a **high-contrast `:focus-visible`** treatment. GOV.UK's yellow-plus-black ring proves contrast on any background, but ShenTarot should adapt it to ink and gold while keeping a 3:1 contrast against parchment. For orientation, use an `aria-pressed` toggle with a **stable label** ("Reversed"), or a two-option radio group.

### Cited Findings
- Codrops LineHoverStyles: "simple & subtle line hover animations for links using CSS only". MIT license; demo at tympanus.net/Development/LineHoverStyles/ — [GitHub codrops/LineHoverStyles](https://github.com/codrops/LineHoverStyles)
- The accompanying 2021 article mostly uses pseudo-element lines. One variant animates an SVG stroke's dash offset, with path length normalised so the real length need not be measured — [Codrops 2021 article (search snippet; page returned 403)](https://tympanus.net/codrops/2021/02/10/simple-css-line-hover-animations-for-links)
- GOV.UK focus: links get a yellow background and a thick black bottom border; inputs get a yellow outline and a thickened black border. The aim is WCAG 2.2 SC 1.4.11 contrast on any GOV.UK background colour. The page uses `:focus`, not `:focus-visible` — [GOV.UK Focus states](https://design-system.service.gov.uk/get-started/focus-states/)
- APG toggle: expose state with `aria-pressed`. "It is critical the label on a toggle does not change when its state changes." Space and Enter activate it — [APG Button](https://www.w3.org/WAI/ARIA/apg/patterns/button/)

### Implementation notes (snippets inferred, built on cited techniques)
```css
/* Ink underline draw (pseudo-element technique, as in LineHoverStyles) */
.ink-link { position:relative; text-decoration:none; color:var(--ink); }
.ink-link::after { content:""; position:absolute; left:0; right:0; bottom:-.15em; height:1px;
  background:currentColor; transform:scaleX(0); transform-origin:right; transition:transform .35s cubic-bezier(.2,.7,.2,1); }
.ink-link:hover::after, .ink-link:focus-visible::after { transform:scaleX(1); transform-origin:left; }

/* Letterpress button: rule-bordered, presses *into* the paper */
.btn { font: 500 0.95rem/1 var(--serif); letter-spacing:.08em; text-transform:uppercase;
  padding:.8rem 1.4rem; border:1px solid var(--ink); background:transparent; color:var(--ink); border-radius:0; }
.btn:hover  { background: color-mix(in srgb, var(--ink) 6%, transparent); }
.btn:active { transform: translateY(1px); box-shadow: inset 0 1px 2px rgb(0 0 0 / .18); }
.btn:focus-visible { outline: 2px solid var(--ink); outline-offset: 3px;
  box-shadow: 0 0 0 6px var(--gold-soft); }    /* double ring: ink for contrast, gold for brand */

/* Selected card / spread position */
.position[aria-pressed="true"], .card[aria-selected="true"] { outline:1px solid var(--gold); outline-offset:6px; }
.position[aria-pressed="true"]::before { content:"✦"; /* small gold mark + not colour alone */ }

@media (prefers-reduced-motion: reduce) { .ink-link::after { transition:none; } }
@media (forced-colors: active) { .btn:focus-visible { outline-color: Highlight; } }
```
Orientation toggle (stable label, per APG):
```html
<button class="toggle" aria-pressed="false">Reversed</button>
<!-- or, for an explicit choice: -->
<fieldset class="orient"><legend class="sr-only">Orientation</legend>
  <label><input type="radio" name="o" value="upright" checked> Upright</label>
  <label><input type="radio" name="o" value="reversed"> Reversed</label>
</fieldset>
```
- Show the state visually by rotating a small card glyph 180°, plus the word in small caps. Don't rely on gold alone; pair it with a mark (✦) and a weight change.
- Correction controls ("Change card", "Mark as reversed") should be text buttons with an ink underline and an undo affordance, not icon-only.
- **Flutter:** use a custom `ButtonStyle` with `WidgetStateProperty.resolveWith` for `hovered`/`pressed`/`focused`/`selected` (in Flutter 3.22+ these are `WidgetState`, formerly `MaterialState`). Use `OutlinedBorder` = `RoundedRectangleBorder(borderRadius: BorderRadius.zero)` and `overlayColor` low-alpha ink. For the press, an `AnimatedSlide`/`Transform.translate` of 1 px. Draw the underline with a `CustomPainter` or an `AnimatedContainer` width driven by `MouseRegion` + `Focus`. Use `FocusableActionDetector` for hover/focus highlight callbacks. For the toggle, `Semantics(toggled: isReversed, button: true, label: 'Reversed')` or `SegmentedButton` restyled. Card selection uses `Semantics(selected: true)`. Respect `MediaQuery.disableAnimationsOf(context)` (framework knowledge, inferred).

### Gaps
- I didn't verify ink-on-parchment contrast ratios. Measure the actual palette for SC 1.4.11 (3:1 for focus indicators and UI boundaries).
- I found no published "letterpress button" design-system component. The press state is my synthesis.

---

## Presenting a clearly labelled future AI companion concept honestly

### Takeaway
Label it as a **concept, not a feature**: a GOV.UK-style phase tag ("Concept" / "In development") with one plain sentence. Use explicit "AI" wording, as Apple HIG and Carbon do. State what it will and won't do and that it can be wrong, following PAIR's mental-models guidance. Avoid a human persona that implies more capability than it has. Opt-in interest is fine; fake waitlist urgency, pre-checked boxes and teaser features that look usable are not. iA Writer's authorship colouring is a strong, on-brand precedent for marking AI-written text distinctly if the companion ships.

### Cited Findings
- Apple HIG: "Clearly identify when and where you use AI". "Set clear expectations about what your AI-powered feature can and can't do". Disclose limitations up front and "explain why inferior results occur". "clearly communicate that AI-generated content may contain errors". Avoid AI content where hallucination "could misinform and harm someone". "Keep people in control". Offer Edit/Undo/Retry. "Always make providing feedback voluntary." — [Apple HIG Generative AI](https://developer.apple.com/tutorials/data/design/human-interface-guidelines/generative-ai.json)
- Apple HIG (as fetched) does not directly address anthropomorphism. The closest rule is not tricking people about who or what created content — [Apple HIG Generative AI](https://developer.apple.com/tutorials/data/design/human-interface-guidelines/generative-ai.json)
- PAIR: be upfront about what the product can and can't do at first contact, and avoid hype such as "AI magic". Describe benefits rather than technology. Onboard in stages: "explain what it can do, what it can't do, how it may change, and how to improve it". Clearly disclose that it is an algorithm-powered system, not a human. Calibrate humanisation to real abilities. First-person chatbot language can imply near-human understanding — [PAIR Mental Models](https://pair.withgoogle.com/chapter/mental-models/)
- Carbon for AI: the AI label is "the primary indicator to communicate that AI is present". It triggers an explainability popover with a short in-context explanation and an option to dig deeper. It offers revert-to-AI after edits. Its visual language uses glow and gradients, with a warning against using them as decoration — [Carbon for AI](https://carbondesignsystem.com/guidelines/carbon-for-ai/)
- GOV.UK phase banner: a tag (Alpha/Beta) plus one line, "This is a new service. We're still working on ways to improve it." It goes inside the header and is used until the service passes assessment. The July 2026 guidance moved feedback into a separate Feedback component — [GOV.UK Phase banner](https://design-system.service.gov.uk/components/phase-banner/)
- iA Writer shows AI-generated text in colour, separate from the user's own text — [iA Writer](https://ia.net/writer)

### Implementation notes (inferred)
- Concept card or page, in the editorial register:
  - Eyebrow tag: `CONCEPT · NOT YET AVAILABLE` (small caps, 1px ink border, no gold glow). Carbon's glow and gradient AI styling conflicts with the brief, so take Carbon's *label + popover* structure but render the label as an ink "AI" small-caps tag with an ⓘ disclosure.
  - Headline: "A reading companion, powered by AI". Name the technology; use no human name or face. If it gets a name, give it an object or role name ("The Margin Notes") rather than a person's.
  - "What it would do": reflect your own journal entries back, suggest questions, explain card symbolism.
  - "What it won't do": predict events, give medical/legal/financial advice, or replace your own interpretation. "It can be wrong."
  - "Your words stay yours": AI-written text would be marked in a distinct ink (iA precedent), and you can edit, undo or discard it (Apple HIG).
  - Optional: "Tell me when it's ready" (unchecked, separate consent, one-click unsubscribe) and "Not interested" (dismisses permanently). No countdowns, fake scarcity, "x people waiting" counters, or disabled-looking UI that suggests it works today.
- Avoid first-person ("I sense…") and mystical certainty language for the AI. It conflicts with PAIR's calibration guidance and is especially risky in a divination context.
- **Flutter:** concept tag = `Container` with `Border.all(width:1)` + small-caps `Text` (`FontFeature.enable('smcp')` if the font supports it). The ⓘ uses `Tooltip`/`MenuAnchor` popover with `Semantics(label: 'About this AI concept')`. AI-authored spans use `TextSpan` with a distinct ink colour plus a semantic label, so colour is not the only signal.

### Gaps
- I didn't inspect how Readwise, Craft or Notion label AI features this session. Verify before citing them.
- Carbon component code licensing was not stated on the guideline page; check `@carbon/*` repos.
- No authoritative source found specifically on "coming soon" dark patterns. The anti-pattern list above is my inference from the cited consent and expectation guidance.

---

## Additional reference: calm browsing (Are.na)

### Takeaway
Are.na is a useful tone reference for card browsing without a feed: channels of "blocks", grid **and table** views, and a paid membership with no ads. A list/table toggle suits browsing 78 cards editorially, like an index of plates.

### Cited Findings
- Are.na calls itself "a mindful space where you can work through any project over time". Channels are "containers that are editable, arrangeable and searchable". It offers grid and table views, presentation mode, and dark mode/themes. The typeface is Areal by Dinamo. It is member-funded with no ads. Search scope covers your channels, your network, and all of Are.na — [Are.na About](https://www.are.na/about)

### Inferences
- Offer a "Plates" (image grid with thin rules and captions, no cards-with-shadows) / "Index" (ruled table: numeral, name, arcana, keywords) toggle as a two-option radio group, with the same semantics as the orientation control above.

### Gaps
- The about page doesn't mention likes or algorithmic feeds. I can't confirm Are.na's policy from it.
