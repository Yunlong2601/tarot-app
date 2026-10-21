import 'models.dart';

/// Debug builds only ("Simulate scan"): a reading in the same layout the
/// backend sends, built from the stored card text, so the reading screen can
/// be previewed without a server.
String mockInterpretation(SpreadType spread, List<DrawnCard> cards) {
  final parts = <String>[
    'In short\nThis is a sample reading for debug builds. Real readings come '
        'from the backend.',
  ];
  for (final (i, d) in cards.indexed) {
    final k = d.card.knowledge;
    final text = k == null
        ? (d.reversed ? d.card.reversed : d.card.upright)
        : (d.reversed ? k.reversedCore : k.uprightCore);
    parts.add(
      '${spread.positions[i]}: ${d.card.name}${d.reversed ? ' (reversed)' : ''}'
      '\n$text${k == null ? '' : '\nWhy: ${k.why}'}',
    );
  }
  final k = cards.first.card.knowledge;
  parts.add(
    'To reflect on\n${k == null ? 'What stands out to you most, and why?' : (cards.first.reversed ? k.reversedQuestion : k.uprightQuestion)}',
  );
  parts.add('A small step\nWrite one sentence about what you noticed today.');
  return parts.join('\n\n');
}
