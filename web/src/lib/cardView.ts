import type { MeaningCard } from "./data.ts";

/** Builds the result cards the free tools show, in the browser. */
export const el = <K extends keyof HTMLElementTagNameMap>(tag: K, cls?: string, text?: string) => {
  const e = document.createElement(tag);
  if (cls) e.className = cls;
  if (text) e.textContent = text;
  return e;
};

/** Where card pictures and pages live, and the "Full meaning" link text, in the page's language. */
export type View = { base: string; cards: string; more: string };

/** A card with its picture, name, keywords and a line of meaning. */
export function cardResult(c: MeaningCard, view: View, label: string, text: string) {
  const base = view.base;
  const box = el("div", "result-card panel");
  const link = el("a");
  link.href = `${view.cards}/${c.slug}`;
  const img = el("img");
  img.src = `${base}cards/art/${c.id}.jpg`;
  img.alt = c.name;
  img.width = 300;
  img.height = 514;
  link.append(img);
  const body = el("div");
  body.append(el("p", "pos", label), el("h3", "", c.name), el("p", "kw", c.keywords.join(" · ")));
  if (text) body.append(el("p", "", text));
  const more = el("a", "link-arrow", view.more);
  more.href = link.href;
  body.append(more);
  box.append(link, body);
  return box;
}

export const readConfig = <T>(root: ParentNode) =>
  JSON.parse(root.querySelector("[data-config]")!.textContent!) as T;
