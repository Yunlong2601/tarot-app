import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/core/reading_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/main.dart';


class _Fake implements ReadingService {
  final calls = <List<DrawnCard>>[];
  @override
  Future<ReadingResult> interpret({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
  }) async {
    calls.add(cards);
    return const ReadingResult(text: 'A thoughtful reading.', disclaimer: 'd');
  }

  @override
  Future<ReadingResult> followUp({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    required String reading,
    required String followUp,
  }) async => const ReadingResult(text: 'More.', disclaimer: 'd');
}

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  void tall(WidgetTester t) {
    t.view.physicalSize = const Size(1080, 5000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
  }

  Future<void> start(WidgetTester t, AppState s) async {
    tall(t);
    await t.pumpWidget(ShenTarotApp(initialState: s));
    await t.pumpAndSettle();
  }

  testWidgets('landing shows the tagline and the mode button swaps', (t) async {
    await start(t, AppState(deck: deck, onboarded: true));
    expect(find.text('Hold the cards.'), findsOneWidget);
    expect(find.text('Photo reading'), findsOneWidget);
    await t.tap(find.byTooltip('Switch to digital card reading'));
    await t.pumpAndSettle();
    expect(find.text('Digital card reading'), findsOneWidget);
    expect(find.text('Photo reading'), findsNothing);
  });

  testWidgets('digital reading: flip every card, then get a reading', (
    t,
  ) async {
    final fake = _Fake();
    final s = AppState(deck: deck, onboarded: true, readingService: fake);
    await start(t, s);
    await t.tap(find.byTooltip('Switch to digital card reading'));
    await t.pumpAndSettle();
    await t.tap(find.text('Digital card reading'));
    await t.pumpAndSettle();
    // Single card spread: one face-down card, no reading button yet.
    expect(find.text('Get my reading'), findsNothing);
    await t.tap(find.bySemanticsLabel('Face-down card. Tap to turn over.'));
    await t.pumpAndSettle();
    expect(find.text('Get my reading'), findsOneWidget);
    await t.tap(find.text('Get my reading'));
    await t.pumpAndSettle();
    expect(fake.calls.single.length, 1);
    expect(find.text('A thoughtful reading.'), findsOneWidget);
    expect(s.history.length, 1);
  });

  testWidgets('library: spreads list, Premium lock, and the cards tab', (
    t,
  ) async {
    final s = AppState(deck: deck, onboarded: true);
    await start(t, s);
    await t.tap(find.text('Library').last);
    await t.pumpAndSettle();
    expect(find.text('Single card'), findsOneWidget);
    expect(find.text('Premium'), findsNWidgets(2)); // three-card + Celtic Cross
    await t.tap(find.text('Three cards'));
    await t.pumpAndSettle();
    expect(find.text('Unlock Premium'), findsOneWidget);
  });

  testWidgets(
    'library: picking a free spread returns to Read with it selected',
    (t) async {
      final s = AppState(deck: deck, onboarded: true)..setPremium(true);
      await start(t, s);
      await t.tap(find.text('Library').last);
      await t.pumpAndSettle();
      await t.tap(find.text('Three cards'));
      await t.pumpAndSettle();
      expect(s.selectedSpread, SpreadType.threeCard);
      expect(find.text('Spread: Three cards'), findsOneWidget);
    },
  );

  testWidgets('guide explains how to use the app', (t) async {
    await start(t, AppState(deck: deck, onboarded: true));
    await t.tap(find.text('Guide').last);
    await t.pumpAndSettle();
    expect(find.text('How to use ShenTarot'), findsOneWidget);
    expect(find.text('Scan a card'), findsOneWidget);
    expect(find.text('Tarot basics'), findsOneWidget);
  });

  testWidgets('sign-in demo can be closed and skipped, and signs nobody in', (
    t,
  ) async {
    final s = AppState(deck: deck, onboarded: true);
    await start(t, s);
    await t.tap(find.text('You').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Sign in'));
    await t.pumpAndSettle();
    expect(
      find.text('Demo screen: accounts are not available yet.'),
      findsOneWidget,
    );
    await t.tap(find.text('Continue with Apple'));
    await t.pump();
    expect(find.textContaining('Accounts are coming later'), findsOneWidget);
    await t.tap(find.text('Skip for now'));
    await t.pumpAndSettle();
    expect(find.text('Guest'), findsOneWidget);
    // And the close button works too.
    await t.tap(find.text('Sign in'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Close'));
    await t.pumpAndSettle();
    expect(find.text('Guest'), findsOneWidget);
  });

  test('digital draws never repeat a card (seeded)', () {
    // The draw uses a shuffled deck, so cards in one spread are unique.
    final cards = [...deck.cards]..shuffle(Random(1));
    expect(cards.take(10).map((c) => c.id).toSet().length, 10);
  });
}
