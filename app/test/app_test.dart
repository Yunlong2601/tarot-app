import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/flags.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/main.dart';

import 'helpers.dart';

import 'package:shentarot/app/brand.dart';

void tallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 5000);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

Deck loadDeckFromDisk() =>
    Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

void main() {
  brandAnimations = false;
  final deck = loadDeckFromDisk();

  group('Deck data', () {
    test('has 78 unique cards', () {
      expect(deck.cards.length, 78);
      expect({for (final c in deck.cards) c.id}.length, 78);
    });

    test('has 22 major cards and 14 per suit', () {
      expect(deck.cards.where((c) => c.arcana == Arcana.major).length, 22);
      for (final s in Suit.values) {
        expect(deck.cards.where((c) => c.suit == s).length, 14, reason: s.name);
      }
    });

    test('every card has 3 keywords and both meanings', () {
      for (final c in deck.cards) {
        expect(c.keywords.length, 3, reason: c.id);
        expect(c.upright.trim(), isNotEmpty, reason: c.id);
        expect(c.reversed.trim(), isNotEmpty, reason: c.id);
        expect(c.upright, isNot(c.reversed), reason: c.id);
      }
    });

    test('major arcana are numbered 0 to 21 in order', () {
      final majors = deck.cards.where((c) => c.arcana == Arcana.major).toList();
      expect([for (final c in majors) c.number], List.generate(22, (i) => i));
    });

    test('rejects a deck of the wrong size', () {
      expect(() => Deck.fromJsonString('{"cards": []}'), throwsFormatException);
    });
  });

  group('Deck search', () {
    test('matches name, case-insensitively', () {
      expect(deck.search('star').map((c) => c.name), contains('The Star'));
    });

    test('matches keywords', () {
      expect(deck.search('hope').map((c) => c.id), contains('major_17_star'));
    });

    test('filters by suit', () {
      final cups = deck.search('', filter: CardFilter.cups);
      expect(cups.length, 14);
      expect(cups.every((c) => c.suit == Suit.cups), isTrue);
    });

    test('combines query and filter', () {
      final r = deck.search('ace', filter: CardFilter.wands);
      expect(r.map((c) => c.id), ['wands_ace']);
    });

    test('no match returns empty', () {
      expect(deck.search('zzzz'), isEmpty);
    });
  });

  Reading sample(String id, {SpreadType spread = SpreadType.single}) => Reading(
    id: id,
    createdAt: DateTime(2026, 10, 16),
    spread: spread,
    cards: [DrawnCard(card: deck.cards.first, reversed: false)],
    interpretation: 'x',
  );

  group('AppState credit wallet', () {
    tearDown(() => creditsEnabled = false);

    test('the status line shows credits, the daily amount and rollover', () {
      creditsEnabled = true;
      final s = AppState(deck: deck)
        ..credits = 7
        ..dailyCredits = 2;
      expect(
        s.creditLine,
        '7 credits · 2 new credits every day, unused credits roll over',
      );
      s.credits = 0;
      expect(s.creditLine, contains('No credits left'));
      expect(s.creditLine, contains('go Premium'));
      s.setPremium(true);
      s.dailyCredits = 2;
      s.monthlyCredits = 150;
      expect(s.creditLine, 'No credits left. 2 new credits arrive tomorrow.');
      s.credits = 120;
      expect(
        s.creditLine,
        '120 credits · 150 new credits every month, and 2 a day, unused credits roll over',
      );
    });

    test('a free user can start a reading only while they hold credits', () {
      creditsEnabled = true;
      final s = AppState(deck: deck);
      expect(s.canStart(SpreadType.single), isFalse);
      s.credits = 1;
      expect(s.canStart(SpreadType.single), isTrue);
      expect(s.canStart(SpreadType.horseshoe), isTrue); // the one trial
      s.trialUsed = true;
      expect(s.canStart(SpreadType.horseshoe), isFalse); // Premium spread
    });
  });

  group('AppState free-tier rules', () {
    test(
      'spreads of up to 3 cards are free; longer ones use the one trial',
      () {
        final s = AppState(deck: deck);
        for (final t in SpreadType.values) {
          expect(s.canStart(t), isTrue, reason: t.name);
          expect(s.usesTrial(t), t.cardCount > 3, reason: t.name);
        }
        expect(
          SpreadType.values.where((t) => !t.isFree).map((t) => t.cardCount),
          everyElement(greaterThan(3)),
        );
      },
    );

    test('free reading is consumed after one reading', () {
      final s = AppState(deck: deck);
      s.addReading(sample('a'));
      expect(s.canStart(SpreadType.single), isFalse);
      expect(s.canStart(SpreadType.threeCard), isFalse);
    });

    test('a long spread uses the trial and the daily reading; tomorrow only free spreads open', () {
      var now = DateTime(2026, 10, 16);
      final s = AppState(deck: deck, clock: () => now);
      s.addReading(sample('a', spread: SpreadType.horseshoe));
      expect(s.trialUsed, isTrue);
      expect(s.canStart(SpreadType.single), isFalse);
      now = DateTime(2026, 10, 17); // a new day: daily limit reset
      expect(s.canStart(SpreadType.threeCard), isTrue);
      expect(s.canStart(SpreadType.horseshoe), isFalse); // Premium now
      expect(s.usesTrial(SpreadType.horseshoe), isFalse);
    });

    test('premium unlocks all spreads, unlimited', () {
      final s = AppState(deck: deck)..setPremium(true);
      s.addReading(sample('a'));
      s.addReading(sample('b'));
      for (final t in SpreadType.values) {
        expect(s.canStart(t), isTrue);
      }
    });
  });

  group('navigation', () {
    testWidgets('new user sees onboarding, then the scan tab', (tester) async {
      tallPhone(tester);
      await tester.pumpWidget(ShenTarotApp(initialState: AppState(deck: deck)));
      await tester.pumpAndSettle();
      expect(find.text('Hold the cards. We explain them.'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(find.text('Photo reading'), findsOneWidget);
    });

    testWidgets('the paywall shows the required links', (tester) async {
      tallPhone(tester);
      await tester.pumpWidget(
        ShenTarotApp(
          initialState: AppState(deck: deck, onboarded: true)..trialUsed = true,
        ),
      );
      await tester.pumpAndSettle();
      await openPaywall(tester);
      await tester.pumpAndSettle();
      expect(find.text('Unlock Premium'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Use'), findsOneWidget);
    });

    testWidgets('simulated scan opens a reading', (tester) async {
      tallPhone(tester);
      await tester.pumpWidget(
        ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
      );
      await tester.pumpAndSettle();
      await goPhoto(tester);
      await tester.tap(find.text('Simulate scan'));
      await tester.pumpAndSettle();
      expect(find.textContaining('sample reading'), findsOneWidget);
    });

    testWidgets('cards tab lists the deck, filters, and opens a detail page', (
      tester,
    ) async {
      tallPhone(tester);
      await tester.pumpWidget(
        ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Library').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cards').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cups'));
      await tester.pumpAndSettle();
      // Each tile shows the name twice while the art placeholder is in use.
      expect(find.text('Ace of Cups'), findsWidgets);
      expect(find.text('Ace of Wands'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('No cards match'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ace');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ace of Cups').last);
      await tester.pumpAndSettle();
      expect(find.text('Upright'), findsOneWidget);
      expect(find.text('Reversed'), findsOneWidget);
      expect(find.textContaining('Element: Water'), findsOneWidget);
    });
  });
}
