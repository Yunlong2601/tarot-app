// The card pages for one kind of question: a card in love, at work, as
// someone's feelings, or as a yes or no answer. Text is in
// src/i18n/<language>/contexts.json.
export const CONTEXTS = ["love", "career", "feelings", "yes-or-no"] as const;
export type Context = (typeof CONTEXTS)[number];
/** The key in contexts.json for each page. */
export const CONTEXT_KEY = { love: "love", career: "career", feelings: "feelings", "yes-or-no": "yesno" } as const;
