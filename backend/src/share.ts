import { CARDS } from "./cards";
import { POSITIONS } from "./knowledge";
import { SPREADS, isSpread, spreadSize, type Spread } from "./spreads";
import { cleanQuestion, type Parsed } from "./validate";

/** Shared readings (opt-in, per reading): the app sends a copy of one reading
 * and gets a public link. Stored in KV for SHARE_DAYS, then gone; the person
 * who shared it can delete it at any time. The question is included only when
 * the user ticks "Show my question". No install id or account is stored with
 * it, only a salted hash used to allow deletion. */
export const SHARE_DAYS = 365;
export const SHARES_PER_DAY = 20;
export const MAX_SHARED_READING = 6000;

export interface SharedReading {
  spread: Spread;
  cards: { id: string; reversed: boolean }[];
  reading: string;
  question: string | null;
  createdAt: string;
}

/** Reading text keeps its line breaks (the page lays out its sections) but
 * loses control characters and angle brackets; the page escapes it again. */
function cleanReading(raw: string): string {
  return raw
    .replace(/\r\n?/g, "\n")
    .replace(/[\u0000-\u0009\u000b-\u001f\u007f-\u009f\u2028\u2029]/g, " ")
    .replace(/[<>]/g, "")
    .replace(/[ \t]+/g, " ")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

export function parseShareRequest(body: unknown, now: Date): Parsed<SharedReading> {
  if (typeof body !== "object" || body === null) return { ok: false, error: "body must be a JSON object" };
  const b = body as Record<string, unknown>;
  if (!isSpread(b.spread)) return { ok: false, error: "unknown spread" };
  const spread = b.spread;
  if (!Array.isArray(b.cards) || b.cards.length !== spreadSize(spread)) return { ok: false, error: "wrong number of cards" };
  const cards: SharedReading["cards"] = [];
  for (const c of b.cards) {
    const { id, reversed } = (c ?? {}) as Record<string, unknown>;
    if (typeof id !== "string" || !Object.hasOwn(CARDS, id) || typeof reversed !== "boolean") {
      return { ok: false, error: "invalid card" };
    }
    if (cards.some((x) => x.id === id)) return { ok: false, error: "duplicate card" };
    cards.push({ id, reversed });
  }
  if (typeof b.reading !== "string" || b.reading.length > MAX_SHARED_READING * 2) return { ok: false, error: "invalid reading" };
  const reading = cleanReading(b.reading);
  if (reading.length < 20 || reading.length > MAX_SHARED_READING) return { ok: false, error: "invalid reading" };
  let question: string | null = null;
  if (b.question !== undefined && b.question !== null) {
    if (typeof b.question !== "string" || b.question.length > 600) return { ok: false, error: "invalid question" };
    question = cleanQuestion(b.question).slice(0, 300) || null;
  }
  return { ok: true, value: { spread, cards, reading, question, createdAt: now.toISOString() } };
}

/** 128-bit random token, URL-safe. */
export function newShareToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(16));
  return btoa(String.fromCharCode(...bytes)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

export const isShareToken = (t: string): boolean => /^[A-Za-z0-9_-]{22}$/.test(t);

const esc = (s: string): string =>
  s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");

/** Section titles the app writes (see renderReading in reading.ts). */
const LEAD = new Set(["In a line"]);
const BOXED = new Set(["In short", "Putting it together"]);

function readingHtml(text: string): string {
  return text.split(/\n\s*\n/).map((block) => {
    const lines = block.trim().split("\n").map((l) => l.trim()).filter(Boolean);
    if (lines.length === 0) return "";
    const [title, ...rest] = lines;
    const isTitle = rest.length > 0 && title!.length <= 70 && !/[.?]$/.test(title!);
    if (!isTitle) return `<p>${lines.map(esc).join("<br>")}</p>`;
    const why = rest.filter((l) => l.startsWith("Why:")).map((l) => `<p class="why">${esc(l)}</p>`).join("");
    const body = rest.filter((l) => !l.startsWith("Why:")).map((l) => `<p>${esc(l)}</p>`).join("");
    if (LEAD.has(title!)) return `<p class="lead">${esc(rest.join(" "))}</p>`;
    if (title === "Yes or no") return `<p class="lean">${esc(rest.join(" "))}</p>`;
    const cls = BOXED.has(title!) ? "section boxed" : "section";
    return `<section class="${cls}"><h2>${esc(title!)}</h2>${body}${why}</section>`;
  }).join("\n");
}

export function renderSharePage(s: SharedReading, links: { appStore?: string; playStore?: string }): string {
  const positions = POSITIONS[s.spread];
  const title = s.question ? `“${s.question}”` : "A tarot reading";
  const strip = s.cards.map((c, i) => {
    const card = CARDS[c.id]!;
    return `<li><span class="pos">${esc(positions[i]!)}</span><span class="name">${esc(card.name)}</span>${c.reversed ? '<span class="rev">Reversed</span>' : ""}</li>`;
  }).join("");
  const date = s.createdAt.slice(0, 10);
  const buttons = [
    links.appStore ? `<a class="btn" href="${esc(links.appStore)}">Download on the App Store</a>` : "",
    links.playStore ? `<a class="btn" href="${esc(links.playStore)}">Get it on Google Play</a>` : "",
  ].join("");
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow">
<title>${esc(s.question ?? "A tarot reading")} · ShenTarot</title>
<meta property="og:title" content="${esc(s.question ?? "A tarot reading")}">
<meta property="og:description" content="${esc(`${SPREADS[s.spread].name}: ${s.cards.map((c) => CARDS[c.id]!.name).join(", ")}`)}">
<meta property="og:site_name" content="ShenTarot">
<style>
:root{--bg:#faf8f3;--fg:#1f1d19;--muted:#6b665c;--gold:#9a7a2c;--panel:#fff;--line:#e6e0d2}
@media(prefers-color-scheme:dark){:root{--bg:#0d0c0a;--fg:#ece7da;--muted:#9a9488;--gold:#e3c77a;--panel:#1a1814;--line:#2a2822}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.6 -apple-system,system-ui,sans-serif}
main{max-width:42rem;margin:0 auto;padding:1.5rem 1rem 4rem}
.kicker{color:var(--gold);letter-spacing:.12em;text-transform:uppercase;font-size:.75rem;font-weight:700}
h1{font-size:1.6rem;line-height:1.25;margin:.4rem 0}.meta{color:var(--muted);font-size:.9rem}
ol.strip{position:sticky;top:0;list-style:none;margin:1rem -1rem;padding:.6rem 1rem;display:flex;gap:.5rem;overflow-x:auto;background:var(--bg);border-bottom:1px solid var(--line)}
ol.strip li{flex:0 0 auto;background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:.45rem .7rem;display:flex;flex-direction:column;min-width:7rem}
.pos{font-size:.7rem;color:var(--muted);text-transform:uppercase;letter-spacing:.06em}.name{font-weight:600}.rev{font-size:.75rem;color:#c0563f}
.lead{font-size:1.25rem;font-weight:700;margin:1.2rem 0}
.lean{font-size:1.6rem;font-weight:800;color:var(--gold);text-align:center;border:1px solid var(--gold);border-radius:16px;padding:.8rem;margin:1rem 0}
.section{margin:1rem 0}.boxed{background:var(--panel);border:1px solid var(--gold);border-radius:16px;padding:.8rem 1rem}
h2{font-size:1.05rem;color:var(--gold);margin:.2rem 0}.why{color:var(--muted);font-style:italic;font-size:.92rem}
.cta{margin-top:2rem;padding:1.2rem;border-radius:16px;background:var(--panel);border:1px solid var(--line);text-align:center}
.btn{display:inline-block;margin:.3rem;padding:.7rem 1.1rem;border-radius:999px;background:var(--gold);color:#111;font-weight:700;text-decoration:none}
.note{color:var(--muted);font-size:.8rem;margin-top:2rem}
</style></head>
<body><main>
<div class="kicker">ShenTarot reading</div>
<h1>${esc(title)}</h1>
<div class="meta">${esc(SPREADS[s.spread].name)} · ${s.cards.length} card${s.cards.length === 1 ? "" : "s"} · ${esc(date)}</div>
<ol class="strip">${strip}</ol>
${readingHtml(s.reading)}
<div class="cta"><strong>Ask your own question</strong><p>Scan your own deck or draw on screen, and get a reading of your own.</p>${buttons}</div>
<p class="note">AI-generated, for entertainment and self-reflection only. Not medical, legal, financial or professional advice.</p>
</main></body></html>`;
}

export function notFoundPage(): string {
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="robots" content="noindex"><title>Reading not found · ShenTarot</title>
<style>body{font:16px/1.6 -apple-system,system-ui,sans-serif;max-width:40rem;margin:3rem auto;padding:0 1rem;background:#faf8f3;color:#1f1d19}@media(prefers-color-scheme:dark){body{background:#0d0c0a;color:#ece7da}}</style></head>
<body><h1>This reading is no longer shared</h1><p>The person who shared it may have removed it, or the link has expired.</p></body></html>`;
}
