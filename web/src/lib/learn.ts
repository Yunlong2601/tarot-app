// Guide text marks links as [words](path), with path the English address
// ("cards/major-17-star"), so every language links to its own pages.
export type Piece = string | { text: string; path: string };

/** Splits guide text into plain runs and links. */
export const pieces = (s: string): Piece[] =>
  s.split(/(\[[^\]]+\]\([^)\s]+\))/).filter(Boolean).map((p) => {
    const m = p.match(/^\[([^\]]+)\]\(([^)\s]+)\)$/);
    return m ? { text: m[1]!, path: m[2]! } : p;
  });

/** The same text without link marks, for meta tags, schema data and llms.txt. */
export const plain = (s: string) => s.replace(/\[([^\]]+)\]\([^)\s]+\)/g, "$1");
