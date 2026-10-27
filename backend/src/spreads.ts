/** The spread catalog. Keep in sync with app/lib/data/spreads.dart (same ids,
 * same position labels). Positions are about the reader's own situation, never
 * about what another person thinks or feels. */
export interface SpreadDef {
  name: string;
  category: "love" | "career" | "growth" | "classics";
  /** What the spread is for, passed to the model as context. */
  purpose: string;
  positions: string[];
}

export const SPREADS = {
  single: {
    name: "One-Card Reading", category: "classics",
    purpose: "One clearly framed question; a single theme to notice.",
    positions: ["The card"],
  },
  three: {
    name: "Past, Present, Future", category: "classics",
    purpose: "A concise story of how a situation developed and where it is heading if the pattern continues.",
    positions: ["Where it began", "Where it stands", "Where it is heading"],
  },
  three_decision: {
    name: "Situation, Challenge, Way Forward", category: "classics",
    purpose: "Framing a decision: what is going on, what is in the way, and a way to move.",
    positions: ["The situation", "The challenge", "A way forward"],
  },
  five_cross: {
    name: "Five-Card Cross", category: "classics",
    purpose: "Looking at one clearly stated matter from five sides.",
    positions: ["What is behind it", "The matter itself", "What is ahead", "What I am reaching for", "What grounds me"],
  },
  horseshoe: {
    name: "Seven-Card Horseshoe", category: "classics",
    purpose: "A focused situation with several interacting influences.",
    positions: ["Past", "Present", "Hidden influences", "Obstacles", "Influences around me", "Advice", "Direction if the pattern continues"],
  },
  celtic: {
    name: "Celtic Cross", category: "classics",
    purpose: "A complex situation that needs a full map of influences.",
    positions: [
      "The heart of it", "What crosses it", "Foundation", "Recent past", "Aim",
      "Near horizon", "You", "Surroundings", "Hopes and fears", "Direction",
    ],
  },
  love_connection: {
    name: "Love & Relationship", category: "love",
    purpose: "Reflecting on the user's own part in a relationship. Never what the other person thinks or feels.",
    positions: ["What I bring", "The connection itself", "What it asks of me"],
  },
  love_bring: {
    name: "What I Bring to This Connection", category: "love",
    purpose: "Self-reflection about what the user brings, needs and may be avoiding in a connection.",
    positions: ["What I bring", "What I need", "What I may be avoiding"],
  },
  love_reconnect: {
    name: "Healing & Reconnection", category: "love",
    purpose: "Reflecting on a past relationship from the user's side: what happened inside them and what they can change. Never predict whether anyone returns and never advise contacting anyone.",
    positions: [
      "What ended", "What I am still carrying", "What I need to understand", "What I can change",
      "What is outside my control", "What healing could look like", "A next step for me",
    ],
  },
  love_ready: {
    name: "Single & New Love", category: "love",
    purpose: "Reflecting on readiness for new love, from the user's side only.",
    positions: [
      "How I feel about love now", "What I carry from the past", "What I truly want",
      "What may be holding me back", "What I can offer", "What openness would look like", "A step toward it",
    ],
  },
  career_path: {
    name: "Career Path", category: "career",
    purpose: "Reflecting on work direction. No predictions about jobs or money.",
    positions: ["Where I am", "What holds me back", "What to explore next"],
  },
  career_strengths: {
    name: "Strengths & Growth", category: "career",
    purpose: "Reflecting on strengths and what to develop at work. No predictions about jobs or money.",
    positions: ["My strength", "My challenge", "What I can learn", "What supports me", "A next step"],
  },
  three_hhh: {
    name: "Head, Heart, Hands", category: "growth",
    purpose: "Inner conflict or a decision: what I think, what I feel, what I will do.",
    positions: ["What I think", "What I feel", "What I will do"],
  },
  growth_shadow_light: {
    name: "Shadow & Light", category: "growth",
    purpose: "Self-understanding: a strength, a hidden side, and how to bring them together.",
    positions: ["My light", "My shadow", "Bringing them together"],
  },
  yes_no: {
    name: "Yes or No", category: "classics",
    purpose: "A quick yes-or-no question. Start with a gentle leaning in plain words (leans yes, leans no, or not clear yet) taken from the card, then say why and what would help. It is a leaning to reflect on, never a certain answer, and the choice stays the user's. For health, legal, money or safety questions give no leaning, only reflection.",
    positions: ["The leaning"],
  },
  new_moon: {
    name: "New Moon Intentions", category: "growth",
    purpose: "A New Moon intention ritual: what the user can release, what they want to plant, and one small first step. Reflective and practical; the moon is a moment for reflection, not a cause of events.",
    positions: ["What to release", "What to plant", "A first step"],
  },
  full_moon: {
    name: "Full Moon Reflection", category: "growth",
    purpose: "A Full Moon reflection: what has grown since the last new moon, what the user can let go of, and what to celebrate. Warm and grounded; the moon is a moment for reflection, not a cause of events.",
    positions: ["What has grown", "What to let go", "What to celebrate"],
  },
} as const satisfies Record<string, SpreadDef>;

export type Spread = keyof typeof SPREADS;

export const SPREAD_IDS = Object.keys(SPREADS) as Spread[];
export const spreadSize = (s: Spread): number => SPREADS[s].positions.length;
export const isSpread = (v: unknown): v is Spread => typeof v === "string" && Object.hasOwn(SPREADS, v);

/** Spreads of up to 3 cards are free within the daily limit; the 5, 7 and
 * 10-card spreads are Premium, with one free trial reading per install
 * (owner decision 2026-10-17). This is the one place to change that. */
export const FREE_SPREAD_MAX_CARDS = 3;
export const isFreeSpread = (s: Spread): boolean => spreadSize(s) <= FREE_SPREAD_MAX_CARDS;
