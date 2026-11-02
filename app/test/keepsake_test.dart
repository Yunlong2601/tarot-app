import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/reading/keepsake.dart';

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  test('pages are cut on blank rows, never through text', () {
    // Text rows 90..110 and 190..210; pages are 100 tall.
    bool blank(int y) => !(y >= 90 && y <= 110) && !(y >= 190 && y <= 210);
    final cuts = keepsakeCuts(260, 100, blank);
    expect(cuts.first, (0, 89));
    for (final (_, b) in cuts.take(cuts.length - 1)) {
      expect(blank(b), isTrue);
    }
    expect(cuts.last.$2, 260);
  });

  test('a page with no blank row is still cut at the page height', () {
    expect(keepsakeCuts(250, 100, (_) => false), [(0, 100), (100, 200), (200, 250)]);
  });

  testWidgets('a reading keepsake lists each card with its position', (t) async {
    final r = Reading(
      id: 'r',
      createdAt: DateTime(2026, 11, 2),
      spread: SpreadType.single,
      cards: [DrawnCard(card: deck.cards.first, reversed: false)],
      interpretation: 'In short\nA fresh start.\n\nThe card: The Fool\nLeap.\nWhy: zero.',
    );
    final parts = readingParts(r);
    expect(parts.map((p) => p.heading), ['In short', 'The card · The Fool']);
    await t.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: KeepsakePage(title: 'One-Card Reading', subtitle: '2 November 2026', parts: parts),
        ),
      ),
    );
    expect(find.text('Leap.'), findsOneWidget);
    expect(find.text('For entertainment and self-reflection only.'), findsOneWidget);
  });
}
