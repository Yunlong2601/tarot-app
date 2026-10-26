# AI chat / conversation UI patterns for ShenTarot's reading page (Mystical & Editorial, phone-first Flutter)

Scope: the post-reading area where the user can (a) ask a follow-up question (1 credit), (b) draw a clarifier card (1 credit), (c) write a private journal note. Research date 2026-10-26.

Evidence labels used below:
- **Inspected**: I read the source code (via GitHub API) or the live doc page in this session.
- **Documented**: stated by the vendor's docs/help page, loaded this session, but I did not run the product.
- **Inferred / not loaded**: from general product knowledge; the page was not loaded this session. Treat as hypothesis to verify on device.

## Reference table (11 references)

| # | Reference | Live / demo URL | Code URL | License (verified) | Interaction worth studying | Evidence |
|---|---|---|---|---|---|---|
| 1 | Vercel Chatbot template (formerly "ai-chatbot") | https://chatbot.ai-sdk.dev (demo: https://chatbot.ai-sdk.dev/demo, not loaded) | https://github.com/vercel/chatbot | Apache-2.0 (LICENSE file: "Copyright 2024 Vercel, Inc. Licensed under the Apache License, Version 2.0"); GitHub API reports NOASSERTION, file text is Apache | Send/Stop swap, "Thinking" row with specific status text, empty-state-only suggestions, scroll-to-bottom pill, vote/copy actions | Inspected |
| 2 | AI Elements (Vercel, shadcn registry) | https://elements.ai-sdk.dev | https://github.com/vercel/ai-elements (components vendored in chatbot repo `components/ai-elements/`) | Apache-2.0 (LICENSE file "Copyright 2023 Vercel, Inc.") | `PromptInputSubmit` 4-state button; IME-safe Enter; `Conversation` = `role="log"` + stick-to-bottom | Inspected. Site says project "will be deprecated at the end of November 2026" and is moving to shadcn/ui |
| 3 | assistant-ui | https://www.assistant-ui.com | https://github.com/assistant-ui/assistant-ui | MIT | `ThreadPrimitive.Viewport turnAnchor="top"` (question pinned to top, answer streams below) and `ScrollToBottom` that disables itself at bottom | Inspected (docs mdx + source) |
| 4 | use-stick-to-bottom | https://use-stick-to-bottom.samdenty.io/ (not loaded) | https://github.com/stackblitz-labs/use-stick-to-bottom | MIT | Bottom-pinning that releases when the reader scrolls up | Inspected (as used in AI Elements `Conversation`) |
| 5 | LibreChat | https://librechat.ai/ (not loaded) | https://github.com/danny-avila/LibreChat | MIT | Full open ChatGPT-style app; uses `aria-live` regions (code search hit) | License inspected; UI not inspected |
| 6 | Open WebUI | https://openwebui.com (not loaded) | https://github.com/open-webui/open-webui | **Custom "Open WebUI License"** (BSD-style + clause 4 forbidding altering/removing "Open WebUI" branding above a user-count threshold). NOT plain MIT/BSD; do not copy code into ShenTarot without review | Reference only | License inspected |
| 7 | Flyer Chat (flutter_chat_ui v2) | https://flyer.chat (not loaded) | https://github.com/flyerhq/flutter_chat_ui | Apache-2.0 | Flutter builders to replace bubbles; `flyer_chat_text_stream_message` package for chunked AI text with fade-in | Documented (README) |
| 8 | Apple HIG – Generative AI | https://developer.apple.com/design/human-interface-guidelines/generative-ai | n/a | Apple docs | Disclosure, specific progress copy, refine/revert, voluntary feedback, privacy | Documented (loaded via JSON endpoint) |
| 9 | Google PAIR Guidebook (Mental Models; Explainability + Trust) | https://pair.withgoogle.com/chapter/mental-models/ ; https://pair.withgoogle.com/chapter/explainability-trust/ | n/a | Google docs | Persona restraint ("not a human"), benefit-not-tech framing, explain "why" in high-stakes | Documented |
| 10 | Microsoft HAX – 18 Guidelines for Human-AI Interaction (Amershi et al., CHI 2019) | https://www.microsoft.com/en-us/haxtoolkit/library/ | n/a | Microsoft docs | G1/G2 capability & limits, G8 dismissal, G9 correction, G15 granular feedback, G16 consequences of actions (=credit cost) | Documented |
| 11 | Rosebud (AI journal) "Go deeper" | https://help.rosebud.app/tools-for-growth/dig-deeper | closed source | proprietary | User-triggered AI inside a private entry: Interactive (1 perspective + 1 question) vs Focused (3 questions) | Documented (help page); privacy claims conflicting, see below |

Editorial transcript products (Claude.ai, Perplexity, ChatGPT, Notion AI, Arc/Dia) were **not loaded** this session (they need sign-in or are app-only); observations about them are marked inferred.

---

## Composer patterns (growing input, send/stop, follow-up chips, context chips, credit disclosure)

### Takeaway
The strongest open-source composers use one button whose meaning changes with request status (send → spinner → stop → error) and a textarea that grows to a cap; suggestions appear only on the empty state. Nothing in the inspected OSS code discloses cost before sending, so ShenTarot's 1-credit disclosure must be designed from HAX G16 ("Convey the consequences of user actions") rather than copied.

### Cited Findings
- AI Elements `PromptInputSubmit` maps `status` to icon: `submitted` → Spinner, `streaming` → Square (stop), `error` → X, otherwise Enter glyph; `isGenerating = status === "submitted" || status === "streaming"`; when generating, click calls `onStop()` and `type` becomes `"button"`; `aria-label` toggles "Stop"/"Submit". — [vercel/chatbot components/ai-elements/prompt-input.tsx](https://github.com/vercel/chatbot/blob/main/components/ai-elements/prompt-input.tsx) (Inspected, Apache-2.0)
- The textarea uses CSS `field-sizing-content max-h-48 min-h-16` (grows with content, capped). — [prompt-input.tsx](https://github.com/vercel/chatbot/blob/main/components/ai-elements/prompt-input.tsx)
- Enter submits, Shift+Enter inserts newline, and Enter is ignored while an IME composition is active (`isComposing || e.nativeEvent.isComposing`), important for CJK input; it also refuses to submit if the submit button is disabled; Backspace on empty input removes the last attachment chip. — [prompt-input.tsx](https://github.com/vercel/chatbot/blob/main/components/ai-elements/prompt-input.tsx)
- In the full template, the composer only submits when `status === "ready" || status === "error"`; otherwise it toasts "Please wait for the model to finish its response!". — [components/chat/multimodal-input.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/multimodal-input.tsx)
- Suggested actions render only when `messages.length === 0` (empty state), as a horizontally scrolling row on mobile (`overflow-x-auto`, `min-w-[200px]`) and a 2-column grid on ≥sm; tapping a chip sends immediately (no edit step) with staggered 0.06s fade-up entrance. — [components/chat/suggested-actions.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/suggested-actions.tsx); [multimodal-input.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/multimodal-input.tsx)
- Composer autofocuses once on mount (guarded by `hasAutoFocused` ref) and re-focuses the textarea after actions. — [multimodal-input.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/multimodal-input.tsx)
- assistant-ui exposes Composer (input, send, attachments, dictation) and Suggestion ("suggested prompts and quick actions") primitives with `asChild` so the look is fully custom. — [assistant-ui Primitives](https://www.assistant-ui.com/docs/primitives) (Documented, MIT)
- AI Elements lists Attachments, Context, Suggestion, Prompt Input, Queue, Confirmation among chatbot components. — [elements.ai-sdk.dev](https://elements.ai-sdk.dev/)
- Apple HIG: "Consider offering curated suggestions that make it easy to get started" and "Set clear expectations about what your AI-powered feature can and can't do." — [Apple HIG Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
- HAX G16 "Convey the consequences of user actions"; G7 "Support efficient invocation"; G8 "Support efficient dismissal". — [HAX Library](https://www.microsoft.com/en-us/haxtoolkit/library/)

### Inferences
- **Credit-aware send button** (ShenTarot-specific design, not observed anywhere): put the cost on the action, not in a dialog: e.g. small-caps serif label "Ask · 1 credit" on the send control, and "Draw a clarifier · 1 credit" as its sibling. Confirm-dialogs for every 1-credit action would violate HAX G7 (efficient invocation); a one-line balance ("4 credits remain") under the composer satisfies G16. Deduct only after a successful response, and say so on error ("No credit was used").
- **Context chips = drawn cards**: mirror the AI Elements attachment chips above the textarea, but as engraved card-name tags ("The Tower · reversed") with fine 0.5px gold rule, not rounded pills. Make them read-only (the reading is the context) so users understand the follow-up is about *this* spread. Backspace-removes-chip should not apply.
- **Follow-up chips**: unlike the Vercel template (empty-state only), ShenTarot should show 2–3 follow-up chips *after* the reading (e.g. "What does the reversed Tower ask of me?"). Tap should **prefill the composer** rather than send, because sending costs a credit; this deviates intentionally from Vercel's tap-to-send.
- Flutter mapping: `TextField(minLines: 1, maxLines: 6, keyboardType: TextInputType.multiline, textInputAction: TextInputAction.newline)` gives grow-to-cap; on iOS, Return-to-send is uncommon on phones, so keep an explicit send button and don't bind Enter. CJK IME: Flutter's `TextEditingValue.composing` range should be non-empty-checked before any programmatic submit.

### Gaps
- No inspected product discloses per-message credit cost pre-send; no source found for best practice on micro-transaction disclosure in chat. Treat as a design hypothesis to test.
- ChatGPT/Claude mobile composer behaviors (e.g., whether suggestion tap sends or prefills) not verified this session.

---

## Streaming / response patterns (reveal, thinking, stop, error, retry, regenerate, avoiding fake typing)

### Takeaway
Best practice is a single honest waiting row with *specific* status text (not bouncing "typing" dots or a human avatar), followed by text streamed in as it actually arrives; stop is always available during submit/stream; regenerate and feedback sit as quiet text/icon actions after completion.

### Cited Findings
- Vercel template shows a `ThinkingMessage` only while `status === "submitted"` and the last message isn't from the assistant; it renders a sparkle icon plus `WaitingText`, whose text comes from the server stream (`waitingStatus?.message ?? "Waiting..."`) with a shimmer sweep (duration 1s). — [components/chat/message.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/message.tsx); [components/chat/messages.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/messages.tsx)
- An assistant message is "thinking" when `isAssistant && isLoading && !hasAnyContent`, i.e., the placeholder is replaced as soon as the first token arrives. — [message.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/message.tsx)
- Message actions after completion: Copy (toast "Copied to clipboard!"), Upvote/Downvote (persisted via API with `toast.promise`), Edit on user messages; `regenerate` passed to messages. — [components/chat/message-actions.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/message-actions.tsx)
- assistant-ui: ActionBar "copy, reload, edit"; BranchPicker "navigates between alternative responses"; Error primitive "with an alert role". — [assistant-ui Primitives](https://www.assistant-ui.com/docs/primitives)
- Apple HIG: "Factor processing time into your design"; "Consider giving specific, reassuring feedback during generation"; "Specific feedback reduces uncertainty and makes waiting feel purposeful"; example replaces "Processing…" with "Finding substitutions for ingredients." — [Apple HIG Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
- Apple HIG on errors: "Describe what happened in plain language." "Offer a clear next step."; feedback controls listed include Edit, Undo, Retry, thumbs up/down. — [Apple HIG Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
- Flyer Chat ships `flyer_chat_text_stream_message`, "designed to display text content that arrives in chunks over time, often seen in interactions with AI assistants," with fade-in. — [flyer_chat_text_stream_message README](https://github.com/flyerhq/flutter_chat_ui/tree/main/packages/flyer_chat_text_stream_message) (Apache-2.0)

### Inferences
- ShenTarot waiting copy should be specific and ritual-but-honest: "Reading the Tower against your question…" sent from the server per stage, not "The oracle is typing…". This follows Apple's specific-feedback rule and avoids fake human typing.
- Reveal: stream real chunks; fade each new chunk's opacity 0→1 over ~150ms (Flyer style) rather than a per-character typewriter with artificial delay. Under reduced motion, append without fade.
- Stop: during submit/stream, the "Ask" control becomes "Stop" (text label in small caps, square glyph). After stop, keep partial text, mark it "Stopped" in a muted caption, and state the credit outcome (decide policy: charge or refund; be explicit).
- Regenerate on a paid follow-up costs another credit; label it "Ask again · 1 credit" or omit regenerate entirely. A free "Retry" should exist only for failed (error) responses.
- Clarifier card draw: treat as a distinct "event" row in the transcript (card image + name, rule line), not a chat message, followed by its AI interpretation as an assistant section.

### Gaps
- Claude.ai/ChatGPT exact thinking-state copy and animations not inspected this session.
- No source found quantifying user preference for typewriter vs chunk-fade reveal.

---

## Message layout without bubbles (editorial transcript, role labels, timestamps, scroll anchoring, native scroll)

### Takeaway
"Turn anchored to top" (user question pinned at top, answer flowing beneath like an article) is the editorial alternative to bottom-pinned bubble chat, and assistant-ui ships it as a documented default; pair it with native scroll, a releasable stick-to-bottom, and a jump-back control that only appears when the reader has scrolled away.

### Cited Findings
- assistant-ui `ThreadPrimitive.Viewport` prop `turnAnchor: "top" | "bottom"` (default bottom). With `"top"`, "the user's message anchors to the top of the viewport. The question stays at the top and the response streams in below it"; a stable reserve element supplies scroll range while the answer grows; `autoScroll` defaults to false in that mode. Docs call it "useful for a focused reading layout instead of a classic chat scroll", and say this is the default in their Thread component. — [assistant-ui thread.mdx / scroll-anchor.mdx](https://github.com/assistant-ui/assistant-ui/blob/main/apps/docs/content/docs/primitives/thread.mdx) (Inspected, MIT)
- `topAnchorMessageClamp={{ tallerThan: "10em", visibleHeight: "6em" }}` keeps only the bottom of a long user question visible above the answer. — [assistant-ui thread.mdx](https://github.com/assistant-ui/assistant-ui/blob/main/apps/docs/content/docs/primitives/thread.mdx)
- Scroll anchor doc tagline: "Streaming never steals your scroll position"; "a reader who scrolls up interrupts that until they scroll back down"; `ScrollToBottom` is disabled while already at bottom so `disabled:invisible` hides it. — [assistant-ui scroll-anchor.mdx](https://github.com/assistant-ui/assistant-ui/blob/main/apps/docs/content/elements/scroll-anchor.mdx)
- AI Elements `Conversation` wraps `StickToBottom` from `use-stick-to-bottom` with `initial="smooth" resize="smooth" role="log"`; `ConversationScrollButton` renders only when `!isAtBottom`. — [components/ai-elements/conversation.tsx](https://github.com/vercel/chatbot/blob/main/components/ai-elements/conversation.tsx); [use-stick-to-bottom (MIT)](https://github.com/stackblitz-labs/use-stick-to-bottom)
- Vercel template's message list uses native `overflow-y-auto` with `touch-pan-y`, `max-w-4xl` centered column, `gap-5`/`md:gap-7` between turns, and messages carry `data-role` attributes rather than bubble shapes for assistant output. — [components/chat/messages.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/messages.tsx)
- Flyer Chat: "Theme options and builder functions let you change the UI or replace parts with your own implementations." — [flutter_chat_ui README](https://github.com/flyerhq/flutter_chat_ui)
- Inferred / not loaded: Claude.ai renders assistant replies as unboxed prose in a centered column with user turns in a subtle tinted block; Perplexity renders the query as a large heading with a Sources row above an article-style answer. Verify on device before citing.

### Inferences
- ShenTarot layout: each follow-up = a "folio". User question set as an italic serif pull-quote with a hairline rule above and small-caps label "YOUR QUESTION"; the answer below in body serif, labelled "THE READING · AI" in small caps. No bubbles, no avatars. Timestamps only per folio (e.g. "26 Oct, 21:14" in muted caption), not per line.
- Use turn-anchored-to-top behaviour: after sending, scroll the new question to the top; let the answer grow below. On phones this beats bottom-pin because users read from the top of the interpretation, like an article.
- Flutter: use a single `CustomScrollView`/`ListView` (native physics, no custom scroll hijack). Implement top-anchor by computing the question's offset via a `GlobalKey` and `Scrollable.ensureVisible(ctx, alignment: 0.0)` after the frame, plus a bottom `SizedBox` reserve height = viewport − question height so the question can reach the top while the answer is still short. Show a "Latest ↓" text control (not a floating round FAB) only when `ScrollController.position.extentAfter > threshold`.
- If the team wants a ready Flutter base, flutter_chat_ui (Apache-2.0) builders can replace bubbles; but its bubble-centric model and reversed list may fight top-anchoring, so a hand-built `ListView` is likely simpler for a single reading page.

### Gaps
- Did not inspect Perplexity, Claude, Notion AI, Arc/Dia live; their layouts above are unverified.
- Did not verify whether flutter_chat_ui supports top-anchoring.

---

## Honest AI labelling, limits, persona restraint, feedback

### Takeaway
All three guideline sets converge: say plainly that it's AI, state limits up front, avoid a human persona that over-promises, make feedback optional and lightweight, and let people refine/revert. For tarot, "the cards"/"the reading" framing is fine, but the interpreter must be labelled AI.

### Cited Findings
- Apple: "Clearly identify when and where you use AI"; "Never trick someone into thinking they're interacting with or viewing content authored by a human"; "Clearly communicate that AI-generated content may contain errors"; "Make it easy for people to refine or revert generated results"; "Always make providing feedback voluntary". — [Apple HIG Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
- Apple on privacy: "Process as much information locally as possible"; "Always offer a clear way to opt out of its use"; state whether the model uses personal info for training. — [Apple HIG Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
- PAIR Mental Models: make it "extremely clear that the product is not a human"; avoid "presenting the AI as human-like when it can actually do far less than a person"; risk that users "rely on the system more than they should"; the "avoid" example is a running app persona "Allstar," a "personal virtual trainer." — [PAIR Mental Models](https://pair.withgoogle.com/chapter/mental-models/)
- PAIR Explainability + Trust: "Focus on the benefit, not the technology"; in high-stakes cases don't give "what" without "why"; partial explanations of key factors preferred over exhaustive ones. — [PAIR Explainability + Trust](https://pair.withgoogle.com/chapter/explainability-trust/)
- HAX 18 guidelines, incl. G1 "Make clear what the system can do", G2 "Make clear how well the system can do what it can do", G5 "Match relevant social norms", G9 "Support efficient correction", G11 "Make clear why the system did what it did", G15 "Encourage granular feedback", G17 "Provide global controls". — [HAX Library](https://www.microsoft.com/en-us/haxtoolkit/library/); paper by Amershi et al., CHI 2019, received a "CHI 2019 Honorable Mention Award" per Microsoft Research — [MSR publication page](https://www.microsoft.com/en-us/research/publication/guidelines-for-human-ai-interaction/) (the HAX landing page calls it "award-winning"; the specific award is an Honorable Mention, not Best Paper)
- Vercel template implements per-message up/down votes stored server-side. — [message-actions.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/message-actions.tsx)

### Inferences
- Label: small-caps "AI INTERPRETATION" on every AI section; first-run one-liner "Readings are written by AI for reflection, not prediction or advice." (G1/G2 + Apple errors rule). Avoid naming the AI as a mystic persona ("Madame X says…"); PAIR's "Allstar" example is the closest analogue.
- Explain "why" (PAIR): each interpretation should cite which card/position drove it ("Because the Tower sits in Outcome…"), the tarot analogue of Perplexity's sources.
- Feedback: two quiet glyphs ("Resonated" / "Missed") plus "Report" in an overflow; never block or nag (Apple voluntary feedback). G15 granular: allow flagging a specific paragraph via long-press.
- Sensitive topics (health, legal, self-harm) need a scoped response and resources (HAX G10 "Scope services when in doubt").

### Gaps
- Did not load PAIR "Feedback + Control" chapter or Apple's full examples page for thumbs placement.

---

## Journaling-with-AI products (private writing + AI prompts)

### Takeaway
The pattern worth copying is Rosebud's: AI help inside a journal entry is **user-triggered** ("Go deeper"), with a lighter mode that only offers questions. Rosebud's public privacy claims conflict across sources, so ShenTarot should make a stronger, explicit promise: the journal note is never sent to the AI unless the user taps an action that says so.

### Cited Findings
- Rosebud "Go deeper" is chosen by the user while composing; two modes: Interactive (a perspective plus one follow-up question) and Focused (three questions based on the entry so far, "more one-way" without AI feedback). — [Rosebud Help: Dig deeper](https://help.rosebud.app/tools-for-growth/dig-deeper) (Documented)
- Rosebud blog claims entries are encrypted in transit/at rest and never used to train AI models; a third-party copy of a Rosebud privacy policy says anonymised aggregated datasets may be licensed or sold for AI training; I could not confirm which is current. — [Rosebud blog](https://www.rosebud.app/blog/online-journal-rosebud-guide); [Rosebud privacy policy (Jun 2023)](https://help.rosebud.app/about-us/privacy-policy); conflicting: [tostracker copy](https://tostracker.app/document/rosebud-privacy)
- A third-party 2026 review says long-term memory of past entries requires Rosebud's paid tier. — [Macaron review](https://macaron.im/blog/rosebud-ai-journaling-app-review-2026) (secondary source)
- Apple: get permission before using personal data; "Always offer a clear way to opt out." — [Apple HIG Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai)

### Inferences
- ShenTarot journal note: a separate "Notes" section beneath the reading (ruled-paper feel, no AI label), with a persistent caption "Private · not shared with AI". If offered, an explicit action "Reflect on my note with AI · 1 credit" sends it once, and the transcript shows "Your note was included" on that folio (HAX G11, Apple consent).
- Offer free, static (non-AI) reflection prompts derived from the cards ("What in your life feels like the Tower right now?"), like Rosebud's Focused mode but generated locally from card metadata, so writing never needs the model.

### Gaps
- Day One prompts, Reflectly, Stoic not researched within the tool budget; no verified claims about them.
- Rosebud's current privacy terms unresolved (conflict noted above).

---

## Accessibility (live regions, focus after send, reduced motion)

### Takeaway
Use a log container plus polite announcements for status changes, not for every streamed token; keep focus on the composer after sending; gate shimmer/fade on reduced-motion settings.

### Cited Findings
- AI Elements `Conversation` sets `role="log"` on the scroll container. — [conversation.tsx](https://github.com/vercel/chatbot/blob/main/components/ai-elements/conversation.tsx)
- Vercel `SubmitButton` uses a visually hidden `<output aria-live="polite">` that reads "Loading" vs "Submit form"; scroll button has `aria-label="Scroll to bottom"`; submit toggles `aria-label` "Stop"/"Submit". — [submit-button.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/submit-button.tsx); [messages.tsx](https://github.com/vercel/chatbot/blob/main/components/chat/messages.tsx); [prompt-input.tsx](https://github.com/vercel/chatbot/blob/main/components/ai-elements/prompt-input.tsx)
- assistant-ui Error primitive uses an alert role. — [assistant-ui Primitives](https://www.assistant-ui.com/docs/primitives)
- LibreChat source contains `aria-live` usage (GitHub code search hit; not inspected in detail). — [LibreChat repo](https://github.com/danny-avila/LibreChat)
- Flutter `SemanticsProperties.liveRegion`: "A live region indicates that updates to semantics node are important"; on Android and iOS it "causes a polite announcement to be generated automatically" even without focus, but may not be spoken if the OS is already announcing something. — [Flutter API: liveRegion](https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html)
- GitHub code search found no `liveRegion` or `disableAnimations` usage in flutter_chat_ui (search, not exhaustive review). — [flyerhq/flutter_chat_ui](https://github.com/flyerhq/flutter_chat_ui)

### Inferences
- Do not wrap the streaming answer in a live region (it would re-announce on each chunk). Instead: announce "Interpreting…" on submit, and "Interpretation ready, 3 paragraphs" on completion via a `Semantics(liveRegion: true)` status line or `SemanticsService.announce` (API not loaded this session; verify).
- Focus: keep focus in the composer after send (Vercel pattern) so VoiceOver users can stop; on completion, don't steal focus; offer the "Latest" control as a semantics button.
- Reduced motion: check `MediaQuery.of(context).disableAnimations` (Flutter API not loaded this session) to replace shimmer with static italic "Interpreting…" and remove chunk fades.
- Touch targets ≥44pt for Ask/Stop/Clarifier even if visually rendered as fine-line text buttons.

### Gaps
- Flutter `SemanticsService.announce` and `MediaQuery.disableAnimations` docs not loaded this session.
- No source found testing screen-reader behaviour with streamed LLM text specifically.

---

## Code snippets and Flutter mapping

### Takeaway
Three patterns port cleanly: status-driven action button, top-anchored turn scroll, and honest status line. Snippets below are short; React excerpts are from Apache-2.0 / MIT sources.

### Cited Findings
- React (Apache-2.0, vercel/chatbot `prompt-input.tsx`), status → icon/behaviour:
  ```tsx
  const isGenerating = status === "submitted" || status === "streaming";
  let Icon = <CornerDownLeftIcon className="size-4" />;
  if (status === "submitted") Icon = <Spinner />;
  else if (status === "streaming") Icon = <SquareIcon className="size-4" />;
  else if (status === "error") Icon = <XIcon className="size-4" />;
  // aria-label={isGenerating ? "Stop" : "Submit"}
  ```
  — [prompt-input.tsx](https://github.com/vercel/chatbot/blob/main/components/ai-elements/prompt-input.tsx)
- React (MIT, assistant-ui) top anchor: `<ThreadPrimitive.Viewport turnAnchor="top" topAnchorMessageClamp={{ tallerThan: "10em", visibleHeight: "6em" }}>` — [assistant-ui thread.mdx](https://github.com/assistant-ui/assistant-ui/blob/main/apps/docs/content/docs/primitives/thread.mdx)

### Inferences
Flutter sketches (written for ShenTarot, untested):

```dart
enum AskStatus { idle, submitted, streaming, error }

// 1. Status-driven action: cost shown on the control, Stop while generating.
Widget askButton(AskStatus s, {required VoidCallback onAsk, required VoidCallback onStop}) {
  final generating = s == AskStatus.submitted || s == AskStatus.streaming;
  return Semantics(
    button: true,
    label: generating ? 'Stop' : 'Ask, costs 1 credit',
    child: TextButton(                       // fine-line, no pill/fill
      onPressed: generating ? onStop : onAsk,
      style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
      child: Text(generating ? 'STOP' : 'ASK · 1 CREDIT'),
    ),
  );
}

// 2. Honest status line, announced politely; static under reduced motion.
Widget statusLine(BuildContext c, String? text) => Semantics(
  liveRegion: true,
  child: text == null ? const SizedBox.shrink() : Text(text, // e.g. 'Reading the Tower against your question…'
      style: Theme.of(c).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
);

// 3. Top-anchor a new question after send (native ListView, no custom physics).
void anchorQuestion(GlobalKey questionKey) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = questionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, alignment: 0.0,
          duration: MediaQuery.of(ctx).disableAnimations ? Duration.zero : const Duration(milliseconds: 300));
    }
  });
}
// Add a trailing SizedBox(height: viewportHeight - questionHeight) reserve while streaming
// so the question can reach the top even when the answer is short (assistant-ui "reserve" idea).
```

Mapping summary:
- `field-sizing-content max-h-48` → `TextField(minLines: 1, maxLines: 6)`.
- `role="log"` + polite status → `Semantics(liveRegion: true)` on a status line only.
- `use-stick-to-bottom` / `ScrollToBottom` disabled at bottom → `ScrollController` listener on `position.extentAfter`; show "Latest ↓" text button only when > ~80px.
- Shimmer thinking → static italic text when `disableAnimations`; otherwise a slow opacity pulse in gold at low contrast (no sparkle avatar).
- Suggestion chips → `Wrap` of outlined, square-cornered `TextButton`s with 0.5px gold `BorderSide`; tap prefills `TextEditingController`, doesn't send.

### Gaps
- Flutter snippets are untested sketches; `Scrollable.ensureVisible` with a growing reserve needs device testing for jank during streaming.
- Did not benchmark flutter_chat_ui vs hand-built list.
