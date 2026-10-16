import { describe, expect, it } from "vitest";
import { CARDS } from "../src/cards";
import { CRISIS_MESSAGE, POSITIONS, cardBlock, detectCrisis, restrictedTopic, spreadFacts } from "../src/knowledge";
import {
  READING_SYSTEM_PROMPT, buildReadingMessage, fallbackReading, hitsBannedClaim, parseModelReply, renderReading,
} from "../src/reading";
import type { ReadingRequest } from "../src/validate";

const req = (ids: [string, boolean][], spread: ReadingRequest["spread"], question: string | null = null): ReadingRequest => ({
  spread, question, impression: null, cards: ids.map(([id, reversed]) => ({ id, reversed })),
});

describe("card knowledge sent to the model", () => {
  it("a reversed card gets reversed material, not the upright text (the old bug)", () => {
    const up = cardBlock({ id: "major_16_tower", reversed: false }, 0, "The card");
    const rev = cardBlock({ id: "major_16_tower", reversed: true }, 0, "The card");
    expect(up).toContain("core:");
    expect(up).not.toContain("modes:");
    expect(rev).toContain("modes:");
    expect(rev).toContain("core (reversed):");
    expect(rev).not.toContain("light:");
    expect(rev).toContain("reversed (Major 16, Mars)");
    expect(up).toContain("image:");
  });

  it("minor cards send orientation-specific meaning, suit and number", () => {
    const rev = cardBlock({ id: "swords_five", reversed: true }, 2, "Where it stands");
    expect(rev).toContain("core (reversed): " + CARDS["swords_five"]!.k!.reversed.core);
    expect(rev).toContain("swords 5, Air");
  });

  it("every court card has rich knowledge and is labelled a court", () => {
    const courts = Object.entries(CARDS).filter(([id]) => /_(page|knight|queen|king)$/.test(id));
    expect(courts).toHaveLength(16);
    for (const [id, c] of courts) {
      expect(c.k, id).toBeTruthy();
      expect(c.k!.upright.core.length, id).toBeGreaterThan(20);
      expect(c.k!.reversed.modes, id).toHaveLength(3);
    }
    expect(cardBlock({ id: "cups_queen", reversed: false }, 0, "x")).toContain("cups court");
  });

  it("every major has rich knowledge with all fields", () => {
    const majors = Object.entries(CARDS).filter(([, c]) => c.arcana === "major");
    expect(majors).toHaveLength(22);
    for (const [id, c] of majors) {
      expect(c.k, id).toBeTruthy();
      for (const f of [c.k!.essence, c.k!.imagery, c.k!.why, c.k!.upright.core, c.k!.upright.question, c.k!.reversed.core, c.k!.reversed.question]) {
        expect(f.length, id).toBeGreaterThan(10);
      }
      expect(c.k!.reversed.modes, id).toHaveLength(3);
      // no directives or predictions in the wording
      expect(JSON.stringify(c.k), id).not.toMatch(/\byou will\b/i);
    }
  });
});

describe("spread facts are computed in code", () => {
  it("counts majors, suits, courts, reversals, repeats and element", () => {
    const f = spreadFacts([
      { id: "major_16_tower", reversed: true }, { id: "swords_five", reversed: false },
      { id: "cups_five", reversed: true }, { id: "swords_two", reversed: false }, { id: "swords_king", reversed: false },
    ]);
    expect(f).toContain("majors: 1 of 5");
    expect(f).toContain("swords 3");
    expect(f).toContain("courts: 1");
    expect(f).toContain("reversed: 2 of 5 (positions 1, 3)");
    expect(f).toContain("two or more 5s (positions 2, 3)");
    expect(f).toContain("dominant element: Air");
  });
  it("celtic positions are relabelled", () => {
    expect(POSITIONS.celtic[4]).toBe("Aim");
    expect(POSITIONS.celtic[9]).toBe("Direction");
    expect(POSITIONS.celtic).toHaveLength(10);
  });
});

describe("prompt", () => {
  it("states the hard limits and treats user tags as untrusted", () => {
    expect(READING_SYSTEM_PROMPT).toMatch(/untrusted/);
    expect(READING_SYSTEM_PROMPT).toMatch(/never claim what a third party/i);
    expect(READING_SYSTEM_PROMPT).toMatch(/does not mean physical death/i);
  });
  it("hints a restricted topic without refusing", () => {
    const m = buildReadingMessage(req([["major_00_fool", false]], "single", "Should I invest my savings in crypto?"));
    expect(m).toMatch(/restricted topic.*financial/i);
    expect(restrictedTopic("what should I cook tonight")).toBeNull();
  });
});

describe("model reply handling", () => {
  const r = req([["major_00_fool", false], ["cups_ace", true], ["swords_ten", false]], "three", "What should I focus on?");
  const good = {
    cards: [
      { position: "x", card: "The Fool", orientation: "upright", reading: "A beginning you can take lightly.", why: "Zero is potential." },
      { position: "x", card: "Ace of Cups", orientation: "reversed", reading: "Feeling held back.", why: "Aces are seeds." },
      { position: "x", card: "Ten of Swords", orientation: "upright", reading: "A painful chapter closing.", why: "Ten completes." },
    ],
    overview: "A story of starting after something ends.", reflection_question: "What am I ready to begin?",
    small_step: "Write down one thing you would try.", declined_topic: null, crisis: false,
  };
  it("accepts a valid reply and renders it with positions from the server", () => {
    const s = parseModelReply("```json\n" + JSON.stringify(good) + "\n```", r)!;
    expect(s).toBeTruthy();
    const text = renderReading(s);
    expect(text).toContain("Where it began: The Fool");
    expect(text).toContain("Ace of Cups (reversed)");
    expect(text).toContain("A small step");
  });
  it("rejects wrong card names, wrong orientation, wrong count and oversized fields", () => {
    const bad1 = { ...good, cards: [{ ...good.cards[0], card: "The Magician" }, good.cards[1], good.cards[2]] };
    const bad2 = { ...good, cards: [good.cards[0], { ...good.cards[1], orientation: "upright" }, good.cards[2]] };
    const bad3 = { ...good, cards: good.cards.slice(0, 2) };
    const bad4 = { ...good, overview: "x".repeat(2000) };
    for (const b of [bad1, bad2, bad3, bad4]) expect(parseModelReply(JSON.stringify(b), r)).toBeNull();
    expect(parseModelReply("not json", r)).toBeNull();
  });
  it("banned claims are caught and the fallback is built from stored text only", () => {
    expect(hitsBannedClaim("You will get pregnant soon")).toBe(true);
    expect(hitsBannedClaim("you are pregnant")).toBe(true);
    expect(hitsBannedClaim("He is thinking of you")).toBe(true);
    expect(hitsBannedClaim("You should leave him")).toBe(true);
    expect(hitsBannedClaim("This card invites you to notice what has ended.")).toBe(false);
    const fb = fallbackReading(r);
    expect(fb).toContain("Where it began: The Fool");
    expect(fb).toContain("(reversed)");
    expect(hitsBannedClaim(fb)).toBe(false);
  });
});

describe("crisis pre-check", () => {
  it("catches common phrasings, accents, spacing tricks", () => {
    for (const t of ["I want to die", "thinking about suicide", "I might hurt myself", "He hits me", "no reason to live",
      "I w​ant to d​ie"]) {
      expect(detectCrisis(t), t).toBe(true);
    }
  });
  it("does not trigger on ordinary questions", () => {
    for (const t of ["What should I focus on this week?", "How do I kill a bad habit?", "Will my project succeed?"]) {
      expect(detectCrisis(t), t).toBe(false);
    }
    expect(CRISIS_MESSAGE).toMatch(/988/);
  });
});

import { SPREADS, SPREAD_IDS, isFreeSpread, spreadSize } from "../src/spreads";

describe("spread catalog", () => {
  it("every spread has 1 to 10 unique positions and a purpose", () => {
    expect(SPREAD_IDS.length).toBeGreaterThanOrEqual(14);
    for (const id of SPREAD_IDS) {
      const d = SPREADS[id];
      expect(spreadSize(id), id).toBeGreaterThanOrEqual(1);
      expect(spreadSize(id), id).toBeLessThanOrEqual(10);
      expect(new Set(d.positions).size, id).toBe(d.positions.length);
      expect(d.purpose.length, id).toBeGreaterThan(20);
    }
  });
  it("no position claims to read another person's mind", () => {
    for (const id of SPREAD_IDS) {
      for (const p of SPREADS[id].positions) {
        expect(p, `${id}: ${p}`).not.toMatch(/\b(he|she|they|their|his|her|other person|ex)\b/i);
      }
    }
  });
  it("every spread is free within the daily limit", () => {
    expect(SPREAD_IDS.filter(isFreeSpread)).toEqual(SPREAD_IDS);
  });
  it("the prompt names the spread and its purpose", () => {
    const m = buildReadingMessage({
      spread: "love_reconnect", question: null, impression: null,
      cards: ["major_00_fool", "major_01_magician", "major_02_high_priestess", "major_03_empress", "major_04_emperor", "major_05_hierophant", "major_06_lovers"].map((id) => ({ id, reversed: false })),
    });
    expect(m).toContain("Healing & Reconnection");
    expect(m).toMatch(/never predict whether anyone returns/i);
    expect(m).toContain("What I am still carrying");
  });
});
