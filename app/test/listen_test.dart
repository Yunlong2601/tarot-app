import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/reading/listen.dart';

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  test('reads the overview, each card by position, the question and the step', () {
    final cards = [
      for (final c in deck.cards.take(3)) DrawnCard(card: c, reversed: false),
    ];
    final r = Reading(
      id: 'r',
      createdAt: DateTime(2026, 11, 2),
      spread: SpreadType.threeCard,
      cards: cards,
      interpretation: [
        'In short\nA **turning** point.',
        'Where it began: The Fool\nA fresh start.\nWhy: it is card zero.',
        'Where it stands: The Magician\nYou have the tools.',
        'Where it is heading: The High Priestess\nListen inward.',
        'To reflect on\nWhat do you already know?',
        'A small step\nWrite one line tonight.',
      ].join('\n\n'),
    );
    final s = spokenReading(r);
    expect(s, startsWith('In short. A turning point.'));
    expect(s, contains('Where it began. The Fool. A fresh start.'));
    expect(s, isNot(contains('Why:')));
    expect(s, contains('A small step. Write one line tonight.'));
  });

  test('speaks in the app language', () {
    expect(speechLanguage('zh_Hans'), 'zh-CN');
    expect(speechLanguage('fr'), 'fr');
  });
}
