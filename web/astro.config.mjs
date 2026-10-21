// @ts-check
import { defineConfig } from "astro/config";
import { SITE_URL } from "./src/config.ts";

export default defineConfig({
  site: SITE_URL,
  base: new URL(SITE_URL).pathname,
  // "preserve" writes cards/index.astro to cards/index.html and
  // cards/[slug].astro to cards/<slug>.html. Cloudflare serves them at clean
  // addresses (/cards, /cards/major-00-fool); see wrangler.jsonc.
  build: { format: "preserve" },
  trailingSlash: "never",
  // Card and spread data come from the backend (one source for app, readings
  // and site), which lives outside this folder.
  vite: { server: { fs: { allow: [".."] } } },
});
