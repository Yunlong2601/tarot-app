import type { APIRoute } from "astro";
import { SITE_URL } from "../config.ts";
import { cardIds, slug, spreadIds } from "../lib/data.ts";
import { QUESTION_GUIDES } from "../lib/questions.ts";
import { TOPICS } from "../lib/topics.ts";

export const GET: APIRoute = () => {
  const paths = [
    "",
    "cards",
    "spreads",
    "tools",
    "tools/yes-no",
    "tools/daily-card",
    "tools/combinations",
    "tools/elements",
    "tools/random-card",
    "tools/birth-card",
    ...TOPICS.map((t) => `topics/${t.slug}`),
    "questions",
    ...QUESTION_GUIDES.map((g) => `questions/${g.slug}`),
    ...cardIds.map((id) => `cards/${slug(id)}`),
    ...spreadIds.map((id) => `spreads/${slug(id)}`),
    "privacy",
    "terms",
  ];
  const body = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${paths.map((p) => `  <url><loc>${new URL(p, SITE_URL).href}</loc></url>`).join("\n")}
</urlset>
`;
  return new Response(body, { headers: { "content-type": "application/xml" } });
};
