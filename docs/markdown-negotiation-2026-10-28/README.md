# Markdown content negotiation — 2026-10-28

Implemented the supplied https://isitagentready.com/.well-known/agent-skills/markdown-negotiation/SKILL.md requirements without enabling a paid plan. The live Cloudflare dashboard showed Markdown for Agents disabled and Pro-only. The site implements the behavior itself with build-generated Markdown and Worker Accept negotiation.

## Release

Exact production source base: `472d72f51717dc05b36d2e0333c0e993fd2f21eb`, with the already-released robots Content Signals fix retained. Added 3,900 Markdown counterparts and the new Worker; unrelated dirty website work excluded. Deployed Worker version `b261e456-30fd-4641-a306-8f56f1eb913a` at 100%. Rollback: `1ec015cb-4599-42cd-942c-47cfcf9f9d45`.

Future builds run the generator after the existing provenance script. Build-only dependencies are Turndown and LinkeDOM. No runtime AI inference or paid conversion service. Worker now runs before static asset handling for negotiation.

## Verified

- 35 site tests pass, including four targeted conversion/negotiation/runtime routing tests.
- All 3,900 built HTML pages (excluding 404) have nonempty Markdown counterparts.
- Local Wrangler HTTP checks return Markdown and HTML as requested, including Chinese directory routes.
- Live Markdown checks pass for `/`, `/zh-hans/cards`, `/read`, `/privacy`, `/cards/major-19-sun`.
- Browser/default response bodies are SHA-256 identical before/after for `/`, `/zh-hans/cards`, `/read`, `/privacy`, `/robots.txt`, `/release.json`.
- Converted responses use `text/markdown; charset=utf-8`, `Vary: Accept` and the existing Content Signals policy; HTML validators/encoding headers are removed on conversion. Private shared readings bypass negotiation.
- External POST scan returned `checks.contentAccessibility.markdownNegotiation.status = "pass"`, HTTP 200 and text/markdown. Saved evidence accompanies this report.

## Limits

Markdown represents public build-time page content, not a user's interactive reading state or a private shared reading. An exact token count is not available, so the optional x-markdown-tokens header is omitted. No physical-device UI test was needed for this HTTP-only change; default browser bodies were verified byte-for-byte. Existing npm audit findings concern Wrangler/Miniflare/undici/fast-uri tooling, not the added conversion dependencies.
