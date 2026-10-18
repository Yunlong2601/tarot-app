// Generates the free web pages in site/ (card meanings, spreads, a random card
// draw and a birth card calculator) from the app's own data, so the site and
// the app never disagree. Re-run after changing cards or spreads:
//
//   node --experimental-strip-types scripts/gen-site.mjs
//
// Writes site/cards/, site/spreads/, site/tools/, site/assets/site.css,
// site/sitemap.xml and site/robots.txt, and copies the public-domain card art
// to site/cards/art/. Pages are static: no tracking, no cookies.
import { copyFileSync, existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const { CARDS } = await import(join(root, "backend/src/cards.ts"));
const { SPREADS } = await import(join(root, "backend/src/spreads.ts"));

/** Where the site is published (GitHub Pages). Used for the sitemap only. */
const BASE_URL = "https://yunlong2601.github.io/shentarot-legal/";
/** Store links for the "Get the app" buttons. Fill in once the app is live. */
const APP_STORE_URL = "";
const PLAY_STORE_URL = "";

const site = join(root, "site");
const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const slug = (id) => id.replace(/_/g, "-");
const write = (rel, html) => {
  const p = join(site, rel);
  mkdirSync(dirname(p), { recursive: true });
  writeFileSync(p, html);
};

/** Spread sources live in the app (app/lib/data/spreads.dart). */
function spreadSources() {
  const dart = readFileSync(join(root, "app/lib/data/spreads.dart"), "utf8");
  const consts = Object.fromEntries([...dart.matchAll(/^const (_\w+) = '([^']*)';/gm)].map((m) => [m[1], m[2]]));
  const out = {};
  for (const block of dart.split("SpreadDef(").slice(1)) {
    const wire = block.match(/wire: '([a-z_]+)'/)?.[1];
    const src = block.match(/source:\s*((?:'[^']*'\s*)+|_\w+)/)?.[1];
    if (!wire || !src) continue;
    out[wire] = src.startsWith("_") ? consts[src] : [...src.matchAll(/'([^']*)'/g)].map((m) => m[1]).join("");
  }
  return out;
}
const SOURCES = spreadSources();

const storeButtons = () => {
  const b = [
    APP_STORE_URL && `<a class="btn" href="${esc(APP_STORE_URL)}">Download on the App Store</a>`,
    PLAY_STORE_URL && `<a class="btn" href="${esc(PLAY_STORE_URL)}">Get it on Google Play</a>`,
  ].filter(Boolean).join(" ");
  return b || `<p class="muted">Coming soon to the App Store and Google Play.</p>`;
};

function page({ title, description, path, body, depth }) {
  const up = "../".repeat(depth);
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<meta name="description" content="${esc(description)}">
<link rel="canonical" href="${BASE_URL}${path}">
<meta property="og:title" content="${esc(title)}"><meta property="og:description" content="${esc(description)}">
<link rel="stylesheet" href="${up}assets/site.css">
</head><body>
<header><a class="brand" href="${up}index.html">ShenTarot</a>
<nav><a href="${up}cards/index.html">Card meanings</a><a href="${up}spreads/index.html">Spreads</a><a href="${up}tools/random-card.html">Draw a card</a><a href="${up}tools/birth-card.html">Birth cards</a></nav></header>
<main>
${body}
<section class="cta"><h2>Read your own cards</h2><p>Scan your own Rider-Waite-Smith deck or draw on screen, and get a reading for your question.</p>${storeButtons()}</section>
</main>
<footer><p>For entertainment and self-reflection only. Card images: Rider-Waite-Smith deck (1909), public domain.</p>
<p><a href="${up}privacy.html">Privacy</a> · <a href="${up}terms.html">Terms</a></p></footer>
</body></html>
`;
}

const CSS = `:root{--bg:#faf8f3;--fg:#1f1d19;--muted:#6b665c;--gold:#9a7a2c;--panel:#fff;--line:#e6e0d2}
@media(prefers-color-scheme:dark){:root{--bg:#0d0c0a;--fg:#ece7da;--muted:#9a9488;--gold:#e3c77a;--panel:#1a1814;--line:#2a2822}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.6 -apple-system,system-ui,sans-serif}
header{display:flex;flex-wrap:wrap;gap:.5rem 1rem;align-items:center;justify-content:space-between;padding:.8rem 1rem;border-bottom:1px solid var(--line)}
header nav{display:flex;flex-wrap:wrap;gap:.3rem 1rem}a{color:var(--gold)}.brand{font-weight:800;text-decoration:none}
main{max-width:52rem;margin:0 auto;padding:1rem 1rem 3rem}h1{line-height:1.2}h2{color:var(--gold);font-size:1.15rem}
.muted{color:var(--muted)}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(7.5rem,1fr));gap:.8rem}
.grid a{display:block;text-decoration:none;color:var(--fg);text-align:center;font-size:.9rem}
.grid img,.card-img{width:100%;height:auto;border-radius:8px;border:1px solid var(--line)}
.card-top{display:grid;grid-template-columns:minmax(8rem,14rem) 1fr;gap:1.2rem;align-items:start}
@media(max-width:34rem){.card-top{grid-template-columns:1fr}.card-top img{max-width:14rem}}
.chips span{display:inline-block;margin:.15rem;padding:.15rem .6rem;border:1px solid var(--line);border-radius:999px;font-size:.85rem}
.panel{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:.8rem 1rem;margin:.8rem 0}
.cta{margin-top:2.5rem;padding:1.2rem;border-radius:16px;background:var(--panel);border:1px solid var(--gold);text-align:center}
.btn,button{display:inline-block;margin:.3rem;padding:.65rem 1.1rem;border-radius:999px;background:var(--gold);color:#111;font-weight:700;text-decoration:none;border:0;font-size:1rem;cursor:pointer}
footer{max-width:52rem;margin:0 auto;padding:1rem;color:var(--muted);font-size:.85rem}
ol.positions li{margin:.3rem 0}.draw{display:flex;flex-wrap:wrap;gap:.8rem;justify-content:center;margin:1rem 0}
.draw .slot{width:8rem;text-align:center}.draw .back{width:100%;aspect-ratio:7/12;border-radius:8px;background:repeating-linear-gradient(45deg,var(--gold) 0 6px,var(--panel) 6px 12px);border:1px solid var(--line);cursor:pointer}
.rev{transform:rotate(180deg)}input,select{font:inherit;padding:.4rem;border-radius:8px;border:1px solid var(--line);background:var(--panel);color:var(--fg)}
`;

const cardIds = Object.keys(CARDS);
const suitTitle = (s) => s ? s[0].toUpperCase() + s.slice(1) : "Major Arcana";
const artRel = (id, depth) => `${"../".repeat(depth)}cards/art/${id}.jpg`;

// Card pages
for (const id of cardIds) {
  const c = CARDS[id];
  const k = c.k;
  const kind = c.arcana === "major" ? `Major Arcana · ${c.number}` : `Minor Arcana · ${suitTitle(c.suit)}`;
  const facts = [c.element && `Element: ${c.element}`, c.association && `Traditional association: ${c.association}`].filter(Boolean).join(" · ");
  const rich = k ? `
<div class="panel"><h2>What the card shows</h2><p>${esc(k.imagery)}</p><p class="muted">${esc(k.why)}</p></div>
<div class="panel"><h2>Upright</h2><p>${esc(k.upright.core)}</p>
<p><strong>Light:</strong> ${esc(k.upright.light)}. <strong>Shadow:</strong> ${esc(k.upright.shadow)}.</p>
<p><strong>Love:</strong> ${esc(k.upright.love)}</p><p><strong>Work:</strong> ${esc(k.upright.work)}</p>
<p><em>To reflect on: ${esc(k.upright.question)}</em></p></div>
<div class="panel"><h2>Reversed</h2><p>${esc(k.reversed.core)}</p><ul>${k.reversed.modes.map((m) => `<li>${esc(m)}</li>`).join("")}</ul>
<p><em>To reflect on: ${esc(k.reversed.question)}</em></p></div>` : `
<div class="panel"><h2>Upright</h2><p>${esc(c.upright)}</p></div>
<div class="panel"><h2>Reversed</h2><p>${esc(c.reversed)}</p></div>`;
  const i = cardIds.indexOf(id);
  const prev = cardIds[(i - 1 + cardIds.length) % cardIds.length];
  const next = cardIds[(i + 1) % cardIds.length];
  write(`cards/${slug(id)}.html`, page({
    title: `${c.name} tarot card meaning: upright and reversed · ShenTarot`,
    description: `${c.name} meaning in tarot, upright and reversed: ${c.keywords.join(", ")}. ${k?.essence ?? c.upright}`,
    path: `cards/${slug(id)}.html`, depth: 1,
    body: `<p class="muted"><a href="index.html">Card meanings</a> › ${esc(suitTitle(c.suit))}</p>
<div class="card-top"><img class="card-img" src="${artRel(id, 1)}" alt="${esc(c.name)}, Rider-Waite-Smith deck" width="300" height="514">
<div><h1>${esc(c.name)}</h1><p class="muted">${esc(kind)}${facts ? ` · ${esc(facts)}` : ""}</p>
<p class="chips">${c.keywords.map((w) => `<span>${esc(w)}</span>`).join("")}</p>
${k ? `<p><strong>${esc(k.essence)}</strong></p>` : ""}<p>${esc(c.upright)}</p></div></div>
${rich}
<p><a href="${slug(prev)}.html">‹ ${esc(CARDS[prev].name)}</a> · <a href="${slug(next)}.html">${esc(CARDS[next].name)} ›</a></p>`,
  }));
}

// Card index
const groups = ["major", "wands", "cups", "swords", "pentacles"];
write("cards/index.html", page({
  title: "Tarot card meanings: all 78 cards · ShenTarot",
  description: "Meanings of all 78 Rider-Waite-Smith tarot cards, upright and reversed, with what each card shows and why.",
  path: "cards/index.html", depth: 1,
  body: `<h1>Tarot card meanings</h1><p class="muted">All 78 cards of the Rider-Waite-Smith deck, upright and reversed.</p>
${groups.map((g) => {
    const ids = cardIds.filter((id) => (g === "major" ? CARDS[id].arcana === "major" : CARDS[id].suit === g));
    return `<h2>${esc(g === "major" ? "Major Arcana" : suitTitle(g))}</h2><div class="grid">${ids.map((id) =>
      `<a href="${slug(id)}.html"><img src="art/${id}.jpg" alt="" loading="lazy" width="150" height="257">${esc(CARDS[id].name)}</a>`).join("")}</div>`;
  }).join("\n")}`,
}));

// Spread pages
const spreadIds = Object.keys(SPREADS);
for (const id of spreadIds) {
  const s = SPREADS[id];
  write(`spreads/${slug(id)}.html`, page({
    title: `${s.name} tarot spread: ${s.positions.length} card${s.positions.length === 1 ? "" : "s"} · ShenTarot`,
    description: `${s.name}: a ${s.positions.length}-card tarot spread. ${s.purpose}`,
    path: `spreads/${slug(id)}.html`, depth: 1,
    body: `<p class="muted"><a href="index.html">Spreads</a></p><h1>${esc(s.name)}</h1>
<p class="muted">${s.positions.length} card${s.positions.length === 1 ? "" : "s"} · ${esc(s.category[0].toUpperCase() + s.category.slice(1))}</p>
<div class="panel"><h2>Best for</h2><p>${esc(s.purpose)}</p></div>
<div class="panel"><h2>Positions</h2><ol class="positions">${s.positions.map((p) => `<li>${esc(p)}</li>`).join("")}</ol></div>
${SOURCES[id] ? `<p class="muted">Source: ${esc(SOURCES[id])}</p>` : ""}`,
  }));
}
write("spreads/index.html", page({
  title: "Tarot spreads: layouts and what each position means · ShenTarot",
  description: "Tarot spreads for love, career, decisions and yes or no questions, with every position explained.",
  path: "spreads/index.html", depth: 1,
  body: `<h1>Tarot spreads</h1><p class="muted">What each spread is for and what each position means.</p>
${["classics", "love", "career", "growth"].map((cat) => `<h2>${cat[0].toUpperCase() + cat.slice(1)}</h2><ul>${spreadIds.filter((id) => SPREADS[id].category === cat)
    .map((id) => `<li><a href="${slug(id)}.html">${esc(SPREADS[id].name)}</a> <span class="muted">(${SPREADS[id].positions.length} cards)</span></li>`).join("")}</ul>`).join("\n")}`,
}));

// Tools: data for the page scripts.
const deckJson = JSON.stringify(cardIds.map((id) => ({ id, slug: slug(id), name: CARDS[id].name, major: CARDS[id].arcana === "major", n: CARDS[id].number })));

write("tools/random-card.html", page({
  title: "Random tarot card generator: draw 1 to 10 cards · ShenTarot",
  description: "Draw random tarot cards from the full 78-card Rider-Waite-Smith deck. Tap a card to turn it over and read its meaning.",
  path: "tools/random-card.html", depth: 1,
  body: `<h1>Draw a tarot card</h1><p class="muted">Shuffled in your browser from all 78 cards. About one card in four comes up reversed.</p>
<p><label>Cards: <select id="n">${[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((n) => `<option${n === 3 ? " selected" : ""}>${n}</option>`).join("")}</select></label>
<button id="go" type="button">Shuffle and draw</button></p>
<div class="draw" id="out" aria-live="polite"></div>
<script>
const DECK=${deckJson};
function draw(){const n=+document.getElementById('n').value;const d=DECK.slice();
for(let i=d.length-1;i>0;i--){const r=new Uint32Array(1);crypto.getRandomValues(r);const j=r[0]%(i+1);[d[i],d[j]]=[d[j],d[i]];}
const out=document.getElementById('out');out.textContent='';
d.slice(0,n).forEach(c=>{const r=new Uint32Array(1);crypto.getRandomValues(r);const rev=r[0]%4===0;
const slot=document.createElement('div');slot.className='slot';const back=document.createElement('button');back.className='back';back.type='button';back.setAttribute('aria-label','Turn over this card');
back.onclick=()=>{slot.innerHTML='';const a=document.createElement('a');a.href='../cards/'+c.slug+'.html';const img=document.createElement('img');img.src='../cards/art/'+c.id+'.jpg';img.alt=c.name+(rev?', reversed':'');img.className='card-img'+(rev?' rev':'');a.appendChild(img);const t=document.createElement('div');t.textContent=c.name+(rev?' (reversed)':'');a.appendChild(t);slot.appendChild(a);};
slot.appendChild(back);out.appendChild(slot);});}
document.getElementById('go').onclick=draw;
</script>`,
}));

write("tools/birth-card.html", page({
  title: "Tarot birth card calculator: find your birth cards · ShenTarot",
  description: "Find your tarot birth cards and your card for this year from your birthday. Worked out in your browser; nothing is sent.",
  path: "tools/birth-card.html", depth: 1,
  body: `<h1>Tarot birth card calculator</h1>
<p class="muted">A traditional numerology method: add your birth month, day and year, then add the digits until you reach 22 or less. That number is a Major Arcana card (22 is The Fool). A two-digit result also gives the card for the sum of its digits. Worked out in your browser; nothing is sent.</p>
<p><label>Your birthday: <input type="date" id="bd" max="${new Date().toISOString().slice(0, 10)}"></label> <button id="go" type="button">Find my cards</button></p>
<div id="out" aria-live="polite"></div>
<script>
const DECK=${deckJson}.filter(c=>c.major);
const digits=n=>String(n).split('').reduce((s,d)=>s+ +d,0);
function nums(y,m,d){let n=y+m+d;while(n>22)n=digits(n);if(n===22)return[0,4];const o=[n];while(n>=10){n=digits(n);o.push(n);}return o;}
function cardHtml(n){const c=DECK.find(x=>x.n===n);return '<a class="slot" href="../cards/'+c.slug+'.html"><img class="card-img" src="../cards/art/'+c.id+'.jpg" alt=""><div>'+c.name+'</div></a>';}
document.getElementById('go').onclick=()=>{const v=document.getElementById('bd').value;const out=document.getElementById('out');if(!v){out.textContent='Pick a date first.';return;}
const [y,m,d]=v.split('-').map(Number);const year=new Date().getFullYear();
out.innerHTML='<h2>Your birth cards</h2><div class="draw">'+nums(y,m,d).map(cardHtml).join('')+'</div><h2>Your card for '+year+'</h2><div class="draw">'+cardHtml(nums(year,m,d)[0])+'</div><p class="muted">Themes you may grow into, not a fixed fate.</p>';};
</script>`,
}));

// Art, CSS, sitemap, robots
mkdirSync(join(site, "cards/art"), { recursive: true });
const artDir = join(root, "app/assets/cards/art");
for (const f of readdirSync(artDir)) if (f.endsWith(".jpg") || f === "CREDITS.md") copyFileSync(join(artDir, f), join(site, "cards/art", f));
write("assets/site.css", CSS);
const urls = ["", "cards/index.html", "spreads/index.html", "tools/random-card.html", "tools/birth-card.html",
  ...cardIds.map((id) => `cards/${slug(id)}.html`), ...spreadIds.map((id) => `spreads/${slug(id)}.html`)];
write("sitemap.xml", `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls.map((u) => `  <url><loc>${BASE_URL}${u}</loc></url>`).join("\n")}\n</urlset>\n`);
write("robots.txt", `User-agent: *\nAllow: /\nSitemap: ${BASE_URL}sitemap.xml\n`);
if (!existsSync(join(site, "index.html"))) throw new Error("site/index.html missing");
console.log(`Wrote ${cardIds.length} card pages, ${spreadIds.length} spread pages, 2 tools, sitemap (${urls.length} URLs).`);
