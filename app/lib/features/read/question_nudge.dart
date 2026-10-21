import '../../data/spreads.dart';

/// A gentle, offline check of how a question is worded. Returns a short
/// suggestion, or null when the question looks fine. Tarot works best as
/// reflection, so we nudge away from yes/no, timing, and mind-reading
/// questions. It never blocks; the user can ask anything.
String? questionNudge(String question) {
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
