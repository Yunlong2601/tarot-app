/** Languages the app can ask for. Codes match the app's i18n codes. */
export const LANGUAGES: Record<string, string> = {
  en: "English",
  zh_Hans: "Simplified Chinese",
  zh_Hant: "Traditional Chinese",
  ja: "Japanese",
  ko: "Korean",
  es: "Spanish",
  pt: "Portuguese",
  fr: "French",
  de: "German",
  it: "Italian",
  ru: "Russian",
  tr: "Turkish",
  id: "Indonesian",
  th: "Thai",
  vi: "Vietnamese",
  ar: "Arabic",
};

export const parseLang = (v: unknown): string =>
  typeof v === "string" && Object.hasOwn(LANGUAGES, v) ? v : "en";

/** Rough script of a text: enough to catch "Chinese question, English reading". */
export type Script = "cjk" | "hangul" | "kana" | "thai" | "arabic" | "cyrillic" | "latin" | "none";

export function dominantScript(text: string): Script {
  const counts: Record<Script, number> = { cjk: 0, hangul: 0, kana: 0, thai: 0, arabic: 0, cyrillic: 0, latin: 0, none: 0 };
  for (const ch of text) {
    const c = ch.codePointAt(0)!;
    if (c >= 0x3040 && c <= 0x30ff) counts.kana++;
    else if ((c >= 0x4e00 && c <= 0x9fff) || (c >= 0x3400 && c <= 0x4dbf)) counts.cjk++;
    else if (c >= 0xac00 && c <= 0xd7af) counts.hangul++;
    else if (c >= 0x0e00 && c <= 0x0e7f) counts.thai++;
    else if (c >= 0x0600 && c <= 0x06ff) counts.arabic++;
    else if (c >= 0x0400 && c <= 0x04ff) counts.cyrillic++;
    else if ((c >= 0x41 && c <= 0x5a) || (c >= 0x61 && c <= 0x7a) || (c >= 0xc0 && c <= 0x24f)) counts.latin++;
  }
  // Japanese mixes kanji and kana: any real amount of kana means Japanese.
  if (counts.kana >= 2) return "kana";
  let best: Script = "none";
  let n = 0;
  for (const k of Object.keys(counts) as Script[]) if (counts[k] > n) { best = k; n = counts[k]; }
  return n < 2 ? "none" : best;
}

export const scriptOfLang = (lang: string): Script => {
  switch (lang) {
    case "zh_Hans": case "zh_Hant": return "cjk";
    case "ja": return "kana";
    case "ko": return "hangul";
    case "th": return "thai";
    case "ar": return "arabic";
    case "ru": return "cyrillic";
    default: return "latin";
  }
};

/** The language the reply must be in: the question's own script wins over the
 * app setting (someone with an English phone asking in Chinese gets Chinese). */
export function replyLanguage(lang: string, question: string | null): { name: string; script: Script } {
  const appScript = scriptOfLang(lang);
  const q = question ? dominantScript(question) : "none";
  // Japanese questions can be all kanji: a Japanese app keeps Japanese.
  if (q === "none" || q === appScript || (appScript === "kana" && q === "cjk")) {
    return { name: LANGUAGES[lang]!, script: appScript };
  }
  const byScript: Record<string, string> = {
    cjk: lang === "zh_Hant" ? "Traditional Chinese" : "Chinese (use the same script as the question)",
    kana: "Japanese", hangul: "Korean", thai: "Thai", arabic: "Arabic", cyrillic: "Russian",
    latin: "the language of the question",
  };
  return { name: byScript[q]!, script: q };
}
