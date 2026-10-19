import type { APIRoute } from "astro";
import { SITE_URL } from "../config.ts";
import { cardIds, slug, spreadIds } from "../lib/data.ts";
import { QUESTION_GUIDES } from "../lib/questions.ts";
import { TOPICS } from "../lib/topics.ts";
import { LOCALES, LOCALE_INFO, prefix } from "../i18n/index.ts";

export const GET: APIRoute = () => {
  const paths = [
    "",
    "about",
    "cards",
    "spreads",
    "tools",
    "tools/yes-no",
    "tools/daily-card",
    "tools/combinations",
    "tools/elements",
    "tools/random-card",
    "tools/birth-card",
    "tools/love-compatibility",
    "tools/year-card",
    "tools/zodiac-tarot",
    "tools/life-path",
    "tools/which-card-are-you",
    "tools/weekly-draw",
    "tools/reading-sheet",
    ...TOPICS.map((t) => `topics/${t.slug}`),
    "questions",
    ...QUESTION_GUIDES.map((g) => `questions/${g.slug}`),
    ...cardIds.map((id) => `cards/${slug(id)}`),
    ...spreadIds.map((id) => `spreads/${slug(id)}`),
  ];
  const loc = (l: (typeof LOCALES)[number], p: string) => new URL(`${prefix(l)}${p}`.replace(/\/$/, ""), SITE_URL).href;
  // Every page in every language, each listing its translations so search engines pair them.
  const urls = LOCALES.flatMap((l) =>
    paths.map((p) => {
      const alts = LOCALES.map((a) => `    <xhtml:link rel="alternate" hreflang="${LOCALE_INFO[a].tag}" href="${loc(a, p)}"/>`).join("\n");
      return `  <url>\n    <loc>${loc(l, p)}</loc>\n${alts}\n    <xhtml:link rel="alternate" hreflang="x-default" href="${loc("en", p)}"/>\n  </url>`;
    }),
  );
  const english = ["privacy", "terms"].map((p) => `  <url><loc>${new URL(p, SITE_URL).href}</loc></url>`);
  const body = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
${[...urls, ...english].join("\n")}
</urlset>
`;
  return new Response(body, { headers: { "content-type": "application/xml" } });
};
