/** Questions plainly not about the user's own life: about the AI or the app,
 * prompt injection, maths, code, or no words at all. Caught here before the
 * model is called (no tokens, no credit). The model flags subtler ones with
 * off_topic (see READING_SYSTEM_PROMPT). Ported from PR #12 and extended to
 * the app's languages. */
import { dominantScript } from "./language";

const META: RegExp[] = [
  /\b(what|which) (ai |language |llm )?model (are|is|do|does|powers|runs) (you|this|it)\b/i,
  /\bwhat (ai|llm) (are|is) (you|this)\b/i,
  /\bare you (an? )?(ai|bot|robot|human|real person|real|chatgpt|gpt|claude|gemini|llm)\b/i,
  /\bwho (made|built|created|trained|programmed) you\b/i,
  /\b(ignore|forget|disregard) (all |any |the |your )?(previous|prior|above|earlier) (instructions|rules|prompts?)\b/i,
  /\b(system prompt|your instructions|your rules|developer mode|jailbreak)\b/i,
  /(什么|哪个|哪一个|啥|什麼|哪個)(ai)?模型/i,
  /^(请问|請問)?你(到底)?是(谁|誰|什么|什麼|哪个|哪個|人|真人|机器人|機器人|ai|gpt|chatgpt|claude)/i,
  /(谁|誰)(做|开发|開發|训练|訓練|创造|創造)了?你/,
  /(忽略|无视|無視|忘记|忘記)(之前|以上|上面|前面)/,
  /(系统提示|系統提示|提示词|提示詞)/,
  /(どの|何の)(ai)?モデル|あなたは(誰|だれ|人間|ai|ロボット)/i,
  /(무슨|어떤) 모델|(너는|당신은) (누구|사람|ai|로봇)/i,
  /\bqu[eé] modelo (eres|es)\b|\beres (una? )?(ia|robot|humano|persona real)\b/i,
  /\bquel mod[eè]le\b|\bes-tu (une? )?(ia|robot|humain)\b/i,
  /\bwelches modell\b|\bbist du (eine? )?(ki|roboter|mensch)\b/i,
];

export function detectOffTopic(question: string | null | undefined): boolean {
  const q = (question ?? "").trim();
  if (q === "") return false; // no question is a general reading
  if (META.some((r) => r.test(q))) return true;
  // Bare arithmetic ("2+2", "12 * 7 = ?").
  if (/^[\d\s+\-*/x×÷=().,?^%]+$/i.test(q) && /\d/.test(q) && /[+\-*/×÷^%=]/.test(q)) return true;
  // Code.
  if (/(\bfunction\s*\(|=>|\bdef \w+\(|#include|\bconsole\.log|\bSELECT .* FROM\b)/i.test(q)) return true;
  return false;
}

const MESSAGES: Record<string, string> = {
  en: "I'm the world's best tarot AI reader, here to read the cards about your own life. What's on your mind?",
  zh_Hans: "我是世界上最好的塔罗 AI 解读师，只为你自己的生活解读牌面。你心里在想什么呢？",
  zh_Hant: "我是世界上最好的塔羅 AI 解讀師，只為你自己的生活解讀牌面。你心裡在想什麼呢？",
  ja: "私は世界最高のタロットAIリーダーです。あなた自身の人生についてカードを読みます。今、何が気になっていますか？",
  ko: "저는 세계 최고의 타로 AI 리더예요. 당신 자신의 삶에 대해 카드를 읽어 드려요. 지금 무엇이 마음에 걸리나요?",
  es: "Soy el mejor lector de tarot con IA del mundo, y leo las cartas sobre tu propia vida. ¿Qué tienes en mente?",
  pt: "Sou o melhor leitor de tarô com IA do mundo e leio as cartas sobre a sua própria vida. O que está em sua mente?",
  fr: "Je suis le meilleur lecteur de tarot IA au monde, ici pour lire les cartes sur ta propre vie. Qu'est-ce qui te préoccupe ?",
  de: "Ich bin der beste Tarot-KI-Leser der Welt und lege die Karten zu deinem eigenen Leben. Was beschäftigt dich?",
  it: "Sono il miglior lettore di tarocchi IA al mondo e leggo le carte sulla tua vita. Cosa hai in mente?",
  ru: "Я лучший в мире ИИ-таролог и читаю карты о вашей собственной жизни. Что у вас на душе?",
  tr: "Ben dünyanın en iyi tarot yapay zekâ okuyucusuyum; kartları kendi hayatın için okurum. Aklında ne var?",
  id: "Aku pembaca tarot AI terbaik di dunia, siap membaca kartu tentang hidupmu sendiri. Apa yang sedang kamu pikirkan?",
  th: "ฉันคือผู้อ่านไพ่ทาโรต์ AI ที่ดีที่สุดในโลก อ่านไพ่เกี่ยวกับชีวิตของคุณเอง ตอนนี้คุณกำลังคิดถึงเรื่องอะไรอยู่?",
  vi: "Mình là người đọc bài tarot AI giỏi nhất thế giới, đọc bài về chính cuộc sống của bạn. Bạn đang nghĩ gì vậy?",
  ar: "أنا أفضل قارئ تاروت بالذكاء الاصطناعي في العالم، أقرأ الأوراق عن حياتك أنت. ما الذي يشغل بالك؟",
};

/** The fixed redirect in the question's script, else the app language. */
export function offTopicMessage(question: string | null | undefined, lang: string | undefined): string {
  const s = dominantScript(question ?? "");
  const byScript: Record<string, string> = {
    kana: "ja", hangul: "ko", thai: "th", arabic: "ar", cyrillic: "ru",
    cjk: lang === "zh_Hant" ? "zh_Hant" : "zh_Hans",
  };
  const code = byScript[s] ?? (s === "latin" && (lang ?? "en").match(/^(zh|ja|ko|th|ar|ru)/) ? "en" : lang ?? "en");
  return MESSAGES[code] ?? MESSAGES.en!;
}
