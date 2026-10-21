import type { APIRoute } from "astro";
import { SITE_URL } from "../config.ts";

// Search engines and AI answer engines are welcome everywhere. The AI crawlers
// are named so a "block AI bots" default elsewhere can't be read as our choice.
const AI_CRAWLERS = [
  "GPTBot",
  "OAI-SearchBot",
  "ChatGPT-User",
  "ClaudeBot",
  "Claude-SearchBot",
  "Claude-User",
  "PerplexityBot",
  "Perplexity-User",
  "Google-Extended",
  "Applebot-Extended",
  "Bingbot",
  "CCBot",
];

export const GET: APIRoute = () =>
  new Response(
    [
      ...AI_CRAWLERS.map((bot) => `User-agent: ${bot}\nAllow: /\n`),
      "User-agent: *\nAllow: /\n",
      `Sitemap: ${new URL("sitemap.xml", SITE_URL).href}\n`,
    ].join("\n"),
    { headers: { "content-type": "text/plain" } },
  );
