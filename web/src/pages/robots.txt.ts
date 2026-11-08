import type { APIRoute } from "astro";
import { SITE_URL } from "../config.ts";

// Repeat the preferences in named groups as well as the catch-all group.
const CONTENT_SIGNAL = "Content-Signal: ai-train=no, search=yes, ai-input=yes";
const AI_CRAWLERS = [
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
      // OpenAI treats GPTBot's crawl rule and OAI-SearchBot's rule separately.
      `User-agent: GPTBot\n${CONTENT_SIGNAL}\nDisallow: /\n`,
      ...AI_CRAWLERS.map((bot) => `User-agent: ${bot}\n${CONTENT_SIGNAL}\nAllow: /\n`),
      `User-agent: *\n${CONTENT_SIGNAL}\nAllow: /\n`,
      `Sitemap: ${new URL("sitemap.xml", SITE_URL).href}\n`,
    ].join("\n"),
    { headers: { "content-type": "text/plain" } },
  );
