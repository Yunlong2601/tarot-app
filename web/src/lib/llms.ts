// llms.txt and llms-full.txt: the site in plain Markdown for AI assistants and
// answer engines (https://llmstxt.org). Built from the same English text as the
// pages, so they never disagree.
import { SITE_URL } from "../config.ts";
import { i18n, joinAnd, LEARN_SLUGS, LOCALES, LOCALE_INFO, prefix } from "../i18n/index.ts";
import { plain } from "./learn.ts";
import { BIRTH } from "./birth.ts";
import { SIGNS } from "./zodiac.ts";
import { CARDS, cardIds, slug, spreadIds, type CardId } from "./data.ts";
import { QUESTION_GUIDES } from "./questions.ts";
import { TOPICS } from "./topics.ts";

const L = i18n("en");
const { t } = L;
const link = (path = "") => new URL(path, SITE_URL).href.replace(/\/$/, "") || SITE_URL;
const TOOLS = ["yes-no", "daily-card", "weekly-draw", "random-card", "combinations", "elements", "birth-card", "year-card", "love-compatibility", "zodiac-tarot", "life-path", "which-card-are-you", "reading-sheet"];
const GROUPS = ["major", "wands", "cups", "swords", "pentacles"] as const;
const inGroup = (g: (typeof GROUPS)[number]) => cardIds.filter((id) => (g === "major" ? CARDS[id].arcana === "major" : CARDS[id].suit === g));
const ctx = (id: CardId) => L.contexts.cards[id as keyof typeof L.contexts.cards];
const keywords = (id: CardId) => joinAnd("en", L.cards[id]!.keywords);

function header() {
  return [
    "# ShenTarot",
    "",
    `> ${t("about.lead")} ${L.ui.about.sections[4]!.text}`,
    "",
    `ShenTarot is made by Shenetic, Singapore. Card meanings cover all 78 cards of the Rider-Waite-Smith tarot deck, upright and reversed, and are the same ones the app's readings use. The site is also available in ${LOCALES.filter((l) => l !== "en").map((l) => `${LOCALE_INFO[l].name} (${link(prefix(l))})`).join(", ")}.`,
    "",
  ];
}

export function llmsTxt() {
  const card = (id: CardId) => `- [${L.cards[id]!.name}](${link(`cards/${slug(id)}`)}): ${keywords(id)}. ${L.cards[id]!.k?.essence ?? L.cards[id]!.upright}`;
  return [
    ...header(),
    "## About",
    "",
    `- [About ShenTarot](${link("about")}): ${t("about.description")}`,
    `- [All card meanings](${link("cards")}): ${t("cards.description")}`,
    `- [Full card meanings in one file](${link("llms-full.txt")}): every card's upright, reversed, love and work meaning.`,
    "",
    ...GROUPS.flatMap((g) => [`## ${L.group(g)}`, "", ...inGroup(g).map(card), ""]),
    "## Spreads",
    "",
    ...spreadIds.map((id) => {
      const s = L.content.spreads[id as keyof typeof L.content.spreads];
      return `- [${s.name}](${link(`spreads/${slug(id)}`)}): ${t("cardCount", { n: s.positions.length })}. ${s.blurb}`;
    }),
    "",
    "## Readings by topic",
    "",
    ...TOPICS.map((tp) => {
      const c = L.content.topics[tp.slug as keyof typeof L.content.topics];
      return `- [${c.title}](${link(`topics/${tp.slug}`)}): ${c.intro}`;
    }),
    "",
    "## Questions people ask tarot",
    "",
    ...QUESTION_GUIDES.map((g) => {
      const c = L.content.guides[g.slug as keyof typeof L.content.guides];
      return `- [${c.question}](${link(`questions/${g.slug}`)}): ${c.answer}`;
    }),
    "",
    "## Learn tarot",
    "",
    ...LEARN_SLUGS.map((s) => `- [${L.learn.guides[s].h1}](${link(`learn/${s}`)}): ${L.learn.guides[s].answer}`),
    "",
    "## Zodiac signs and their tarot cards",
    "",
    ...SIGNS.map((s) => `- [${L.content.signs[s.slug as keyof typeof L.content.signs].name} tarot card](${link(`zodiac/${s.slug}`)}): ${L.cards[s.major]!.name}. ${L.zodiac.signs[s.slug as keyof typeof L.zodiac.signs].intro.split(". ")[0]}.`),
    "",
    "## Birth cards",
    "",
    ...BIRTH.map((id) => `- [${L.cards[id]!.name} as a birth card](${link(`birth-cards/${slug(id)}`)})`),
    "",
    "## Free tools",
    "",
    ...TOOLS.map((k) => `- [${t(`tools.list.${k}.title`)}](${link(`tools/${k}`)}): ${t(`tools.list.${k}.text`)}`),
    "",
    "## Optional",
    "",
    `- [Privacy policy](${link("privacy")})`,
    `- [Terms of use](${link("terms")})`,
    "",
  ].join("\n");
}

export function llmsFullTxt() {
  const card = (id: CardId) => {
    const tr = L.cards[id]!;
    const k = tr.k;
    const c = CARDS[id];
    const facts = [c.element && `Element: ${c.element}.`, c.association && `Traditional association: ${c.association}.`].filter(Boolean).join(" ");
    return [
      `### ${tr.name}`,
      "",
      `Source: ${link(`cards/${slug(id)}`)}`,
      "",
      `${t("card.answer", { name: tr.name, keywords: keywords(id) })}${k ? ` ${k.essence}` : ""}${facts ? ` ${facts}` : ""}`,
      "",
      ...(k
        ? [
            `What it shows: ${k.imagery} ${k.why}`,
            "",
            `Upright: ${k.upright.core} Light side: ${k.upright.light}. Shadow side: ${k.upright.shadow}.`,
            "",
            `In love: ${k.upright.love}`,
            "",
            `At work: ${k.upright.work}`,
            "",
            `Reversed: ${k.reversed.core} ${k.reversed.modes.join(" ")}`,
            "",
            `Questions to reflect on: ${k.upright.question} Reversed: ${k.reversed.question}`,
            "",
            `In love: ${ctx(id).love.up} Reversed: ${ctx(id).love.rev}`,
            "",
            `Career and money: ${ctx(id).career.up} Reversed: ${ctx(id).career.rev}`,
            "",
            `As feelings: ${ctx(id).feelings.up} Reversed: ${ctx(id).feelings.rev}`,
            "",
            `Yes or no: ${ctx(id).yesno.up} Reversed: ${ctx(id).yesno.rev}`,
            "",
            `Advice: ${ctx(id).advice.up} Reversed: ${ctx(id).advice.rev}`,
          ]
        : [`Upright: ${tr.upright}`, "", `Reversed: ${tr.reversed}`]),
      "",
    ];
  };
  return [
    ...header(),
    `Card images: Rider-Waite-Smith deck (1909), public domain. Shorter index: ${link("llms.txt")}`,
    "",
    ...GROUPS.flatMap((g) => [`## ${L.group(g)}`, "", ...inGroup(g).flatMap(card)]),
    "## Learn tarot",
    "",
    ...LEARN_SLUGS.flatMap((s) => {
      const g = L.learn.guides[s];
      return [
        `### ${g.h1}`,
        "",
        `Source: ${link(`learn/${s}`)}`,
        "",
        g.answer,
        "",
        ...g.sections.flatMap((x) => [`#### ${x.h}`, "", ...x.p.flatMap((p) => [plain(p), ""])]),
        ...g.faq.flatMap((f) => [`Q: ${f.q}`, `A: ${plain(f.a)}`, ""]),
      ];
    }),
  ].join("\n");
}
