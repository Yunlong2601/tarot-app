# Bing indexing audit — 28 October 2026 (Singapore)

Five live routes checked: `/`, `/read`, `/cards`, `/tools/random-card`, `/learn/how-to-read-tarot`.

All five Bing Index inspections report **Discovered but not crawled**. Homepage/cards/random tool discovered October 18; workspace/guide October 22. Homepage live test passed in this session: URL can be indexed. This does not guarantee inclusion or establish why Bing has not crawled these URLs.

All five browser DOM checks show a self-referencing canonical, unique descriptive title/description, one H1, substantive main content and internal links. No robots meta exclusion was found. Raw observations in JSON. These are rendered DOM checks, not an exhaustive initial-response or duplicate-content audit.

Bing sitemap: success, roughly 3,900 URLs discovered, last crawl October 25. IndexNow shows 25,400 submissions (not unique URLs); latest listed submissions already include all five routes. No additional bulk submissions made.

Homepage warning clarified: all nine flagged images have an alt attribute, with empty values. Two hero illustrations are decorative; the card-back link has an accessible label; six gallery links have visible card names. Empty alt avoids redundant naming; no blanket replacement performed. Library card illustrations similarly accompany visible names. No confirmed SEO blocker was found and no production code/security/canonical changes made.

Yandex setup opened in Chrome at the add-site sign-in flow. Authentication and ownership verification remain incomplete. The visible sign-in page was brought to the front for the owner; no site verified, credential created, terms accepted or new account permissions granted by this audit.

Next: finish Yandex login and site ownership verification, submit existing sitemap there; inspect representative language/card pages and acquisition/content quality if Bing remains stalled. Current source checkout contains substantial unrelated edits and unreleased search-growth work; no full deployment was appropriate for this read-only audit.

## Yandex setup completed to service limit

28 October: saved root TXT `yandex-verification: e1292077bd36eafd` in Cloudflare after owner confirmation. Yandex Manage access confirmed signed-in owner via DNS, verification date 10/28/2026. Existing DNS records were preserved.

Sitemap submission attempted through the normal UI, but the service displays: "The Sitemap files tool is in read-only mode. You can’t add a file or submit it for recrawling right now." Add remains disabled after filling `https://shentarot.com/sitemap.xml`. No submission success is claimed. Existing robots.txt already advertises the sitemap. Revisit when Yandex restores service.
