import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/history/history_filter.dart';

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
  final now = DateTime(2026, 10, 17);
  Reading r(String id, SpreadType s, int daysAgo, {String? q, String? note}) =>
      Reading(
        id: id,
        createdAt: now.subtract(Duration(days: daysAgo)),
        spread: s,
        cards: [DrawnCard(card: deck.byId('major_19_sun')!, reversed: false)],
        interpretation: 'x',
        question: q,
        note: note,
      );
  final all = [
    r('a', SpreadType.single, 1, q: 'My new job?'),
    r('b', SpreadType.loveConnection, 10, note: 'felt calm'),
    r('c', SpreadType.careerPath, 100),
  ];

  test('search covers cards, question and note', () {
    expect(filterHistory(all, query: 'sun', now: now).length, 3);
    expect(filterHistory(all, query: 'job', now: now).single.id, 'a');
    expect(filterHistory(all, query: 'CALM', now: now).single.id, 'b');
  });

  test('category and period filters', () {
    expect(
      filterHistory(all, category: SpreadCategory.love, now: now).single.id,
      'b',
    );
    expect(
      filterHistory(all, period: HistoryPeriod.week, now: now).single.id,
      'a',
    );
    expect(filterHistory(all, period: HistoryPeriod.month, now: now).length, 2);
  });
}
