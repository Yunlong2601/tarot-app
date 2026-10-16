import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/core/reading_service.dart';
import 'package:shentarot/core/reminder_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/history_repository.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/main.dart';

import 'helpers.dart';

import 'package:shentarot/app/brand.dart';

class FakeReadingService implements ReadingService {
  FakeReadingService({this.error});
  final ReadingException? error;
  final calls = <Map<String, Object?>>[];

  @override
  Future<ReadingResult> interpret({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    String? impression,
  }) async => const ReadingResult(text: 'x', disclaimer: 'd');

  @override
  Future<ReadingResult> followUp({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    required String reading,
    required String followUp,
    DrawnCard? clarifier,
  }) async {
    if (error != null) throw error!;
    calls.add({
      'reading': reading,
      'followUp': followUp,
      'n': cards.length,
      'clarifier': clarifier?.card.id,
    });
    return const ReadingResult(
      text: 'Here is more to explore.',
      disclaimer: 'd',
    );
  }
}

class FakeReminders implements ReminderService {
  FakeReminders({this.allow = true});
  final bool allow;
  TimeOfDay? scheduled;
  int cancels = 0;

  @override
  Future<bool> enable(TimeOfDay time) async {
    if (!allow) return false;
    scheduled = time;
    return true;
  }

  @override
  Future<void> disable() async => cancels++;
}

void main() {
  brandAnimations = false;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  Reading reading(String id, DateTime at, {String? question}) => Reading(
    id: id,
    createdAt: at,
    spread: SpreadType.threeCard,
    cards: [
      DrawnCard(card: deck.byId('major_00_fool')!, reversed: true),
      DrawnCard(card: deck.byId('cups_ace')!, reversed: false),
      DrawnCard(card: deck.byId('swords_ten')!, reversed: false),
    ],
    interpretation: 'A reading.',
    question: question,
  );

  late String dbPath;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final dir = Directory.systemTemp.createTempSync('shentarot_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    dbPath = '${dir.path}/h.db';
  });

  group('SqliteHistoryRepository', () {
    test(
      'round-trips readings, newest first, with orientation and question',
      () async {
        final repo = SqliteHistoryRepository(path: dbPath);
        await repo.add(reading('old', DateTime(2026, 1, 1)));
        await repo.add(reading('new', DateTime(2026, 6, 1), question: 'Why?'));
        final all = await repo.load(deck);
        expect(all.map((r) => r.id), ['new', 'old']);
        expect(all.first.question, 'Why?');
        expect(all.first.cards.map((c) => c.reversed), [true, false, false]);
        expect(all.first.cards.first.card.id, 'major_00_fool');
        expect(all.first.spread, SpreadType.threeCard);
      },
    );

    test('notes can be set, cleared, and readings deleted', () async {
      final repo = SqliteHistoryRepository(path: dbPath);
      await repo.add(reading('a', DateTime(2026, 1, 1)));
      await repo.add(reading('b', DateTime(2026, 1, 2)));
      await repo.setNote('a', '  felt true  ');
      expect((await repo.load(deck)).last.note, 'felt true');
      await repo.setNote('a', '   ');
      expect((await repo.load(deck)).last.note, isNull);
      await repo.delete('b');
      expect((await repo.load(deck)).map((r) => r.id), ['a']);
      await repo.clear();
      expect(await repo.load(deck), isEmpty);
    });
  });

  group('look back after a week', () {
    test('revisit text is stored, and v1 databases are upgraded', () async {
      // A database from before the look-back existed (schema v1).
      final old = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) => db.execute(
            'CREATE TABLE readings (id TEXT PRIMARY KEY, created_at INTEGER '
            'NOT NULL, spread TEXT NOT NULL, cards TEXT NOT NULL, '
            'interpretation TEXT NOT NULL, question TEXT, note TEXT)',
          ),
        ),
      );
      await old.close();
      final repo = SqliteHistoryRepository(path: dbPath);
      await repo.add(reading('a', DateTime(2026, 1, 1)));
      await repo.setRevisit('a', '  It went fine.  ');
      expect((await repo.load(deck)).single.revisit, 'It went fine.');
    });

    test('due only for Premium, 7 to 59 days old, once', () {
      final now = DateTime(2026, 10, 16);
      final s = AppState(deck: deck)..setPremium(true);
      final r = reading('a', now.subtract(const Duration(days: 8)));
      expect(s.revisitDue(r, now: now), isTrue);
      expect(
        s.revisitDue(
          reading('b', now.subtract(const Duration(days: 3))),
          now: now,
        ),
        isFalse,
      );
      expect(
        s.revisitDue(
          reading('c', now.subtract(const Duration(days: 90))),
          now: now,
        ),
        isFalse,
      );
      expect(s.revisitDue(r.withRevisit(''), now: now), isFalse);
      expect((AppState(deck: deck)).revisitDue(r, now: now), isFalse);
    });

    testWidgets('Read tab links to the reading; the answer is saved', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      final state = AppState(deck: deck, onboarded: true)..setPremium(true);
      state.history.add(
        reading('a', DateTime.now().subtract(const Duration(days: 8))),
      );
      await tester.pumpWidget(ShenTarotApp(initialState: state));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Look back at last week's reading"));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Since then...'),
        'It went fine.',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(state.history.single.revisit, 'It went fine.');
      expect(find.text('It went fine.'), findsOneWidget);
      expect(state.dueRevisit, isNull);
    });
  });

  group('AppState persistence', () {
    test('readings survive a restart and delete-all clears them', () async {
      final first = AppState(
        deck: deck,
        historyRepository: SqliteHistoryRepository(path: dbPath),
      );
      first.addReading(reading('a', DateTime(2026, 3, 1)));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final second = AppState(
        deck: deck,
        historyRepository: SqliteHistoryRepository(path: dbPath),
      );
      await second.loadPersisted();
      expect(second.history.map((r) => r.id), ['a']);

      await second.deleteAllData();
      final third = AppState(
        deck: deck,
        historyRepository: SqliteHistoryRepository(path: dbPath),
      );
      await third.loadPersisted();
      expect(third.history, isEmpty);
    });

    test(
      'onboarding and the daily free reading persist, and reset next day',
      () async {
        var now = DateTime(2026, 10, 16, 10);
        AppState make() => AppState(deck: deck, clock: () => now);
        final a = make();
        a.completeOnboarding();
        a.addReading(reading('a', now));
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final b = make();
        await b.loadPersisted();
        expect(b.onboarded, isTrue);
        expect(b.canStart(SpreadType.single), isFalse);

        now = DateTime(2026, 10, 17, 8);
        expect(b.canStart(SpreadType.single), isTrue);
      },
    );

    test('journal note and single delete update state', () {
      final s = AppState(deck: deck);
      s.addReading(reading('a', DateTime(2026, 1, 1)));
      s.setNote('a', 'hello');
      expect(s.history.single.note, 'hello');
      s.deleteReading('a');
      expect(s.history, isEmpty);
    });
  });

  group('reminder', () {
    test('turning on schedules at the chosen time and persists', () async {
      final fake = FakeReminders();
      final s = AppState(deck: deck, reminders: fake);
      expect(
        await s.setReminder(true, time: const TimeOfDay(hour: 20, minute: 30)),
        isTrue,
      );
      expect(fake.scheduled, const TimeOfDay(hour: 20, minute: 30));

      final again = AppState(deck: deck, reminders: fake);
      await again.loadPersisted();
      expect(again.reminderEnabled, isTrue);
      expect(again.reminderTime, const TimeOfDay(hour: 20, minute: 30));
    });

    test('denied permission leaves the reminder off', () async {
      final s = AppState(deck: deck, reminders: FakeReminders(allow: false));
      expect(await s.setReminder(true), isFalse);
      expect(s.reminderEnabled, isFalse);
    });

    test('turning off cancels', () async {
      final fake = FakeReminders();
      final s = AppState(deck: deck, reminders: fake);
      await s.setReminder(true);
      expect(await s.setReminder(false), isTrue);
      expect(fake.cancels, 1);
    });
  });

  group('screens', () {
    void tall(WidgetTester t) {
      t.view.physicalSize = const Size(1080, 5000);
      t.view.devicePixelRatio = 2.75;
      addTearDown(t.view.reset);
    }

    testWidgets('empty history offers to draw a card', (tester) async {
      tall(tester);
      await tester.pumpWidget(
        ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
      );
      await tester.pumpAndSettle();
      await goHistory(tester);
      expect(find.text('No readings yet'), findsOneWidget);
      expect(find.text('Draw your first card'), findsOneWidget);
    });

    testWidgets('free users see a locked journal; premium can save a note', (
      tester,
    ) async {
      tall(tester);
      final state = AppState(deck: deck, onboarded: true);
      state.addReading(reading('a', DateTime(2026, 5, 5)));
      await tester.pumpWidget(ShenTarotApp(initialState: state));
      await tester.pumpAndSettle();
      await goHistory(tester);
      await tester.tap(find.textContaining('Past, Present, Future'));
      await tester.pumpAndSettle();
      expect(find.text('Add a journal note (Premium)'), findsOneWidget);
      expect(find.text('Ask a follow-up'), findsNothing);
    });

    testWidgets('premium journal note is saved', (tester) async {
      tall(tester);
      final state = AppState(deck: deck, onboarded: true)..setPremium(true);
      state.addReading(reading('a', DateTime(2026, 5, 5)));
      await tester.pumpWidget(ShenTarotApp(initialState: state));
      await tester.pumpAndSettle();
      await goHistory(tester);
      await tester.tap(find.textContaining('Past, Present, Future'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My note');
      await tester.tap(find.text('Save note'));
      await tester.pump();
      expect(state.history.single.note, 'My note');
    });
  });

  group('follow-up questions', () {
    void tall(WidgetTester t) {
      t.view.physicalSize = const Size(1080, 5000);
      t.view.devicePixelRatio = 2.75;
      addTearDown(t.view.reset);
    }

    testWidgets('premium asks and sees the answer under the reading', (
      tester,
    ) async {
      tall(tester);
      final fake = FakeReadingService();
      final state = AppState(deck: deck, onboarded: true, readingService: fake)
        ..setPremium(true);
      state.addReading(reading('a', DateTime(2026, 5, 5)));
      await tester.pumpWidget(ShenTarotApp(initialState: state));
      await tester.pumpAndSettle();
      await goHistory(tester);
      await tester.tap(find.textContaining('Past, Present, Future'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ask a follow-up'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'What next?');
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();
      expect(find.text('Here is more to explore.'), findsOneWidget);
      expect(fake.calls.single['followUp'], 'What next?');
      expect(fake.calls.single['reading'], 'A reading.');
      expect(fake.calls.single['n'], 3);
    });

    testWidgets('premium draws a clarifier card not already in the reading', (
      tester,
    ) async {
      tall(tester);
      final fake = FakeReadingService();
      final state = AppState(deck: deck, onboarded: true, readingService: fake)
        ..setPremium(true);
      state.addReading(reading('a', DateTime(2026, 5, 5)));
      await tester.pumpWidget(ShenTarotApp(initialState: state));
      await tester.pumpAndSettle();
      await goHistory(tester);
      await tester.tap(find.textContaining('Past, Present, Future'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Draw a clarifier card'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Draw one for me'));
      await tester.pumpAndSettle();
      final id = fake.calls.single['clarifier'] as String;
      expect(['major_00_fool', 'cups_ace', 'swords_ten'], isNot(contains(id)));
      expect(
        find.textContaining('Clarifier: ${deck.byId(id)!.name}'),
        findsOneWidget,
      );
      expect(find.text('Here is more to explore.'), findsOneWidget);
    });

    testWidgets('free users are sent to the paywall', (tester) async {
      tall(tester);
      final state = AppState(deck: deck, onboarded: true);
      state.addReading(reading('a', DateTime(2026, 5, 5)));
      await tester.pumpWidget(ShenTarotApp(initialState: state));
      await tester.pumpAndSettle();
      await goHistory(tester);
      await tester.tap(find.textContaining('Past, Present, Future'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ask a follow-up (Premium)'));
      await tester.pumpAndSettle();
      expect(find.text('Unlock Premium'), findsOneWidget);
    });
  });
}
