import type { CardId } from "./data.ts";

/** Question guides: one page per question people often bring to tarot. Each
 * page suggests the spread the app would pick for that wording
 * (`recommendSpread`), so a guide and the home page's ask box always agree. */
export interface QuestionGuide {
  slug: string;
  question: string;
  topic: string;
  /** What the cards can and cannot do with this question. */
  answer: string;
  /** Ways to word it that give a more useful reading. */
  better: string[];
  /** Cards worth noticing if they turn up, with what they may point to. */
  cards: [CardId, string][];
  tip: string;
}

export const QUESTION_GUIDES: QuestionGuide[] = [
  {
    slug: "does-he-love-me",
    question: "Does he love me?",
    topic: "love",
    answer:
      "Tarot cannot see into another person's heart, and no card proves what someone feels. What a reading can do is show how the connection looks from where you stand: what you are giving, what you are getting back and what you are hoping for.",
    better: [
      "How do I feel in this relationship?",
      "What is the connection between us right now?",
      "What do I need from them that I am not getting?",
    ],
    cards: [
      ["cups_two", "A mutual bond: both people are meeting each other halfway."],
      ["major_06_lovers", "A real choice about values and closeness, not only attraction."],
      ["cups_four", "Something offered is being missed or turned away."],
      ["swords_three", "Hurt that needs to be named before things can move on."],
    ],
    tip: "If you find yourself drawing again and again for the same answer, the reading is telling you about your own worry. That is worth listening to.",
  },
  {
    slug: "will-my-ex-come-back",
    question: "Will my ex come back?",
    topic: "love",
    answer:
      "No reading can promise that someone will return. A reconnection spread looks at what ended the relationship, what has changed since and what you would need for it to be different this time, so you can decide whether hoping is good for you.",
    better: [
      "What ended our relationship?",
      "What has changed in me since we broke up?",
      "What would need to be different if we got back together?",
    ],
    cards: [
      ["cups_six", "Nostalgia and the pull of the past, for better or worse."],
      ["swords_ten", "A clear ending: this chapter is finished."],
      ["major_20_judgement", "A reckoning, and the chance to start again with open eyes."],
      ["cups_eight", "Walking away from something that no longer fills you."],
    ],
    tip: "Ask what you want, not only what they will do. The first is something you can act on.",
  },
  {
    slug: "will-i-meet-someone-new",
    question: "Will I meet someone new?",
    topic: "love",
    answer:
      "Tarot cannot give you a date or a name. A reading for someone who is single looks at whether you are ready, what you are looking for and what may be holding you back, which tends to matter more than timing.",
    better: [
      "Am I ready for a new relationship?",
      "What am I really looking for in a partner?",
      "What is holding me back from meeting someone?",
    ],
    cards: [
      ["cups_ace", "A new feeling, or an open heart ready to receive."],
      ["cups_page", "A light, curious start: a message, a flirt, a first step."],
      ["swords_eight", "Feeling trapped by beliefs that are not as fixed as they seem."],
      ["major_17_star", "Hope returning after a hard time."],
    ],
    tip: "Read the cards about yourself first. They usually say more about readiness than about who is coming.",
  },
  {
    slug: "should-i-stay-in-my-relationship",
    question: "Should I stay in my relationship?",
    topic: "love",
    answer:
      "This is your decision, and the cards should not make it for you. A relationship spread can lay out where things stand between you, what each of you brings and what is not being said, so the choice is clearer.",
    better: [
      "Where does my relationship stand right now?",
      "What am I not saying to my partner?",
      "What would help this relationship grow?",
    ],
    cards: [
      ["cups_ten", "Lasting contentment and a shared sense of home."],
      ["swords_two", "A stalemate: avoiding a decision you already sense."],
      ["cups_five", "Grief over what was lost, while something remains."],
      ["major_14_temperance", "Patience and balance: working things out step by step."],
    ],
    tip: "If you or anyone is unsafe, talk to someone you trust or a local support service before any reading.",
  },
  {
    slug: "should-i-change-jobs",
    question: "Should I change jobs?",
    topic: "career",
    answer:
      "Tarot cannot see a job market or an offer letter. A career spread looks at where you stand now, what is holding you back and what you could try next, so you can weigh the move with a clearer head.",
    better: [
      "What is making me want to leave my job?",
      "What could I explore next in my career?",
      "What would I need to make a change work?",
    ],
    cards: [
      ["pentacles_eight", "Skill and steady work: growth may come from getting better where you are."],
      ["wands_three", "Looking ahead: plans are underway and ready to expand."],
      ["cups_eight", "Leaving behind something that no longer fills you."],
      ["pentacles_four", "Holding on tightly to security, perhaps too tightly."],
    ],
    tip: "Pair the reading with practical steps: talk to people in the role you want and look at the numbers.",
  },
  {
    slug: "will-i-get-the-job",
    question: "Will I get the job?",
    topic: "career",
    answer:
      "The decision belongs to the people hiring, and no card knows it. A reading can show how you are coming across, what you bring and what to focus on before or after the interview, which is the part you can still change.",
    better: [
      "What strengths should I show in this interview?",
      "What could hold me back in this application?",
      "What do I need to know about this role?",
    ],
    cards: [
      ["wands_six", "Recognition and a public win."],
      ["pentacles_three", "Teamwork and being valued for your skill."],
      ["swords_seven", "Something not being said openly: check the details."],
      ["major_01_magician", "You have the tools you need. Use them."],
    ],
    tip: "Whatever the cards say, prepare as if it is up to you. Much of it is.",
  },
  {
    slug: "should-i-move-to-a-new-city",
    question: "Should I move to a new city?",
    topic: "choices",
    answer:
      "A yes or no draw can be a quick check-in, but a move is a big choice with many parts. Use a short draw to see how you feel about it, then a decision spread to look at the options side by side.",
    better: [
      "What do I need to know before I decide to move?",
      "What would I gain and what would I give up?",
      "What is drawing me to this place?",
    ],
    cards: [
      ["major_00_fool", "A leap into the unknown, with trust."],
      ["swords_six", "Moving on to calmer water, a transition that helps."],
      ["pentacles_ten", "Roots, family and long-term security."],
      ["wands_four", "Celebration and a sense of home."],
    ],
    tip: "Ask about each option separately and compare. One reading for both places can blur them together.",
  },
  {
    slug: "what-do-i-need-to-know-before-i-decide",
    question: "What do I need to know before I decide?",
    topic: "choices",
    answer:
      "This is one of the best questions to bring to tarot, because it asks for perspective rather than a verdict. A decision spread looks at the situation, what stands in the way and the way forward, and leaves the choice with you.",
    better: [
      "What am I not seeing about this choice?",
      "What does each option ask of me?",
      "What matters most to me here?",
    ],
    cards: [
      ["swords_two", "Holding off a choice: it may be time to look."],
      ["major_11_justice", "Weighing things fairly, and living with the result."],
      ["cups_seven", "Many options and some illusions: sort what is real."],
      ["major_02_high_priestess", "Quiet knowing: trust what you already sense."],
    ],
    tip: "Write down your choice before you draw. Notice how you feel when a card seems to agree or disagree.",
  },
  {
    slug: "why-do-i-feel-stuck",
    question: "Why do I feel stuck?",
    topic: "growth",
    answer:
      "Feeling stuck is a good reason to sit with the cards. A self-reflection spread looks at what you think, what you feel and what you are doing, and where those three pull against each other.",
    better: [
      "What am I not seeing about myself right now?",
      "What lesson do I keep repeating?",
      "What small step would help me move?",
    ],
    cards: [
      ["major_12_hanged_man", "A pause with a purpose: seeing things from a new angle."],
      ["swords_eight", "Feeling trapped by beliefs that are not as fixed as they seem."],
      ["major_15_devil", "A habit or attachment that holds you more than you hold it."],
      ["wands_ace", "A spark of energy for a fresh start."],
    ],
    tip: "If feeling stuck lasts or gets heavy, talking to a friend or a professional helps more than any spread.",
  },
];
