/// Splits the reading text the backend sends (see `renderReading` in
/// backend/src/reading.ts) into sections the app can lay out:
///
/// ```text
/// In short / overview
/// Position: Card [(reversed)] / text / Why: note   (one per card)
/// To reflect on / question
/// A small step / step
/// ```
///
/// Older or fallback readings may lack some parts; plain text gives null.
enum SectionKind { overview, card, reflect, step, other }

class ReadingSection {
  const ReadingSection(
    this.kind,
    this.title,
    this.body, {
    this.why,
    this.cardIndex,
  });
  final SectionKind kind;
  final String title;
  final String body;

  /// "Why this card" note, for card sections.
  final String? why;

  /// Which drawn card this section is about (card sections, in order).
  final int? cardIndex;
}

bool _isTitle(String line) =>
    line.length <= 70 &&
    !line.endsWith('.') &&
    !line.endsWith('?') &&
    !line.startsWith('Why:');

List<ReadingSection>? parseReading(String text) {
  final out = <ReadingSection>[];
  var cards = 0;
  for (final block in text.trim().split(RegExp(r'\n\s*\n'))) {
    final lines = block.trim().split('\n');
    if (lines.length < 2 || !_isTitle(lines.first)) {
      out.add(ReadingSection(SectionKind.other, '', block.trim()));
      continue;
    }
    final title = lines.first.trim();
    final rest = lines.skip(1).map((l) => l.trim()).toList();
    final why = rest.where((l) => l.startsWith('Why:')).firstOrNull;
    final body = rest.where((l) => !l.startsWith('Why:')).join('\n');
    final kind = switch (title) {
      'In short' => SectionKind.overview,
      'To reflect on' => SectionKind.reflect,
      'A small step' => SectionKind.step,
      _ => title.contains(':') ? SectionKind.card : SectionKind.other,
    };
    out.add(
      ReadingSection(
        kind,
        title,
        kind == SectionKind.other ? rest.join('\n') : body,
        why: kind == SectionKind.card ? why?.substring(4).trim() : null,
        cardIndex: kind == SectionKind.card ? cards++ : null,
      ),
    );
  }
  return out.any((s) => s.kind != SectionKind.other) ? out : null;
}
