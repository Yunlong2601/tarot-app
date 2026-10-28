# Website beta onboarding — 27 October 2026

**Invitation follow-up:** owner supplied `https://testflight.apple.com/join/rwDXXVU1`. Opened the exact public URL on 27 October; Apple displayed “This beta isn't accepting any new testers right now.” Configured that link and separated invitation presence from availability with `TESTFLIGHT_ACCEPTING_TESTERS = false`. The iPhone button now opens the supplied invitation with the checked-date/closed-enrolment message and email fallback. Do not claim the link is accepting testers or external review is approved merely because it exists. Website remains local, not deployed.

## Working local website

- `/beta`: separate Android and iPhone paths, account/opt-in/install instructions, troubleshooting, email help and feedback, native anchor navigation and no credential-collection form.
- Desktop header, enhanced mobile menu and no-JavaScript menu link to it. The homepage companion section and shared companion CTA also link to it in all eight site locales.
- This first joining guide is English-only. Other-language links explicitly mark English; `/beta` does not advertise nonexistent translated routes. Existing site localisation is retained.
- Beta destinations are separate from the empty production download URLs. Public-release store badges remain Coming soon. No claim that website AI is now available.
- Config: `web/src/lib/beta.ts`. `TESTFLIGHT_INVITE` contains the owner-provided public URL; `TESTFLIGHT_ACCEPTING_TESTERS` stays false until public enrolment is verified. The invitation button remains usable with the availability warning and email fallback.

## Verified through the owner's Chrome session

### Android

Google Play Console: Closed testing – Alpha, **Active**, latest release **1.0.1 (10) closed test**, 178 countries/regions. Eligibility group: `shentarot-testers@googlegroups.com`.

1. [Tester group](https://groups.google.com/g/shentarot-testers): settings allow anyone on the web to see and join it. No group permission changed; owner was already a member.
2. [Web opt-in](https://play.google.com/apps/testing/com.shentech.shentarot): rendered ShenTarot, ShenTech, testing explanation and Become a tester. Did not enrol the owner's account merely to test the button.
3. [Store destination](https://play.google.com/store/apps/details?id=com.shentech.shentarot): exact Android link copied from the console's displayed link label; installation requires prior eligibility/opt-in and a compatible device/region. No physical installation performed.

The same Google account is required through the group, opt-in and Play Store. Website buttons preserve this sequence and keep the guide open in the original tab.

### iPhone — not externally available yet

App Store Connect initially had only internal groups Beta and Owner. Latest build **15 / 1.0.1** was **Ready to Submit**, expiring in 90 days in the observed UI. There was no approved external group/public link to reuse.

Created the external **Website Beta** group, ID `d91369ef-ecee-4291-a677-c78c462cb7a4`. Selected build 15 in Add Builds → Next. Apple's required Test Information form was empty; prepared an original beta description and public business feedback/contact email/name. **Contact phone and sign-in review instructions remain for the owner.** No invented phone number or demo credentials were entered. No beta review submission or external build approval is claimed. Group was created; adding build 15 is not complete while the required form remains unfinished.

The owner was asked to complete those fields in the open Chrome form, without sending credentials in chat. Preserve that handoff. After required information is complete: verify it with the owner’s app/review instructions, finish the build's review flow, wait for Apple's external approval, enable a public link with a deliberate tester limit, inspect its public landing page, then populate `TESTFLIGHT_INVITE` and rebuild. Do not expose an empty/unapproved invitation as working installation.

## Validation and limits

- Astro check: 122 files, zero errors/warnings, two existing birth-card hints. Production build: 3,911 pages.
- Existing 26 tests, eight-locale checks, reader/ritual/interaction/search-growth audits pass.
- `npm run check:beta-build` verifies actual Android destinations and order, iOS pending/ready URL gate, absence of credential forms in beta content, English metadata, sitemap entry and eight-locale header/companion links.
- [Responsive data](./runtime.json): 1280/1024/901/390/320px, no document horizontal overflow; both phone paths retain their content. [Desktop screenshot](./beta-desktop.png), [compact iPhone path](./beta-phone.png).
- Native scrolling/anchor links and ordinary external links; no new tracking or library dependency. Website language fallbacks remain unchanged. Not a screen-reader conformance audit, fresh-account enrolment or native installation test.

## Release boundary

Website changes are **local only**, not deployed. The earlier search-growth task explicitly excluded deployment and this branch also contains substantial unreleased interaction work; do not publish that whole branch as a side effect of beta onboarding. Prepare/review a focused release separately. Android enrolment destination is verified; iPhone installation remains blocked by required review information and Apple's external review. Do not report both platforms as publicly installable.

Reference workflow: [Google closed testing](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en), [Apple external testers](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers), and the [TestFlight orchestration skill](/Users/syl/.codex/skills/asc-testflight-orchestration/SKILL.md) used to guide the browser setup. No tester invitations, email messages, purchases or production release were sent.
