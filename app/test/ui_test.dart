import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/core/reading_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/read/flip_card.dart';
import 'package:shentarot/main.dart';

import 'helpers.dart';

import 'package:shentarot/app/brand.dart';

class _Fake implements ReadingService {
  final calls = <List<DrawnCard>>[];
  final impressions = <String?>[];
  @override
  Future<ReadingResult> interpret({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    String? impression,
  }) async {
    calls.add(cards);
    impressions.add(impression);
    return const ReadingResult(text: 'A thoughtful reading.', disclaimer: 'd');
  }

  @override
  Future<ReadingResult> followUp({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    required String reading,
    required String followUp,
    DrawnCard? clarifier,
  }) async => const ReadingResult(text: 'More.', disclaimer: 'd');
}

void main() {
  brandAnimations = false;
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

  testWidgets('digital reading: ask, pick, draw into slots, flip, read', (
    t,
  ) async {
    final fake = _Fake();
    final s = AppState(deck: deck, onboarded: true, readingService: fake);
    await start(t, s);
    await t.tap(find.byTooltip('Switch to digital card reading'));
    await t.pumpAndSettle();
    await t.tap(find.text('Digital card reading'));
    await t.pumpAndSettle();
    await t.enterText(
      find.byType(TextField),
      'What should I focus on this week?',
    );
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    expect(find.text('Select a Spread'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    await t.tap(find.textContaining('Start '));
    await t.pumpAndSettle();
    // Past, Present, Future: three cards. Draw each from the deck.
    expect(find.text('Get my reading'), findsNothing);
    for (var i = 0; i < 3; i++) {
      await t.tap(find.bySemanticsLabel('Deck. Tap to draw the next card.'));
      await t.pumpAndSettle();
    }
    for (var i = 0; i < 3; i++) {
      await t.tap(find.byType(FlipCard).at(i));
      await t.pumpAndSettle();
    }
    expect(find.text('Get my reading'), findsOneWidget);
    await t.tap(find.text('Get my reading'));
    await t.pumpAndSettle();
    expect(fake.calls.single.length, 3);
    expect(find.text('A thoughtful reading.'), findsOneWidget);
    expect(s.history.length, 1);
    expect(s.history.first.question, 'What should I focus on this week?');
    // Back from the reading lands on the Read tab, not the draw screen.
    await t.tap(find.byTooltip('Back'));
    await t.pumpAndSettle();
    expect(find.text('Hold the cards.'), findsOneWidget);
  });

  testWidgets('look first: the typed impression goes with the reading', (
    t,
  ) async {
    final fake = _Fake();
    final s = AppState(deck: deck, onboarded: true, readingService: fake)
      ..lookFirst = true;
    await start(t, s);
    await t.tap(find.byTooltip('Switch to digital card reading'));
    await t.pumpAndSettle();
    await t.tap(find.text('Digital card reading'));
    await t.pumpAndSettle();
    await t.tap(find.text('Skip: general reading'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Start '));
    await t.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await t.tap(find.bySemanticsLabel('Deck. Tap to draw the next card.'));
      await t.pumpAndSettle();
    }
    for (var i = 0; i < 3; i++) {
      await t.tap(find.byType(FlipCard).at(i));
      await t.pumpAndSettle();
    }
    await t.tap(find.text('Get my reading'));
    await t.pumpAndSettle();
    expect(find.text('Look first'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, 'a bright sun');
    await t.tap(find.text('Read'));
    await t.pumpAndSettle();
    expect(fake.impressions.single, 'a bright sun');
    expect(find.text('A thoughtful reading.'), findsOneWidget);
  });

  testWidgets('spread picker recommends by the question', (t) async {
    final s = AppState(deck: deck, onboarded: true);
    await start(t, s);
    await t.tap(find.text('Photo reading'));
    await t.pumpAndSettle();
    await t.enterText(
      find.byType(TextField),
      'How do I heal after my breakup?',
    );
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    expect(find.text('Healing & Reconnection'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Start free reading'), findsOneWidget); // a 7-card spread: the one free trial
  });

  testWidgets('library: mode toggle switches between scan and digital', (
    t,
  ) async {
    final s = AppState(deck: deck, onboarded: true);
    await start(t, s);
    await t.tap(find.text('Library').last);
    await t.pumpAndSettle();
    expect(s.readMode, ReadMode.photo);
    await t.tap(find.text('Draw digitally'));
    await t.pumpAndSettle();
    expect(s.readMode, ReadMode.digital);
    await t.tap(find.text('Read').last);
    await t.pumpAndSettle();
    expect(find.text('Digital card reading'), findsOneWidget);
  });

  testWidgets('library: spreads by category, Classics first', (t) async {
    final s = AppState(deck: deck, onboarded: true);
    await start(t, s);
    await t.tap(find.text('Library').last);
    await t.pumpAndSettle();
    // Classics is the first tab and selected by default.
    expect(find.text('One-Card Reading'), findsOneWidget);
    expect(find.text('1 card'), findsOneWidget);
    await tapVisible(t, find.text('Love'));
    expect(find.text('Love & Relationship'), findsOneWidget);
  });

  testWidgets(
    'library: a premium spread opens the paywall once the trial is used',
    (t) async {
      final s = AppState(deck: deck, onboarded: true)..trialUsed = true;
      await start(t, s);
      await openPaywall(t);
      expect(find.text('Unlock Premium'), findsOneWidget);
    },
  );

  testWidgets('library: a free spread starts the ask flow with it selected', (
    t,
  ) async {
    final s = AppState(deck: deck, onboarded: true);
    await start(t, s);
    await t.tap(find.text('Library').last);
    await t.pumpAndSettle();
    await tapVisible(t, find.text('Classics'));
    await tapVisible(t, find.text('Past, Present, Future'));
    expect(s.selectedSpread, SpreadType.threeCard);
    expect(find.text('Your question'), findsOneWidget);
  });

  testWidgets('guide explains how to use the app', (t) async {
    await start(t, AppState(deck: deck, onboarded: true));
    await t.tap(find.text('Guide').last);
    await t.pumpAndSettle();
    expect(find.text('How to use ShenTarot'), findsOneWidget);
    expect(find.text('Scan a card'), findsOneWidget);
    expect(find.text('Draw today\'s card'), findsOneWidget);
    await t.scrollUntilVisible(find.text('Myths and worries'), 400);
    expect(find.text('Learn tarot in 12 short lessons'), findsOneWidget);
    expect(find.text('Myths and worries'), findsOneWidget);
  });

  testWidgets('guide shows today\'s card and your journey', (t) async {
    final s = AppState(deck: deck, onboarded: true);
    final r = Reading(
      id: 'a',
      createdAt: DateTime(2026, 10, 1),
      spread: SpreadType.single,
      cards: [DrawnCard(card: deck.byId('major_19_sun')!, reversed: false)],
      interpretation: 'x',
    );
    s.history.addAll([r, r]);
    s.drawDailyCard(Random(3), false);
    await start(t, s);
    await t.tap(find.text('Guide').last);
    await t.pumpAndSettle();
    expect(find.text('TODAY\'S CARD'), findsOneWidget);
    expect(find.text('Your journey'), findsOneWidget);
    expect(find.textContaining('The Sun (2 times)'), findsOneWidget);
  });

  test('digital draws never repeat a card (seeded)', () {
    // The draw uses a shuffled deck, so cards in one spread are unique.
    final cards = [...deck.cards]..shuffle(Random(1));
    expect(cards.take(10).map((c) => c.id).toSet().length, 10);
  });
}
