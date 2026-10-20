import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/features/reading/reading_sections.dart';

void main() {
  const structured = '''In short
Change is underway, and you have more say in it than it seems.

Where it began: The Fool (reversed)
A start that was held back.
Why: Zero is the number of potential.

Where it stands: Ace of Cups
Feeling is opening up.
Why: Aces are seeds.

To reflect on
What would I start if I accepted being clumsy at first?

A small step
Write down one thing you would try this week.''';

  test('splits a structured reading into its sections', () {
    final s = parseReading(structured)!;
    expect(s.map((x) => x.kind), [
      SectionKind.overview,
      SectionKind.card,
      SectionKind.card,
      SectionKind.reflect,
      SectionKind.step,
    ]);
    expect(s[1].title, 'Where it began: The Fool (reversed)');
    expect(s[1].body, 'A start that was held back.');
    expect(s[1].why, 'Zero is the number of potential.');
    expect(s[1].cardIndex, 0);
    expect(s[2].cardIndex, 1);
    expect(s[3].body, startsWith('What would I start'));
  });

  test('fallback readings without "In short" or "Why" still parse', () {
    final s = parseReading(
      'The card: The Sun\nWarmth and clarity.\n\nTo reflect on\nWhat brings me joy?',
    )!;
    expect(s.first.kind, SectionKind.card);
    expect(s.first.why, isNull);
    expect(s.last.kind, SectionKind.reflect);
  });

  test('plain text gives null', () {
    expect(parseReading('Just a paragraph of text.'), isNull);
    expect(parseReading('One.\n\nTwo.'), isNull);
  });
}
