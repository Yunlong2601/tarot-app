import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/features/draw/deck_fan.dart';
import 'package:shentarot/features/read/flip_card.dart';
import 'package:shentarot/main.dart';

void main() {
  brandAnimations = false;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  Future<void> openDraw(WidgetTester t, {bool reduceMotion = false}) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    t.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: reduceMotion);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.pumpWidget(
      ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Draw').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Digital card reading'));
    await t.pumpAndSettle();
    await t.tap(find.text('Skip: general reading'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Start '));
    await t.pumpAndSettle();
  }

  Finder fanCards() => find.descendant(
    of: find.byType(DeckFan),
    matching: find.byType(CardBack),
  );

  testWidgets('swipe the fan, tap any card, it flies into the next slot', (
    t,
  ) async {
    await openDraw(t);
    expect(fanCards(), findsWidgets);
    await t.timedDrag(
      find.byType(DeckFan),
      const Offset(-120, 0),
      const Duration(seconds: 1),
    );
    await t.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      // A card left of the middle, not the one the screen-reader button takes.
      await t.tapAt(t.getCenter(find.byType(DeckFan)) - const Offset(80, 0));
      await t.pumpAndSettle();
      expect(find.byType(FlipCard), findsNWidgets(i + 1));
      if (i == 0) {
        final shuffle = t.widget<TextButton>(
          find.ancestor(
            of: find.text('Shuffle again'),
            matching: find.byWidgetPredicate((w) => w is TextButton),
          ),
        );
        expect(shuffle.onPressed, isNull);
      }
    }
    // All three placed: the fan is gone and the cards are different.
    expect(find.byType(DeckFan), findsNothing);
    final ids = t
        .widgetList<FlipCard>(find.byType(FlipCard))
        .map((f) => f.drawn.card.id)
        .toSet();
    expect(ids.length, 3);
  });

  testWidgets('reduced motion: the draw button places cards at once', (
    t,
  ) async {
    await openDraw(t, reduceMotion: true);
    for (var i = 0; i < 3; i++) {
      await t.tap(find.bySemanticsLabel('Deck. Tap to draw the next card.'));
      await t.pump();
    }
    expect(find.byType(FlipCard), findsNWidgets(3));
    for (var i = 0; i < 3; i++) {
      await t.tap(find.byType(FlipCard).at(i));
      await t.pump();
    }
    expect(find.text('Get my reading'), findsOneWidget);
  });
}
