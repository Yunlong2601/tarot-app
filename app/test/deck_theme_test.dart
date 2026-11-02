import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/app/deck_theme.dart';
import 'package:shentarot/data/deck.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  test('a Premium card back falls back to Classic when Premium ends', () async {
    final s = AppState(deck: deck)..setPremium(true);
    await s.setDeckTheme(DeckTheme.midnight);
    expect(s.activeDeckTheme, DeckTheme.midnight);
    s.setPremium(false);
    expect(s.activeDeckTheme, DeckTheme.classic);
    s.setPremium(true);
    expect(s.activeDeckTheme, DeckTheme.midnight);
  });

  test('unknown stored names read as Classic', () {
    expect(deckThemeNamed('nope'), DeckTheme.classic);
    expect(deckThemeNamed('rose'), DeckTheme.rose);
  });

  testWidgets('every card back draws', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            for (final th in DeckTheme.values) CardBack(width: 40, theme: th),
          ],
        ),
      ),
    );
    expect(find.byType(CardBack), findsNWidgets(DeckTheme.values.length));
    expect(t.takeException(), isNull);
  });
}
