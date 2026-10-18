// Copies the public-domain card art from the app into public/cards/art so the
// site serves the same images as the app. Runs before dev and build.
import { copyFileSync, mkdirSync, readdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const web = join(dirname(fileURLToPath(import.meta.url)), "..");
const from = join(web, "../app/assets/cards/art");
const to = join(web, "public/cards/art");
mkdirSync(to, { recursive: true });
let n = 0;
for (const f of readdirSync(from)) {
  if (f.endsWith(".jpg") || f === "CREDITS.md") {
    copyFileSync(join(from, f), join(to, f));
    n++;
  }
}
console.log(`Copied ${n} card art files.`);
