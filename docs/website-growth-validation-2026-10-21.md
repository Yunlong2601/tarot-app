# Website growth and consumer validation

Date: 21 October 2026 (Singapore). Implementation is on the website feature branch, not production. These are experiments and editorial improvements, not evidence of traffic growth.

## Current-state audit

The original checkout remains on `backup/mac-local-2026-10-21`; its uncommitted research and PROGRESS edits were preserved. Work continues in the existing isolated `shentarot-web-enhancements` worktree and PR #23. That PR targets `main` per AGENTS.md, but inherits the integration branch's app/backend history. Review the website-specific delta against `fda3810`, or this follow-up against `de78f04`; neither website phase edits app or backend.

| Area | Live site observed | Website feature branch |
|---|---|---|
| Homepage | “Ask the cards anything”, app-led claims, both stores “Coming soon” | Website-led card search, spread choice, physical-card workspace and editorial example |
| AI and scanning | Marketing describes app features; this audit does not establish their production availability | Explicit unavailable website AI, no scan or sign-in controls; no credentials or AI requests |
| Trust | Company contact; basic source description | Methodology, AI-assisted text disclosure and explicit unconfirmed expert/native review |
| Learning | Existing lessons and card/context pages | Existing content reused, annotated example, pocket guide and five activities with local progress |
| Reflection | No verified account journey in this audit | One browser-local snapshot and session draft; restore/copy/export/print/delete |
| Crawling | Homepage HTTP 200; robots allows all; sitemap HTTP 200 | Existing routes retained; 32 new HTML pages (four editorial routes × eight locales), plus eight text downloads |

Live public requests were read-only. Production was not changed. Successful HTTP responses and crawl permissions do not prove indexing, ranking, demand or conversion. External Cloudflare bot rules cannot be inferred from a robots file and were not changed.

## Existing content audit and focused acquisition set

The site already has 78 meanings with imagery, upright/reversed text and FAQs; context pages for love/career/feelings/yes-no; shared spreads with diagrams and draw tools; beginner lessons; combination tools; and zodiac pages. A new generic card library would duplicate this investment. We selected a small teaching cluster instead:

| Existing page | Consumer question | Improvement and next task |
|---|---|---|
| `/cards/major-17-star` | How might hope apply in a difficult position? | Original water/stars annotation; challenge-position question; connected-example link |
| `/cards/pentacles-two` | Does a reversed Two mean something bad? | Rhythm/overload annotation; explicit uncertainty; reversed example |
| `/cards/pentacles-eight` | Practice or perfectionism? | Original repeated-coins annotation; position contrast; example and workspace |
| `/spreads/three-decision` and `/spreads/three` | How do three meanings become a reading? | Existing diagrams and examples retained; link to full connected example |
| `/learn/reversed-cards` and `/learn/how-to-read-tarot` | How do I practise without memorising everything? | Existing lesson content retained; direct links to the example, practice sequence and methodology |
| Existing context pages | How do I use this meaning in my actual draw? | Upright and reversed carry-through links to the manual workspace |

Each reference page keeps its existing direct answer, artwork and metadata. New teaching material is original and deliberately expresses alternatives. The large existing page count is not evidence of SEO quality. Improve this small cluster with observed tester feedback before creating more search pages.

## Premium and technical boundaries

`AGENTS.md`, `app/lib/data/models.dart` and the history implementation identify journal notes and look-back as Premium. We therefore did not build a multi-entry free website journal or change app entitlements. The existing one-snapshot reference tool now has a revisit prompt and a path back to practice. It asks users to export the earlier version before replacing a snapshot. The practice checklist stores only five activity IDs, separately from card and reflection data. It is not a reading history, certification, account or sync service.

Website AI still needs the secure browser identity/session, access/credit preflight and supported routing described in `website-enhancements-verification-2026-10-21.md`. The app's testing install-token route must not be used as browser authentication. No backend coordination was necessary for the independent reference/editorial work; the handoff identifies what an assigned backend owner must supply before enabling AI.

No approved newsletter subscription service or consent/unsubscribe workflow was found in this website implementation. No form was added. Before a newsletter launches, the owner must select an authorised provider, approve privacy/consent and deletion/unsubscribe handling, assign a publishing owner, and verify actual delivery. No messages, outreach, subscriptions or external settings were changed.

## Measurement proposal — not installed

No Search Console or analytics connector was exposed among available tools, and no private dashboard data was accessed. Do not infer that the owner has no account; only that this session has no authorised reporting capability. No traffic numbers, attribution, bounce rate, rankings, conversions or retention were invented. No new tracking/cookies were added.

Reports needed from the owner or an authorised reporting connection:

1. Search Console Performance for the last 90 days, compared with the prior 90: date, query, landing page, country, device, impressions, clicks, CTR and position; separate branded/non-branded queries. Document aggregation and privacy-filtering limits.
2. Page indexing and sitemap status; URL Inspection for the homepage and the focused teaching cluster. A robots allowance does not establish indexing.
3. Existing aggregate traffic reports by landing page and referrer/source, with bots excluded where supported; date range, definitions and known gaps. Do not introduce personal tracking simply to obtain these.
4. If already lawfully available, aggregate tool completion and return cohorts. Currently these events are not installed, so funnel/retention rates are unknown.

Proposed future events after a privacy review, consent assessment and owner approval of the actual collection design:

| Stage | Event | Trigger | Minimal properties | Metric denominator |
|---|---|---|---|---|
| Acquisition | landing_view | A reference or landing page becomes visible | route category, locale, coarse source category | Bot-filtered visits under the chosen reporting definition |
| Activation | lookup_result_open | Open a meaning from card search | locale, source category | Search sessions; never send the search text |
| Activation | workspace_start | First manual card assignment | locale, example/manual origin | Reference visits or workspace visitors, reported separately |
| Activation | spread_ready | Every required position has a valid unique card | locale, card-count bucket | Workspace starts; suppress repeated renders |
| Activation | reference_used | A complete spread and its reference section are viewed | locale, card-count bucket | Valid spread completions |
| Retention proxy | reflection_saved / exported | Successful local save or export action | locale, action type | Reference users; an action is not proof of later use |
| Retention | meaningful_return | Another lookup, practice or reading on a later visit | coarse cohort, activity category | Eligible first-use cohort with a full seven-day observation window |

Never collect question text, card selections, names, exact birth data, journal content, images, email addresses or full query-string URLs in these events. Seven-day user retention cannot be measured honestly without a justified, privacy-compatible way to recognise a returning participant; a revisit count is not the same metric. Prefer a consenting research panel until that design is approved. Report counts, denominators, time windows and acquisition sources; do not manufacture percentage uplift from a tiny sample.

## Small distribution plan — prepared, not sent

Start with English and one language the owner can review, despite retaining all eight supported interfaces. Allocate effort to quality and feedback rather than unattended mass posting.

1. Publish only after code/content review and a separately authorised deployment. Verify the example, reference guide and target cluster at production URLs.
2. Record a short screen demonstration using the editorial fixture, never a user's private question. Link directly to `/learn/connected-reading`.
3. Prepare an image showing the three cards, position labels and one connection. Use public-domain artwork and original captions. Link to the guide or example, not a generic store CTA.
4. The owner may later share a useful answer where community rules permit, disclose the project relationship and ask for feedback. No unsolicited messages, fake independent reviews or automatic posting.
5. Review source-specific aggregate visits and observed usability. If people arrive but cannot explain the connection, improve the teaching before buying traffic.

### Original demo scripts

**30-second physical-deck demo:** “Already pulled your cards? Keep that draw. Here is a creative-project question with three positions. The Magician suggests resources; the reversed Two of Pentacles invites a look at competing demands. The Eight of Pentacles could connect them through a small regular practice. That is one reading, not a prediction. Open the example, replace the cards with yours and write what you notice.”

**20-second reversal lesson:** “Reversed does not automatically mean bad. The Two of Pentacles might point to an overloaded rhythm, or a need for flexibility. Its position matters. Compare the picture, question and neighboring cards before deciding what fits.”

**20-second portable reflection:** “Write your own interpretation before asking anyone else. Keep a copy with your question, positions and card orientations. ShenTarot can export text or print a reading; browser storage is not account sync. Return later and compare what changed.”

## Usability and consent script — not yet conducted

Recruit 5–8 consenting adult hobbyists with varied experience, including AI-open and AI-sceptical participants. Do not send invitations automatically. Explain that the product is being tested, participation is voluntary and stopping carries no penalty. Use a supplied fictional question; participants need not reveal private beliefs or life events. Ask permission separately for screen/audio recording and quotes; collect only necessary contact details outside the website. Agree deletion dates and access before recording. Publish no quote or identifying detail without explicit permission.

Moderator introduction: “Please try these tasks as you normally would. Think aloud if comfortable. We are testing the website, not your tarot ability. There is no correct personal interpretation. I will avoid helping unless you are stuck.”

Tasks, without coaching the clicks:

1. From the homepage, find the Queen of Cups reversed. Explain what is available on the website versus the app.
2. Carry that card to a spread. Enter and correct a supplied three-card draw, including one reversal and a reordered card.
3. Read the editorial example. Explain one relationship between cards in your own words, then give an alternative. Ask what changes if Eight of Pentacles is the challenge.
4. Load the example while other cards and notes exist. Predict what will change. Cancel once, then accept. Check that personal notes and saved snapshot remain recoverable.
5. Save a fictional reflection; close/reopen, restore it and export a copy. Explain where it lives and what clearing browser data would do.
6. Use the pocket guide and practice checklist. Return after another task and explain the progress indicator. Try a phone-sized viewport if comfortable.
7. Find methodology. Ask who reviewed the content and whether the website sends a reading to AI. Check for misunderstandings rather than giving a sales explanation.

Record completion without help, time to find the first meaning, correction errors, hesitation, misunderstanding of storage/AI, ability to explain a connection and preference. Ask “What would you use instead?” and “What would make you return?” Avoid leading questions about liking AI. Initial targets (not research-proven guarantees): at least 4 of the first 5 complete the main tasks unaided; lookup under 30 seconds; manual entry under two minutes. Failures guide the next iteration, not a judgement of participants.

Do not claim improved comprehension until this is conducted. A later fair competitor comparison should counterbalance order with identical fictional cards/question, record effort and usefulness, and avoid claiming superiority from marketing descriptions.

## Updated release authorisation

On 22 October 2026 (Singapore), the owner explicitly asked to publish the completed site live, then explicitly authorised merging and completing the release. This supersedes the original “do not merge/deploy” instruction for this website task. Finish verification, merge the reviewed feature PR with passing checks, deploy only the `shentarot-site` Worker/static assets, and verify production. Do not deploy app/backend or enable unsupported AI. The original pre-release live observations above remain a historical baseline, not the post-release state.
