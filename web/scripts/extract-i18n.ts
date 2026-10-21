// Writes the English source text that translators work from:
// src/i18n/en/cards.json and src/i18n/en/content.json. Run with
// `npx tsx scripts/extract-i18n.ts` from web/ after the English data changes.
import { writeFileSync } from "node:fs";
import { APP_SPREADS, CARDS, GROUP_ABOUT, SPREADS, cardIds, spreadIds } from "../src/lib/data.ts";
import { TOPICS } from "../src/lib/topics.ts";
import { QUESTION_GUIDES } from "../src/lib/questions.ts";
import { LIFE_PATH } from "../src/lib/numerology.ts";
import { SIGNS } from "../src/lib/zodiac.ts";

const cards = Object.fromEntries(
  cardIds.map((id) => {
    const c = CARDS[id];
    return [id, { name: c.name, keywords: c.keywords, upright: c.upright, reversed: c.reversed, ...(c.k ? { k: c.k } : {}) }];
  }),
);
const content = {
  groups: GROUP_ABOUT,
  spreads: Object.fromEntries(
    spreadIds.map((id) => [id, { name: SPREADS[id].name, positions: SPREADS[id].positions, blurb: APP_SPREADS[id].blurb, source: APP_SPREADS[id].source }]),
  ),
  topics: Object.fromEntries(TOPICS.map((t) => [t.slug, { name: t.name, title: t.title, intro: t.intro, questions: t.questions }])),
  guides: Object.fromEntries(
    QUESTION_GUIDES.map((g) => [g.slug, { question: g.question, answer: g.answer, better: g.better, cards: Object.fromEntries(g.cards), tip: g.tip }]),
  ),
  lifePath: LIFE_PATH,
  signs: Object.fromEntries(SIGNS.map((s) => [s.slug, { name: s.name, dates: s.dates }])),
};
writeFileSync("src/i18n/en/cards.json", JSON.stringify(cards, null, 1) + "\n");
writeFileSync("src/i18n/en/content.json", JSON.stringify(content, null, 1) + "\n");
console.log("wrote", Object.keys(cards).length, "cards");
