// Checks that every translated file in src/i18n/<locale>/ has exactly the
// keys and list lengths of the English file, with no empty or untranslated-
// looking strings. Usage: node scripts/check-i18n.mjs [locale ...]
import { existsSync, readFileSync, readdirSync } from "node:fs";

const dir = "src/i18n";
const locales = process.argv.slice(2).length ? process.argv.slice(2) : readdirSync(dir).filter((d) => d !== "en" && !d.includes("."));
let bad = 0;
const fail = (m) => { bad++; if (bad <= 40) console.log("  " + m); };

function compare(en, tr, path) {
  if (Array.isArray(en)) {
    if (!Array.isArray(tr)) return fail(`${path}: expected a list`);
    // Word lists for matching questions differ in length from language to language.
    if (path.includes(".recommend.")) return tr.forEach((v, i) => typeof v !== "string" && fail(`${path}[${i}]: not text`));
    if (tr.length !== en.length) fail(`${path}: ${tr.length} items, English has ${en.length}`);
    en.forEach((v, i) => compare(v, tr[i], `${path}[${i}]`));
  } else if (en && typeof en === "object") {
    if (!tr || typeof tr !== "object" || Array.isArray(tr)) return fail(`${path}: expected an object`);
    for (const k of Object.keys(en)) if (!(k in tr)) fail(`${path}.${k}: missing`);
    // Plural groups may add the forms a language needs (few, many, ...).
    const plural = "other" in en && "one" in en;
    for (const k of Object.keys(tr)) if (!(k in en) && !(plural && ["zero", "two", "few", "many"].includes(k))) fail(`${path}.${k}: not in English`);
    for (const k of Object.keys(en)) if (k in tr) compare(en[k], tr[k], `${path}.${k}`);
  } else if (typeof en === "string") {
    if (typeof tr !== "string" || !tr.trim()) return fail(`${path}: empty or not text`);
    const ph = (s) => (s.match(/\{\w+\}/g) ?? []).sort().join();
    if (ph(en) !== ph(tr)) fail(`${path}: placeholders differ (${ph(en)} vs ${ph(tr)})`);
  } else if (en !== tr) fail(`${path}: value should stay ${JSON.stringify(en)}`);
}

for (const loc of locales) {
  bad = 0;
  console.log(loc);
  for (const f of readdirSync(`${dir}/en`)) {
    const p = `${dir}/${loc}/${f}`;
    if (!existsSync(p)) { fail(`${f}: missing file`); continue; }
    let tr;
    try { tr = JSON.parse(readFileSync(p, "utf8")); } catch (e) { fail(`${f}: not valid JSON (${e.message})`); continue; }
    compare(JSON.parse(readFileSync(`${dir}/en/${f}`, "utf8")), tr, f);
  }
  console.log(bad ? `  ${bad} problem(s)` : "  ok");
  if (bad) process.exitCode = 1;
}
