import type { APIRoute } from "astro";
import { SITE_URL } from "../config.ts";

export const GET: APIRoute = () =>
  new Response(`User-agent: *\nAllow: /\nSitemap: ${new URL("sitemap.xml", SITE_URL).href}\n`, {
    headers: { "content-type": "text/plain" },
  });
