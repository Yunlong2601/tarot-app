// @ts-check
import { defineConfig } from "astro/config";
import { SITE_URL } from "./src/config.ts";

export default defineConfig({
  site: SITE_URL,
  base: new URL(SITE_URL).pathname,
  // "preserve" keeps .html addresses (cards/major-00-fool.html, cards/index.html),
  // the same as the earlier static site, so existing links and the privacy
  // and terms links keep working.
  build: { format: "preserve" },
  trailingSlash: "never",
  // Card and spread data come from the backend (one source for app, readings
  // and site), which lives outside this folder.
  vite: { server: { fs: { allow: [".."] } } },
});
