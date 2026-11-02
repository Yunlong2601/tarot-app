import '../../data/models.dart';

/// Words too common to say two questions are about the same thing.
const _stop = {
  'a', 'an', 'the', 'i', 'me', 'my', 'mine', 'we', 'our', 'you', 'your', 'is',
  'are', 'am', 'was', 'be', 'do', 'does', 'did', 'will', 'would', 'should',
  'can', 'could', 'what', 'how', 'why', 'when', 'where', 'who', 'which', 'to',
  'of', 'in', 'on', 'at', 'for', 'with', 'about', 'and', 'or', 'it', 'this',
  'that', 'need', 'know', 'understand', 'approach', 'way', 'helping',
  'there', 'so', 'if', 'now', 'right', 'get', 'go',
};

/// The words that carry a question's meaning. Latin scripts split on
/// non-letters; scripts without spaces (Chinese, Japanese) use pairs of
/// characters so "工作" still matches "工作".
Set<String> questionWords(String q) {
  final text = q.toLowerCase();
  final words = <String>{};
  for (final w in text.split(RegExp(r"[^\p{L}\p{N}']+", unicode: true))) {
    if (w.isEmpty) continue;
    if (RegExp(r'[぀-ヿ㐀-鿿가-힯]').hasMatch(w)) {
      final chars = w.runes.map(String.fromCharCode).toList();
      for (var i = 0; i + 1 < chars.length; i++) {
        words.add(chars[i] + chars[i + 1]);
      }
      continue;
    }
    if (w.length < 3 || _stop.contains(w)) continue;
    words.add(w.length > 4 && w.endsWith('s') ? w.substring(0, w.length - 1) : w);
  }
  return words;
}

/// The most recent past reading whose question is close to [question]
/// (at least half the meaningful words shared), within [window]. Null if
/// none, or if the question is too short to compare.
Reading? similarPastReading(
  List<Reading> history,
  String question, {
  required DateTime now,
  Duration window = const Duration(days: 120),
}) {
  final asked = questionWords(question);
  if (asked.length < 2) return null;
  for (final r in history) {
    final q = r.question;
    if (q == null || q.trim().isEmpty) continue;
    if (now.difference(r.createdAt) > window) continue;
    final past = questionWords(q);
    if (past.isEmpty) continue;
    final shared = asked.intersection(past).length;
    final union = asked.union(past).length;
    if (shared >= 2 && shared / union >= 0.5) return r;
  }
  return null;
}
