import '../../app/i18n.dart';

/// A gentle, offline check of how a question is worded. Returns a short
/// suggestion, or null when the question looks fine. Tarot works best as
/// reflection, so we nudge away from yes/no, timing, and mind-reading
/// questions. It never blocks; the user can ask anything.
String? questionNudge(String question) {
  if (looksOffTopic(question)) {
    return tr(
      'The cards read best on your own life. Try something like "What do I need to understand about my work right now?"',
    );
  }
  final q = question.trim().toLowerCase();
  if (q.length < 8) return null;
  final mindReading = RegExp(
    r"\b(what is|what's|what does) (he|she|they|my (ex|boss|partner|crush))\b.*\b(think|feel|want|thinking|feeling)\b|"
    r"\bdoes (he|she|they) (love|like|miss|want)\b",
  );
  if (mindReading.hasMatch(q)) {
    return tr(
      'Cards cannot tell what someone else thinks or feels. Try asking about your own side: "What do I need to understand about this?"',
    );
  }
  if (RegExp(r'\bwhen (will|am i going to|do i)\b').hasMatch(q)) {
    return tr(
      'Timing is hard for the cards. Try: "What can I do to move this forward?"',
    );
  }
  if (RegExp(r'^(will|should|is|am|are|do|does|can|shall)\b').hasMatch(q)) {
    return tr(
      'Open questions give richer readings. Try starting with "What" or "How": "What would help me with this?"',
    );
  }
  return null;
}

/// Questions about the AI or the app, attempts to change its instructions,
/// maths, code and keyboard mashing. Checked offline before cards are drawn,
/// in the app's main languages. The server checks again after the draw.
bool looksOffTopic(String question) {
  final q = question.trim().toLowerCase();
  if (q.isEmpty) return false;
  final meta = RegExp(
    r"\b(what|which) (ai|model|llm|gpt)\b|\bare you (an? )?(ai|bot|robot|human|real|person|chatgpt|gpt|claude)\b|"
    r"\bwho (made|created|built|programmed) you\b|\bignore (all |your |the )?(previous|above|prior)|"
    r"\bsystem prompt\b|\byour (instructions|prompt)\b|\b(chatgpt|openai|anthropic|claude|gemini)\b|"
    r"\b(write|fix|debug) (me )?(a |some |this )?(code|program|script|essay|poem)\b|"
    r"什么模型|哪个模型|你是谁|你是(人|机器人|ai|人工智能)|谁(开发|创造|制作)了你|忽略(之前|以上|所有)|"
    r"什麼模型|哪個模型|你是誰|誰(開發|創造|製作)了你|"
    r"どのモデル|何のモデル|あなたは誰|あなたは(人間|ai|ロボット)|"
    r"무슨 모델|어떤 모델|너는 누구|당신은 누구|"
    r"qu[eé] modelo|eres (una? )?(ia|robot|humano|persona)|quién te (cre[oó]|hizo)|"
    r"quel mod[eè]le|es-tu (une? )?(ia|robot|humain)|"
    r"welches modell|bist du (eine? )?(ki|roboter|mensch)",
  );
  if (meta.hasMatch(q)) return true;
  // Plain arithmetic like "12*7" or "what is 2+2".
  if (RegExp(
    r'^\s*(what is|calculate|计算)?\s*[\d\s.]+[+\-*/x×÷^]\s*[\d\s.]+[=?？]?\s*$',
  ).hasMatch(q)) {
    return true;
  }
  // Keyboard mashing: long runs of consonants or one repeated character.
  if (RegExp(r'(.)\1{5,}').hasMatch(q) ||
      RegExp(r'^[bcdfghjklmnpqrstvwxz]{7,}$').hasMatch(q)) {
    return true;
  }
  return false;
}
