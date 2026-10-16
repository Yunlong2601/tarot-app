import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/core/reading_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/read/question_nudge.dart';
import 'package:shentarot/features/read/flip_card.dart';
import 'package:shentarot/main.dart';

class _Crisis implements ReadingService {
  @override
  Future<ReadingResult> interpret({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
  }) async => throw const ReadingException(
    ReadingErrorKind.crisis,
    'Please reach out. Call 988.',
  );
  @override
  Future<ReadingResult> followUp({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    required String reading,
    required String followUp,
  }) async => throw const ReadingException(ReadingErrorKind.crisis, 'x');
}

void main() {
  brandAnimations = false;
  final deck = Deck.fromJsonString(
    File(Deck.assetPath).readAsStringSync(),
    File(Deck.knowledgePath).readAsStringSync(),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  void tall(WidgetTester t) {
    t.view.physicalSize = const Size(1080, 5000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
  }

  group('card knowledge', () {
    test('all 22 majors have rich knowledge; minors fall back', () {
      final majors = deck.cards.where((c) => c.arcana == Arcana.major);
      expect(majors.length, 22);
      for (final c in majors) {
        final k = c.knowledge;
        expect(k, isNotNull, reason: c.id);
        expect(k!.essence, isNotEmpty);
        expect(k.imagery.length, greaterThan(40), reason: c.id);
        expect(k.modes.length, 3, reason: c.id);
        expect(k.uprightQuestion, endsWith('?'), reason: c.id);
        expect(k.reversedQuestion, endsWith('?'), reason: c.id);
      }
      expect(deck.byId('cups_ace')!.knowledge, isNull);
    });
  });

  group('question nudge', () {
    test(
      'suggests rewording for yes/no, timing and mind-reading questions',
      () {
        expect(questionNudge('Will I get the job?'), contains('What'));
        expect(questionNudge('When will I meet someone?'), contains('Timing'));
        expect(
          questionNudge('What is he thinking about me?'),
          contains('someone else'),
        );
        expect(questionNudge('Does she love me?'), contains('someone else'));
      },
    );
    test('leaves good or short questions alone', () {
      expect(questionNudge('What should I focus on this week?'), isNull);
      expect(questionNudge('How can I rest?'), isNull);
      expect(questionNudge('Will I?'), isNull);
    });
  });

  group('Card of the Day', () {
    test(
      'draws once a day, same card until tomorrow, persists across restarts',
      () async {
        var now = DateTime(2026, 10, 16, 9);
        AppState make() => AppState(deck: deck, clock: () => now);
        final a = make();
        final first = a.drawDailyCard(Random(1));
        expect(a.drawDailyCard(Random(99)).card.id, first.card.id);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final b = make();
        await b.loadPersisted();
        expect(b.dailyCardIfDrawn!.card.id, first.card.id);

        now = DateTime(2026, 10, 17, 9);
        expect(b.dailyCardIfDrawn, isNull);
        final next = b.drawDailyCard(Random(2));
        expect(next, isNotNull);
      },
    );

    test('never reversed when reversals are off', () {
      for (var seed = 0; seed < 40; seed++) {
        final s = AppState(deck: deck)..setReadReversed(false);
        expect(s.drawDailyCard(Random(seed)).reversed, isFalse);
      }
    });

    testWidgets('flip shows the meaning and Go deeper starts a reading', (
      t,
    ) async {
      tall(t);
      final s = AppState(deck: deck, onboarded: true);
      await t.pumpWidget(ShenTarotApp(initialState: s));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('Card of the Day'));
      await t.pumpAndSettle();
      expect(find.text('Go deeper: reading for this card'), findsNothing);
      await t.tap(find.bySemanticsLabel(RegExp('Face-down card')));
      await t.pumpAndSettle();
      expect(find.text('Go deeper: reading for this card'), findsOneWidget);
      expect(find.textContaining('entertainment'), findsWidgets);
    });
  });

  group('crisis reply', () {
    testWidgets('shows a care dialog and saves no reading', (t) async {
      tall(t);
      final s = AppState(
        deck: deck,
        onboarded: true,
        readingService: _Crisis(),
      );
      await t.pumpWidget(ShenTarotApp(initialState: s));
      await t.pumpAndSettle();
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
      expect(find.text('You are not alone'), findsOneWidget);
      expect(find.textContaining('988'), findsOneWidget);
      expect(s.history, isEmpty);
    });
  });

  group('reading screen', () {
    testWidgets('shows position labels under each card', (t) async {
      tall(t);
      final s = AppState(deck: deck, onboarded: true)..setPremium(true);
      s.addReading(
        Reading(
          id: 'a',
          createdAt: DateTime(2026, 5, 5),
          spread: SpreadType.threeCard,
          cards: [
            for (final id in ['major_00_fool', 'cups_ace', 'swords_ten'])
              DrawnCard(card: deck.byId(id)!, reversed: false),
          ],
          interpretation: 'x',
        ),
      );
      await t.pumpWidget(ShenTarotApp(initialState: s));
      await t.pumpAndSettle();
      await t.tap(find.text('You').last);
      await t.pumpAndSettle();
      await t.tap(find.text('Reading History'));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('Past, Present, Future'));
      await t.pumpAndSettle();
      expect(find.text('Where it began'), findsOneWidget);
      expect(find.text('Where it is heading'), findsOneWidget);
    });
  });
}
