// Link-preview images for the card pages: each card on the site's night
// background at 1200x630, the shape link previews use. No text, so one image
// serves every language. Runs before dev and build, after copy-art.mjs, and
// skips images that are already up to date.
import { existsSync, mkdirSync, readdirSync, statSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const web = join(dirname(fileURLToPath(import.meta.url)), "..");
const art = join(web, "public/cards/art");
const out = join(web, "public/og/cards");
mkdirSync(out, { recursive: true });

const W = 1200, H = 630, CH = 540, CW = 2 * Math.round(CH * (357 / 600) / 2);
const background = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">
  <defs>
    <radialGradient id="g" cx="50%" cy="50%" r="60%">
      <stop offset="0" stop-color="#d9b56a" stop-opacity="0.28"/>
      <stop offset="1" stop-color="#d9b56a" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="100%" height="100%" fill="#09080f"/>
  <rect width="100%" height="100%" fill="url(#g)"/>
  <rect x="24" y="24" width="${W - 48}" height="${H - 48}" rx="22" fill="none" stroke="#e2c88c" stroke-opacity="0.25" stroke-width="2"/>
  <rect x="${(W - CW) / 2 - 6}" y="${(H - CH) / 2 + 14}" width="${CW + 12}" height="${CH}" rx="20" fill="#000" fill-opacity="0.55" filter="blur(12px)"/>
</svg>`);
const mask = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}"><rect width="${CW}" height="${CH}" rx="16" fill="#fff"/></svg>`);

let made = 0;
for (const f of readdirSync(art).filter((f) => f.endsWith(".jpg"))) {
  const dest = join(out, f);
  if (existsSync(dest) && statSync(dest).mtimeMs >= statSync(join(art, f)).mtimeMs) continue;
  const card = await sharp(join(art, f)).resize(CW, CH).composite([{ input: mask, blend: "dest-in" }]).png().toBuffer();
  await sharp(background).composite([{ input: card, left: (W - CW) / 2, top: (H - CH) / 2 }]).jpeg({ quality: 82, mozjpeg: true }).toFile(dest);
  made++;
}
console.log(`Made ${made} card preview images.`);
