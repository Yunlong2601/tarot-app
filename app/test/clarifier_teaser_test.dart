import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/reading/reading_screen.dart';

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
  Reading reading(String id) => Reading(
    id: id,
    createdAt: DateTime(2026, 11, 1),
    spread: SpreadType.threeCard,
    cards: [
      for (final c in deck.cards.take(3)) DrawnCard(card: c, reversed: false),
    ],
    interpretation: 'x',
  );

  test(
    'the waiting clarifier is the same card every time, never in the reading',
    () {
      final s = AppState(deck: deck);
      final r = reading('r1');
      final a = waitingClarifier(s, r);
      final b = waitingClarifier(s, r);
      expect(a.card.id, b.card.id);
      expect(r.cards.map((c) => c.card.id), isNot(contains(a.card.id)));
    },
  );
}
