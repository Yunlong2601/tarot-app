# ShenTarot interaction study: recruitment and moderator pack

Prepared 23 October 2026. Five sessions are planned; **none have been recruited or conducted**. The owner selected “Prepare the study pack” instead of supplying participants. This file is a ready-to-use protocol, not evidence of consumer validation.

## Recruit five learners

Recruit adults who own or have tried a tarot deck and are learning to connect cards in a spread. Aim for a mix of new learners and occasional readers, at least three primarily using phones, and varied comfort with technology. Ask about access needs; offer keyboard or assistive-technology participation without making someone disclose a diagnosis. Avoid recruiting only close collaborators. Each session takes about 25 minutes. Do not promise payment unless a budget has been approved.

Invitation draft (send only through a channel the owner chooses):

> I’m looking for five adults learning tarot to try ShenTarot’s redesigned card search and reading workspace. This is a 25-minute usability session about the website, not a tarot reading. You’ll use a fictional question, choose cards, and save a sample reflection. Participation is optional; you can stop or skip any task. Please reply if you’re interested and tell me whether you prefer phone or computer. Recording is optional and requires separate consent.

Screening questions: Have you tried tarot? How often do you read? Which device/browser would you use? What is your preferred language? Is there anything we should arrange so the session works for you? Collect only contact information needed to schedule, separately from anonymous notes.

## Consent script

Explain that we are evaluating the interface, not the person or their interpretation. Use the fictional creative-project question below. No need to share personal concerns. Ask permission to take anonymous task notes. Ask separately before recording; declining recording must not prevent participation. They may skip tasks, stop, or ask for their notes to be removed. State a concrete deletion date agreed by the owner before collecting recordings/contact details. Do not begin if this consent is unclear.

## Setup and tasks

Use the same reviewed preview revision for all sessions. Record build/commit, language, device, browser, viewport, keyboard/assistive technology, and connection conditions. Reset only the dedicated study profile between participants. Keep the real production saved reflection untouched.

Say: “Please think aloud. I may remain quiet while you try; that helps us see what the website explains on its own.” Avoid showing the participant the planned route.

1. **Discover.** From the homepage, find the meaning of Queen of Cups reversed. Observe how search is discovered, whether reversed intent is noticed, and whether the meaning feels identifiable.
2. **Choose.** Use that card in a three-card spread. Add The Magician and Eight of Pentacles. Enter “How can I make room for a creative project?” Observe position/orientation understanding and duplicate-card feedback.
3. **Correct.** Move the first card later, change one orientation, then consider a one-card spread and cancel the change. Observe whether the guard is understood and whether cards/notes are retained.
4. **Connect.** Explore the homepage example’s Positions and Connection steps, then the workspace’s relationship prompts. Ask which cards each connection refers to and what is authored example versus reference guidance.
5. **Reflect and save.** Write “I will practise one small skill this week.” Save, change the text, restore the saved reflection, then export. Ask where the participant thinks the reading is stored and what would happen on another device.
6. **Optional concept.** Open the companion preview, try one follow-up and a stopped-response fixture. Ask whether it is live AI, whether any charge occurred, and what “charge status unknown” suggests should happen next. Correct misconceptions after recording them.

For each task record: unassisted / completed with help / not completed; elapsed time; misclicks/backtracks; exact confusion quote if consented; severity; and the moderator’s intervention. Ask a 1–5 ease question after the task. Stop timing before discussion. Do not infer comprehension solely from a click path.

## Debrief

Ask: What felt clear? What felt slow or distracting? Which control was hardest to find? Could you explain the spread in your own words? Where is your reflection saved? What would you change first? Ask about motion comfort without suggesting that animation is necessarily a problem.

## Analysis and follow-up

Use `interaction-study-results-template.csv`. Participant IDs P01–P05 are placeholders, not recruited people. Summarize repeated confusion separately from isolated observations. Five formative sessions cannot establish conversion lift, statistical significance, general accessibility conformance, or population preference. Preserve raw observations; distinguish observed behavior, participant opinion, and design inference. Prioritize data loss or blocked completion, then misunderstanding, then visual polish. Record the proposed fix and retest the affected task after changes.

## Device and accessibility review checklist

- At 320, 390 and 768 CSS px, enter text with a real mobile on-screen keyboard; confirm the query, result, close and submission controls remain reachable, and that closing the keyboard preserves the query.
- Zoom to 200% and test reading and modal focus; at high magnification check reflow and focus visibility.
- Keyboard-only: open navigation/search/picker, type, use arrows/Enter, reverse/move cards, save/restore, Escape, and inspect focus restoration.
- VoiceOver or another screen reader: verify labels, listbox active option, disabled duplicate reason, orientation, saved-state announcements, dialog name, and connection controls. Automated scans do not replace this review.
- Enable OS reduced motion, then the visible motion control. Verify every action remains available with no spatial motion.

Record actual device/browser/screen-reader versions and observations. These manual checks remain outstanding until conducted; do not fill this section with simulated results.
