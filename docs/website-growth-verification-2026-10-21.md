# Competitor-gap website enhancement verification

Implementation began 21 October and final release preparation continued 22 October 2026, Singapore. This records the tested implementation before release; the PR release receipt records the final merge/deployment IDs and production checks.

## Scope and requirements

- Website value: homepage utility first; existing art/search/spreads/workspace/tools preserved. Upcoming app clearly labelled. Homepage visible FAQ and FAQ structured data use the same website-specific answers; unavailable app removed from homepage MobileApplication schema.
- Differentiation: `/learn/connected-reading` shows three shared card IDs with pictures, upright/reversed labels, shared position names, original symbol annotations, a connection, alternative and changed-position example. It is explicitly an editorial demonstration. Workspace loading asks before replacing an existing draw, preserves notes and saved snapshot, and consumes its seed parameter once.
- Trust: `/methodology` and About disclose Rider–Waite–Smith, shared app reference text, AI assistance, unconfirmed expert/native review, privacy and interpretive limits. Linked from card/context, Learn and footer pages. No testimonials, performance claims or invented reviewers.
- Acquisition: three existing card pages gained original applied annotations; existing context pages gained upright/reversed workspace links; existing spread and lesson pages link into teaching. New beginner guide has accessible HTML, eight UTF-8 text downloads and browser print/PDF. Crawl/distribution/service audit and original demo scripts are in `website-growth-validation-2026-10-21.md`.
- Repeat use: five activities with browser-local progress, reset and visible failure messages; existing single reflection gets a revisit prompt. The app's Premium journal/look-back boundary is preserved; no multi-entry history, sync, email or notifications were added.
- All eight locales have new `growth.json` content, with no new package. Native review remains unperformed. Shared card and spread data remain authoritative. No app/backend edits, pricing/credit changes, analytics or cookies. The English privacy page now also describes the local workspace/practice records, deletion and export.

## Automated evidence

Commands from `web/`:

```sh
npm test
npm run check:i18n
npm run check
npm run build
npm run check:reader-build
```

- Eight tests passed: original state/search/storage coverage plus example preservation/fixture isolation, practice recovery/validation/reset independence, and denied/quota propagation. Faults are injected at the storage boundary and are not claimed as actual browser quota simulation.
- Translation keys, arrays and placeholders match for all eight languages.
- Astro check: zero errors, zero warnings, two inherited birth-card hints. These hints were present before the website work.
- Production build: 3,901 pages; four substantive new HTML routes in eight languages, plus eight text resources. No new card/context combinatorial pages.
- 136 production pages checked across all eight locales: internal links/assets, canonical/hreflang and new sitemap entries. Additional checks verify homepage FAQ/schema consistency, absence of premature homepage app schema, and eight substantive text downloads.
- `git diff --check` passes. Diff against the integration baseline leaves app/backend untouched. No new dependencies.

## Actual browser journeys

Production output served locally at port 4330. All entered questions/reflections were synthetic test data.

1. Homepage “Queen of Cups reversed” → one result → reversed meaning → correct reversed card seeded in workspace.
2. Three-card manual entry, replacement, reversal and moving earlier worked. Selected IDs/orientations were inspected, not inferred from a successful build.
3. Saved fictional reflection; loaded the editorial example twice: cancelling kept the draw and accepting changed only the confirmed cards/spread while keeping the question/notes. Replacing an example card worked. Restoring recovered the independent saved snapshot.
4. Saved reflection survived refresh and closing/reopening the tab; explicit restore recovered the expected text. Copy yielded readable question/positions/orientations; export downloaded a UTF-8 text file. Browser print pipeline generated `reflection-print.pdf`. Delete → reload → Restore showed no valid saved record.
5. Question → Tab focused first impression with a visible solid outline; Skip focused card picker zero.
6. Practice links opened the existing reversals lesson and combinations tool. Two selected cards produced meaning panels and relationship guidance. All five activity checkboxes were marked to verify state (not to claim human comprehension); 5/5 survived refresh and a new tab. Reset returned to zero. French progress persisted across reload.
7. Guide download initially stalled through a static link in the browser shell, despite HTTP 200. The final Blob download path succeeded and the downloaded text was read. The static href remains for no-JS access. Print inspection initially exposed faint inherited colors; print-specific black text/white diagram styling fixed it, and a new PDF was produced.
8. Methodology rendered the explicit unconfirmed review and unavailable-AI statements. No falsely working AI submit flow exists.
9. 390px English example: three images loaded and no horizontal document overflow. 320px French practice and Japanese guide: no horizontal overflow; long text remained readable. Temporary viewport and print overrides were reset.
10. Existing daily draw/reveal and birth-card calculator were exercised; combinations returned valid content. No browser console errors were reported during these checks.

## Artifacts

`docs/verification/website-growth-2026-10-21/` contains desktop homepage/example/guide/practice captures, mobile example/French-practice/Japanese-guide captures, and browser-generated example print PDFs. PDFs and screenshots use synthetic data. They are evidence of browser rendering, not physical-device or paper-print validation.

## Remaining dependencies and limits

Website AI remains intentionally unavailable pending browser identity/session, supported routing and existing credit/access preflight; exact handoff is in the prior website verification document. No test tokens or provider credentials were placed in browser content.

No native-speaker review, independent tarot expert review, human comprehension/usability study, physical phone, physical printing or screen-reader assessment was conducted. No private traffic/Search Console data was available, so no acquisition or retention outcome is claimed. The prepared 5–8-participant protocol still needs consenting participants. Newsletter requires an approved working subscription/consent/delivery service; no fake form was added.

The owner subsequently authorised merge and live deployment on 22 October. The implementation snapshot above predates that release. Consult PR #23's release receipt and the live URLs for the final published state.
