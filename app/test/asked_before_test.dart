import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/read/asked_before.dart';

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
  final now = DateTime(2026, 11, 2);
  Reading r(String id, String? q, {int daysAgo = 3}) => Reading(
    id: id,
    createdAt: now.subtract(Duration(days: daysAgo)),
    spread: SpreadType.threeCard,
    cards: [DrawnCard(card: deck.cards.first, reversed: false)],
    interpretation: 'x',
    question: q,
  );

  test('finds a past reading for the same worry, worded differently', () {
    final h = [
      r('a', 'Will my career change soon?'),
      r('b', 'Does my ex still think about me and miss me?'),
    ];
    expect(
      similarPastReading(h, 'Does my ex miss me and think about me?', now: now)?.id,
      'b',
    );
  });

  test('different topics, short questions and old readings do not match', () {
    final h = [
      r('a', 'What should I know about my new job?'),
      r('b', 'Does my ex miss me?', daysAgo: 200),
    ];
    expect(similarPastReading(h, 'Does my ex miss me?', now: now), isNull);
    expect(similarPastReading(h, 'Love?', now: now), isNull);
    expect(similarPastReading(h, 'How can I save more money?', now: now), isNull);
  });

  test('works for questions without spaces', () {
    final h = [r('a', '我的工作会顺利吗')];
    expect(similarPastReading(h, '我的工作会不会顺利', now: now)?.id, 'a');
  });
}
