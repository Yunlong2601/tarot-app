import '../../data/spreads.dart';

/// A gentle, offline check of how a question is worded. Returns a short
/// suggestion, or null when the question looks fine. Tarot works best as
/// reflection, so we nudge away from yes/no, timing, and mind-reading
/// questions. It never blocks; the user can ask anything.
String? questionNudge(String question) {
  if (looksOffTopic(question)) return offTopicNudge;
  final q = question.trim().toLowerCase();
  if (q.length < 8) return null;
  final mindReading = RegExp(
    r"\b(what is|what's|what does) (he|she|they|my (ex|boss|partner|crush))\b.*\b(think|feel|want|thinking|feeling)\b|"
    r"\bdoes (he|she|they) (love|like|miss|want)\b",
  );
  if (mindReading.hasMatch(q)) {
    return 'Cards cannot tell what someone else thinks or feels. Try asking about your own side: "What do I need to understand about this?"';
  }
  if (RegExp(r'\bwhen (will|am i going to|do i)\b').hasMatch(q)) {
    return 'Timing is hard for the cards. Try: "What can I do to move this forward?"';
  }
  if (looksYesNo(q)) {
    return 'This reads as a yes or no question: the Yes or No spread shows which way the cards lean. For a fuller reading, try "What would help me with this?"';
  }
  return null;
}

const offTopicNudge =
    'The cards read your own life, not questions about the app, AI, maths '
    'or code. Try: "What do I need to know about my week?"';

/// Questions that are not about the user's life: about the AI or the app,
/// prompt injection, maths, code, or no words at all. Keep in step with
/// `detectOffTopic` in `backend/src/offtopic.ts`, which also catches these
/// (and refunds), so this check only saves the user a wasted draw.
bool looksOffTopic(String question) {
  final q = question.trim();
  if (q.isEmpty) return false;
  final patterns = [
    RegExp(
      r'\b(what|which) (ai |language |llm )?model (are|is|do|does|powers|runs) (you|this|it)\b',
      caseSensitive: false,
    ),
    RegExp(r'\bwhat (ai|llm) (are|is) (you|this)\b', caseSensitive: false),
    RegExp(
      r'\bare you (an? )?(ai|bot|robot|human|real person|real|chatgpt|gpt|claude|gemini|llm)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bwho (made|built|created|trained|programmed) you\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(ignore|forget|disregard) (all |any |the |your )?(previous|prior|above|earlier) (instructions|rules|prompts?)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(system prompt|your instructions|your rules|developer mode|jailbreak)\b',
      caseSensitive: false,
    ),
    RegExp(r'(什么|哪个|哪一个|啥)(ai)?模型', caseSensitive: false),
    RegExp(
      r'^(请问)?你(到底)?是(谁|什么|哪个|人|真人|机器人|ai|gpt|chatgpt|claude)',
      caseSensitive: false,
    ),
    RegExp(r'谁(做|开发|训练|创造)了?你'),
    RegExp(r'(忽略|无视|忘记)(之前|以上|上面|前面)'),
    RegExp(r'(系统提示|提示词)'),
  ];
  if (patterns.any((r) => r.hasMatch(q))) return true;
  // Bare arithmetic ("2+2", "12 * 7 = ?").
  if (RegExp(r'^[\d\s+\-*/x×÷=().,?^%]+$', caseSensitive: false).hasMatch(q) &&
      RegExp(r'\d').hasMatch(q) &&
      RegExp(r'[+\-*/×÷^%=]').hasMatch(q)) {
    return true;
  }
  // Code.
  if (RegExp(
    r'(\bfunction\s*\(|=>|\bdef \w+\(|#include|\bconsole\.log|\bSELECT .* FROM\b)',
    caseSensitive: false,
  ).hasMatch(q)) {
    return true;
  }
  // No letters in any script (emoji, digits or punctuation only).
  return !RegExp(r'\p{L}', unicode: true).hasMatch(q);
}
