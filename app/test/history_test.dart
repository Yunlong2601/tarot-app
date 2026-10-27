import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/core/reading_service.dart';
import 'package:shentarot/core/reminder_service.dart';
import 'package:shentarot/core/subscription_service.dart';
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

  bool? skippedToday;
  @override
  Future<bool> requestPermission() async => allow;

  ReminderCopy Function(DateTime day)? copy;
  @override
  Future<bool> enable(
    TimeOfDay time, {
    bool skipToday = false,
    ReminderCopy Function(DateTime day)? copy,
  }) async {
    if (!allow) return false;
    scheduled = time;
    skippedToday = skipToday;
    this.copy = copy;
    return true;
  }

  @override
  Future<void> disable() async => cancels++;

  final lookBacks = <String, DateTime>{};
  @override
  Future<void> scheduleLookBack(String readingId, DateTime at) async =>
      lookBacks[readingId] = at;
  @override
  Future<void> cancelLookBack(String readingId) async =>
      lookBacks.remove(readingId);

  DateTime? introReminder;
  @override
  Future<void> scheduleIntroEnding(DateTime at) async => introReminder = at;
  @override
  Future<void> cancelIntroEnding() async => introReminder = null;

  DateTime? streakNudge;
  ReminderCopy? streakCopy;
  @override
  Future<void> scheduleStreakNudge(DateTime at, ReminderCopy copy) async {
    streakNudge = at;
    streakCopy = copy;
  }

  @override
  Future<void> cancelStreakNudge() async => streakNudge = null;
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

    test('7 to 59 days old, once; free users get one look back', () {
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
      // Free: the first look back is open, then no more.
      final free = AppState(deck: deck);
      expect(free.revisitDue(r, now: now), isTrue);
      free.addReading(reading('old', now.subtract(const Duration(days: 9))));
      free.setRevisit('old', 'It went fine.');
      expect(free.revisitDue(r, now: now), isFalse);
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
        a.addReading(reading('b', now));
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
    test('the daily push names the card that will be drawn that day', () async {
      final fake = FakeReminders();
      final now = DateTime(2026, 10, 20, 7);
      final s = AppState(deck: deck, reminders: fake, clock: () => now);
      await s.setReminder(true);
      final today = DateTime(2026, 10, 20);
      final copy = fake.copy!(today);
      final planned = s.plannedCard(today);
      expect('${copy.title} ${copy.body}', contains(planned.name));
      expect(s.drawDailyCard().card.id, planned.id);
      // The wording rotates from day to day.
      final titles = {
        for (var d = 0; d < 5; d++)
          fake.copy!(today.add(Duration(days: d))).title,
      };
      expect(titles.length, greaterThan(1));
    });

    test('streak nudge: only when tonight would really break the streak', () async {
      final fake = FakeReminders();
      // Mon 19 Oct 2026 starts the week. Read Sat, Sun, Mon.
      var now = DateTime(2026, 10, 20, 9);
      final s = AppState(deck: deck, reminders: fake, clock: () => now);
      await s.setReminder(true);
      for (final d in [17, 18, 19]) {
        s.addReading(reading('r$d', DateTime(2026, 10, d, 12)));
      }
      await s.refreshReminders();
      // This week's rest day would cover today: no nudge.
      expect(fake.streakNudge, isNull);
      // Rest Tue, read Wed. On Thursday the rest day is used up.
      s.addReading(reading('r21', DateTime(2026, 10, 21, 12)));
      now = DateTime(2026, 10, 22, 9);
      await s.refreshReminders();
      expect(fake.streakNudge, DateTime(2026, 10, 22, 20));
      expect(fake.streakCopy!.title, contains('4'));
      s.addReading(reading('r22', DateTime(2026, 10, 22, 10)));
      await Future<void>.delayed(Duration.zero);
      expect(fake.streakNudge, isNull);
      await s.setStreakNudge(false);
      expect(fake.streakNudge, isNull);
    });

    test('after a reading: reminder offer first, rating after the 3rd', () {
      final s = AppState(deck: deck);
      expect(s.afterReadingAsk, AfterReadingAsk.none);
      s.addReading(reading('a', DateTime(2026, 10, 1)));
      expect(s.afterReadingAsk, AfterReadingAsk.reminder);
      s.markReminderAsked();
      expect(s.afterReadingAsk, AfterReadingAsk.none);
      s.addReading(reading('b', DateTime(2026, 10, 2)));
      s.addReading(reading('c', DateTime(2026, 10, 3)));
      expect(s.afterReadingAsk, AfterReadingAsk.review);
      s.markReviewAsked();
      expect(s.afterReadingAsk, AfterReadingAsk.none);
    });

    test('billing reminder can be turned off and back on', () async {
      final fake = FakeReminders();
      final subs = _IntroSubs(DateTime(2099, 11, 17, 10));
      final s = AppState(deck: deck, reminders: fake, subscriptions: subs);
      await s.setReminder(true);
      s.setPremium(true);
      await Future<void>.delayed(Duration.zero);
      expect(fake.introReminder, isNotNull);
      await s.setBillingReminders(false);
      expect(fake.introReminder, isNull);
      await s.setBillingReminders(true);
      expect(fake.introReminder, DateTime(2099, 11, 15, 10));
    });

    test('the day after the first reading, the reminder follows it up', () async {
      final fake = FakeReminders();
      final s = AppState(deck: deck, reminders: fake)
        ..setFocus('work', 'stuck');
      await s.setReminder(true);
      s.addReading(reading('a', DateTime(2026, 10, 20, 12)));
      await Future<void>.delayed(Duration.zero);
      final next = fake.copy!(DateTime(2026, 10, 21));
      expect(next.title, "Yesterday's reading about work");
      // Other days still name the planned card.
      final later = fake.copy!(DateTime(2026, 10, 22));
      expect(later.title, isNot(contains('Yesterday')));
    });

    test('focus answers go with readings; skipping sends nothing', () {
      final s = AppState(deck: deck);
      expect(s.focusPayload, isNull);
      s.setFocus('love', null);
      expect(s.focusPayload, {'area': 'love'});
    });

    test('first-reading offer: offer arm only, first reading, until closed', () {
      final s = AppState(deck: deck)..testArm = 'offer';
      final r = reading('a', DateTime(2026, 10, 20));
      s.addReading(r);
      expect(s.showsFirstOffer(r), isTrue);
      s.dismissFirstOffer();
      expect(s.showsFirstOffer(r), isFalse);
      final holdout = AppState(deck: deck)..testArm = 'holdout';
      holdout.addReading(r);
      expect(holdout.showsFirstOffer(r), isFalse);
      final second = AppState(deck: deck)..testArm = 'offer';
      second.addReading(reading('x', DateTime(2026, 10, 19)));
      second.addReading(r);
      expect(second.showsFirstOffer(r), isFalse);
    });

    test('offers stay off until the user turns them on', () async {
      final s = AppState(deck: deck, reminders: FakeReminders(allow: false));
      expect(s.offersOptIn, isFalse);
      expect(await s.setOffersOptIn(true), isFalse); // permission refused
      expect(s.offersOptIn, isFalse);
    });

    test('no reminder today once the Card of the Day is drawn', () async {
      final fake = FakeReminders();
      final s = AppState(deck: deck, reminders: fake);
      await s.setReminder(true);
      expect(fake.skippedToday, isFalse);
      s.drawDailyCard();
      await Future<void>.delayed(Duration.zero);
      expect(fake.skippedToday, isTrue);
    });

    test('a reminder 2 days before a paid first month ends', () async {
      final fake = FakeReminders();
      final subs = _IntroSubs(DateTime(2026, 11, 17, 10));
      final s = AppState(deck: deck, reminders: fake, subscriptions: subs);
      await s.setReminder(true);
      s.setPremium(true);
      await Future<void>.delayed(Duration.zero);
      expect(fake.introReminder, DateTime(2026, 11, 15, 10));
    });

    test(
      'Premium readings get a look-back nudge 7 days later; saving cancels it',
      () async {
        final fake = FakeReminders();
        final s = AppState(deck: deck, reminders: fake)..setPremium(true);
        await s.setReminder(true, time: const TimeOfDay(hour: 20, minute: 30));
        s.addReading(reading('a', DateTime(2026, 10, 1, 9)));
        expect(fake.lookBacks['a'], DateTime(2026, 10, 8, 20, 30));
        s.setRevisit('a', 'It went well.');
        await Future<void>.delayed(Duration.zero);
        expect(fake.lookBacks, isEmpty);
      },
    );

    test('no nudge for free users or with the reminder off', () async {
      final fake = FakeReminders();
      final free = AppState(deck: deck, reminders: fake);
      await free.setReminder(true);
      free.addReading(reading('a', DateTime(2026, 10, 1)));
      final off = AppState(deck: deck, reminders: fake)..setPremium(true);
      off.addReading(reading('b', DateTime(2026, 10, 1)));
      expect(fake.lookBacks, isEmpty);
    });

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

    testWidgets('free users can write a journal note', (tester) async {
      tall(tester);
      final state = AppState(deck: deck, onboarded: true);
      state.addReading(reading('a', DateTime(2026, 5, 5)));
      await tester.pumpWidget(ShenTarotApp(initialState: state));
      await tester.pumpAndSettle();
      await goHistory(tester);
      await tester.tap(find.textContaining('Past, Present, Future'));
      await tester.pumpAndSettle();
      expect(find.text('Ask a follow-up (Premium)'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('journal-input')),
        'My note',
      );
      await tester.tap(find.text('Save note'));
      await tester.pump();
      expect(state.history.single.note, 'My note');
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
      await tester.enterText(
        find.byKey(const ValueKey('journal-input')),
        'My note',
      );
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
      await tester.enterText(
        find.byKey(const ValueKey('followup-input')),
        'What next?',
      );
      await tester.tap(find.byKey(const ValueKey('followup-send')));
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

class _IntroSubs extends UnconfiguredSubscriptionService {
  const _IntroSubs(this.end);
  final DateTime end;
  @override
  Future<DateTime?> introEndsAt() async => end;
}
