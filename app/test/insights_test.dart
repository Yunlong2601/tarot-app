import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/collection/insights.dart';
import 'package:shentarot/features/reading/share_card.dart';

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
  final fool = deck.cards.first;
  final other = deck.cards[30];

  Reading reading(DateTime at, List<TarotCard> cards, [SpreadType? s]) =>
      Reading(
        id: '${at.millisecondsSinceEpoch}',
        createdAt: at,
        spread: s ?? SpreadType.threeCard,
        cards: [for (final c in cards) DrawnCard(card: c, reversed: false)],
        interpretation: 'x',
      );

  test('monthly recap counts only this month and ranks repeat cards', () {
    final now = DateTime(2026, 10, 24);
    final r = recapFor([
      reading(DateTime(2026, 10, 2), [fool, other]),
      reading(DateTime(2026, 10, 20), [fool]),
      reading(DateTime(2026, 9, 30), [other, other]),
    ], now);
    expect(r.readings, 2);
    expect(r.topCards.single.$1.id, fool.id);
    expect(r.topCards.single.$2, 2);
    expect(r.groups['major'], 2);
    expect(r.cardCount, 3);
  });

  test('longest streak finds the best run of days', () {
    expect(
      longestStreak([
        DateTime(2026, 10, 1, 9),
        DateTime(2026, 10, 2, 23),
        DateTime(2026, 10, 3, 1),
        DateTime(2026, 10, 5),
      ]),
      3,
    );
    expect(longestStreak([]), 0);
  });

  test('milestones come from real use', () {
    final m = milestonesFor(
      [
        reading(DateTime(2026, 10, 1), [fool], SpreadType.celticCross),
      ],
      {fool.id},
      deck.cards,
    );
    final earned = {for (final x in m) x.title: x.earned};
    expect(earned['First reading'], isTrue);
    expect(earned['Celtic Cross'], isTrue);
    expect(earned['Ten readings'], isFalse);
    expect(earned['Whole deck'], isFalse);
  });

  testWidgets('share card hides the question unless asked', (t) async {
    final r = Reading(
      id: 'r',
      createdAt: DateTime(2026, 10, 1),
      spread: SpreadType.threeCard,
      cards: [
        for (final c in deck.cards.take(3)) DrawnCard(card: c, reversed: false),
      ],
      interpretation: 'A calm reading.',
      question: 'Will my secret plan work?',
    );
    await t.pumpWidget(MaterialApp(home: ShareCard(reading: r)));
    expect(find.textContaining('secret plan'), findsNothing);
    await t.pumpWidget(
      MaterialApp(home: ShareCard(reading: r, withQuestion: true)),
    );
    expect(find.textContaining('secret plan'), findsOneWidget);
  });
}
