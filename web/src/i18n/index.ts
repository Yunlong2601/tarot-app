// The site's languages. English lives at the root (/cards); every other
// language lives under its own prefix (/zh-hans/cards). Text comes from
// src/i18n/<locale>/*.json, which mirror the English files exactly
// (scripts/check-i18n.mjs checks this); anything missing falls back to English.
import { BASE } from "../config.ts";
import enCards from "./en/cards.json";
import enContent from "./en/content.json";
import enUi from "./en/ui.json";
import enLearn from "./en/learn.json";
import enContexts from "./en/contexts.json";
import enZodiac from "./en/zodiac.json";
import enWorkspace from "./en/workspace.json";
import enGrowth from "./en/growth.json";
import enJourney from "./en/journey.json";
import enInteractions from "./en/interactions.json";

export const LOCALES = ["en", "zh-hans", "zh-hant", "es", "de", "ja", "fr", "ru"] as const;
export type Locale = (typeof LOCALES)[number];
export const DEFAULT_LOCALE: Locale = "en";

/** Each language's own name, its HTML/hreflang tag and its Open Graph locale. */
export const LOCALE_INFO: Record<Locale, { name: string; tag: string; og: string }> = {
  en: { name: "English", tag: "en", og: "en_US" },
  "zh-hans": { name: "简体中文", tag: "zh-Hans", og: "zh_CN" },
  "zh-hant": { name: "繁體中文", tag: "zh-Hant", og: "zh_TW" },
  es: { name: "Español", tag: "es", og: "es_ES" },
  de: { name: "Deutsch", tag: "de", og: "de_DE" },
  ja: { name: "日本語", tag: "ja", og: "ja_JP" },
  fr: { name: "Français", tag: "fr", og: "fr_FR" },
  ru: { name: "Русский", tag: "ru", og: "ru_RU" },
};

type CardText = (typeof enCards)[keyof typeof enCards];
type Content = typeof enContent;
type Ui = typeof enUi;
type Learn = typeof enLearn;
type Contexts = typeof enContexts;
type Zodiac = typeof enZodiac;

/** The Learn tarot guides, in reading order. */
export const LEARN_SLUGS = Object.keys(enLearn.guides) as (keyof Learn["guides"])[];

const files = import.meta.glob<{ default: unknown }>("./*/*.json", { eager: true });
const load = <T>(loc: Locale, name: string, en: T): T => {
  if (loc === "en") return en;
  const f = files[`./${loc}/${name}.json`]?.default;
  return f ? (merge(en, f) as T) : en;
};
/** English with the translation laid over it, so a gap shows English, not nothing. */
function merge(en: unknown, tr: unknown, path = ""): unknown {
  // Keyword lists for matching questions are each language's own, of any length.
  if (path.startsWith(".recommend.")) return Array.isArray(tr) ? tr : en;
  if (Array.isArray(en)) return Array.isArray(tr) && tr.length === en.length ? en.map((v, i) => merge(v, tr[i], path)) : en;
  if (en && typeof en === "object") {
    const t = (tr && typeof tr === "object" ? tr : {}) as Record<string, unknown>;
    const out: Record<string, unknown> = { ...t };
    for (const [k, v] of Object.entries(en)) out[k] = merge(v, t[k], `${path}.${k}`);
    return out;
  }
  return typeof tr === typeof en && tr !== "" ? tr : en;
}

/** `/{prefix}` for a language: "" for English, "zh-hans/" for Simplified Chinese. */
export const prefix = (loc: Locale) => (loc === DEFAULT_LOCALE ? "" : `${loc}/`);

/** Static paths for a page in every language ([...lang] is undefined for English). */
export const langPaths = () => LOCALES.map((l) => ({ params: { lang: l === DEFAULT_LOCALE ? undefined : l }, props: { lang: l } }));

/** Static paths for a page with its own paths (a card, a spread) in every language. */
export const langPathsFor = <P extends Record<string, string>, R extends Record<string, unknown>>(items: { params: P; props: R }[]) =>
  LOCALES.flatMap((l) => items.map((i) => ({ params: { ...i.params, lang: l === DEFAULT_LOCALE ? undefined : l }, props: { ...i.props, lang: l } })));

/** "a, b and c" in a language (British English: no comma before "and"). */
export const joinAnd = (tag: string, items: string[]) =>
  new Intl.ListFormat(tag === "en" ? "en-GB" : tag, { type: "conjunction" }).format(items);

/** The first sentence of a text, in any of the site's scripts. */
export const firstSentence = (s: string) => {
  const m = s.match(/^.*?(?:[.!?](?=\s)|[。！？])/);
  return m ? m[0] : s;
};

import { fill } from "./fill.ts";
export { fill };

const cache = new Map<Locale, ReturnType<typeof build>>();
export const i18n = (loc: Locale) => cache.get(loc) ?? (cache.set(loc, build(loc)), cache.get(loc)!);

function build(loc: Locale) {
  const ui = load<Ui>(loc, "ui", enUi);
  const cards = load<Record<string, CardText>>(loc, "cards", enCards);
  const content = load<Content>(loc, "content", enContent);
  const learn = load<Learn>(loc, "learn", enLearn);
  const contexts = load<Contexts>(loc, "contexts", enContexts);
  const zodiac = load<Zodiac>(loc, "zodiac", enZodiac);
  const workspace = load<typeof enWorkspace>(loc, "workspace", enWorkspace);
  const growth = load<typeof enGrowth>(loc, "growth", enGrowth);
  const journey = load<typeof enJourney>(loc, "journey", enJourney);
  const interactions = load<typeof enInteractions>(loc, "interactions", enInteractions);
  const rules = new Intl.PluralRules(LOCALE_INFO[loc].tag);
  /** Looks up a dotted key in ui.json ("card.related") and fills placeholders. */
  const t = (key: string, vars?: Record<string, string | number>): string => {
    const v = key.split(".").reduce<unknown>((o, k) => (o as Record<string, unknown>)?.[k], ui);
    if (typeof v === "string") return fill(v, vars);
    // A plural group: { one, other } (some languages add few or many).
    if (v && typeof v === "object" && "other" in v && vars && typeof vars.n === "number") {
      const forms = v as Record<string, string>;
      return fill(forms[rules.select(vars.n)] ?? forms.other!, vars);
    }
    return key;
  };
  /** A list from ui.json, such as keyword lists. */
  const list = (key: string) => key.split(".").reduce<unknown>((o, k) => (o as Record<string, unknown>)?.[k], ui) as string[];
  /** A link to a page in this language; path is the English address ("cards/major-00-fool"). */
  const url = (path = "") => `${BASE}${prefix(loc)}${path}`.replace(/\/$/, "") || "/";
  /** A suit or the Major Arcana by its key ("cups", "major"). */
  const group = (g?: string | null) => t(`groups.${g ?? "major"}`);
  /** An element, planet or sign as the card data names it in English ("Fire", "Venus", "Leo"). */
  const assoc = (a: string) => {
    const sign = (content.signs as Record<string, { name: string }>)[a.toLowerCase()];
    if (sign) return sign.name;
    const k = a.toLowerCase();
    return (ui.elements as Record<string, string>)[k] ?? (ui.planets as Record<string, string>)[k] ?? a;
  };
  /** What the browser tools need to link a card in this language (see lib/cardView.ts). */
  const view = { base: BASE, cards: url("cards"), more: ui.reader.fullMeaning };
  return { loc, tag: LOCALE_INFO[loc].tag, ui, t, list, url, cards, content, learn, contexts, zodiac, workspace, growth, journey, interactions, group, assoc, view };
}
export type I18n = ReturnType<typeof i18n>;
