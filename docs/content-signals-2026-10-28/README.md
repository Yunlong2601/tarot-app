# Content Signals release — 2026-10-28 (Singapore)

Declared `ai-train=no, search=yes, ai-input=no` in all 12 named crawler groups and the wildcard group, following the supplied Content Signals skill. Existing Allow and sitemap directives remain.

Production base: `472d72f51717dc05b36d2e0333c0e993fd2f21eb`. Built an isolated archive of that exact live revision plus the robots route change, preserving the existing release manifest. Cloudflare reported exactly one new or modified static asset: `/robots.txt`. Worker code and bindings match that release; unrelated dirty local work was excluded.

Deployed version `1ec015cb-4599-42cd-942c-47cfcf9f9d45` at 100%. Previous version for rollback: `7c249e8b-539f-402a-9cb3-b78bf5c5fde1`.

Live GET https://shentarot.com/robots.txt returned all thirteen directives. POST https://isitagentready.com/api/scan with `{"url":"https://shentarot.com"}` returned `checks.botAccessControl.contentSignals.status = "pass"` and thirteen parsed signals, each with all three requested preferences. See saved response and live text.

These directives express preferences; crawler compliance was not established.
