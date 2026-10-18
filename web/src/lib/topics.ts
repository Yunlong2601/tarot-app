import type { SpreadId } from "./data.ts";

/** Topic pages. The sample questions are the ones the app suggests on its
 * question screen (`_samples` in app/lib/features/read/ask_screen.dart):
 * keep the two in step. */
export interface Topic {
  slug: string;
  name: string;
  title: string;
  intro: string;
  questions: string[];
  spreads: SpreadId[];
}

export const TOPICS: Topic[] = [
  {
    slug: "love",
    name: "Love",
    title: "Love tarot reading",
    intro:
      "Tarot cannot tell you what someone else thinks or will do. It can help you see what you bring, what you need and what is yours to change.",
    questions: ["Will my ex come back?", "Where does my relationship stand?", "When will I find love?"],
    spreads: ["love_reconnect", "love_connection", "love_ready", "love_bring"],
  },
  {
    slug: "career",
    name: "Career",
    title: "Career tarot reading",
    intro: "Use the cards to look at where you stand at work, what is holding you back and what you could try next.",
    questions: [
      "Should I take this job offer?",
      "What is holding me back at work?",
      "What could I explore next in my career?",
    ],
    spreads: ["career_path", "career_strengths", "three_decision"],
  },
  {
    slug: "daily",
    name: "Daily",
    title: "Daily tarot reading",
    intro: "A card or three to set your focus for the day or the week ahead.",
    questions: ["What do I need to focus on today?", "What energy should I bring to this week?"],
    spreads: ["single", "three"],
  },
  {
    slug: "choices",
    name: "Choices",
    title: "Tarot for decisions",
    intro: "When you are weighing a choice, the cards can lay out the situation, what stands in the way and a way forward.",
    questions: ["Should I move to a new city?", "What do I need to know before I decide?"],
    spreads: ["yes_no", "three_decision", "five_cross"],
  },
  {
    slug: "growth",
    name: "Growth",
    title: "Tarot for self-reflection",
    intro: "Spreads for getting to know yourself: what you think, what you feel and what you keep repeating.",
    questions: ["What lesson do I keep repeating?", "What am I not seeing about myself?"],
    spreads: ["three_hhh", "growth_shadow_light", "horseshoe"],
  },
];
