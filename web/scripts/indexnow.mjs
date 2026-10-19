// Tells Bing, Yandex and the other IndexNow search engines that the site's
// pages changed, right after a deploy. Run by `npm run deploy`. It never fails
// the deploy: a problem is printed and the script exits normally.
//
// The key is public by design: search engines check it at
// https://shentarot.com/<key>.txt, which is the file in public/.
import { readdirSync, readFileSync } from "node:fs";

const SITE = "https://shentarot.com";
try {
  const keyFile = readdirSync("public").find((f) => /^[0-9a-f]{32}\.txt$/.test(f));
  if (!keyFile) throw new Error("no IndexNow key file in public/");
  const key = readFileSync(`public/${keyFile}`, "utf8").trim();
  const sitemap = readFileSync("dist/sitemap.xml", "utf8");
  const urls = [...sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]);
  urls.push(`${SITE}/llms.txt`, `${SITE}/llms-full.txt`);
  const res = await fetch("https://api.indexnow.org/indexnow", {
    method: "POST",
    headers: { "content-type": "application/json; charset=utf-8" },
    body: JSON.stringify({ host: new URL(SITE).host, key, keyLocation: `${SITE}/${keyFile}`, urlList: urls }),
    signal: AbortSignal.timeout(20000),
  });
  console.log(res.ok ? `IndexNow: sent ${urls.length} pages (${res.status}).` : `IndexNow: not accepted (${res.status} ${await res.text()}).`);
} catch (e) {
  console.log(`IndexNow: skipped (${e instanceof Error ? e.message : e}).`);
}
