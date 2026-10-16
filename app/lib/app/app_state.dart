import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/install_id.dart';
import '../core/reading_service.dart';
import '../core/reminder_service.dart';
import '../core/subscription_service.dart';
import '../data/deck.dart';
import '../data/history_repository.dart';
import '../data/models.dart';

enum ReadMode { photo, digital }

/// App-wide state: onboarding, premium, today's free reading, saved history
/// (on device only) and the daily reminder.
class AppState extends ChangeNotifier {
  AppState({
    required this.deck,
    this.onboarded = false,
    this.readingService = const UnconfiguredReadingService(),
    this.subscriptions = const UnconfiguredSubscriptionService(),
    HistoryRepository? historyRepository,
    this.reminders = const NoopReminderService(),
    DateTime Function()? clock,
  }) : _repo = historyRepository ?? InMemoryHistoryRepository(),
       _clock = clock ?? DateTime.now;

  final Deck deck;
  final ReadingService readingService;
  final SubscriptionService subscriptions;
  final ReminderService reminders;
  final HistoryRepository _repo;
  final DateTime Function() _clock;

  bool onboarded;

  /// Spread chosen on the Read tab / Library; shared by photo and digital readings.
  SpreadType selectedSpread = SpreadType.single;

  /// The question typed on the Ask screen for the reading in progress.
  String draftQuestion = '';

  /// Whether the one-time free reading of a longer spread has been used.
  bool trialUsed = false;

  /// The Read tab's main button: scan a physical deck or draw digitally.
  ReadMode readMode = ReadMode.photo;
  bool isPremium = false;
  static const freeReadingsPerDay = 1;
  final List<Reading> history = [];

  /// Whether digital draws and the Card of the Day may come up reversed.
  bool readReversed = true;

  /// Whether to ask what you notice in the cards before the AI reading.
  /// Off in the constructor so tests stay simple; loadPersisted defaults it on.
  bool lookFirst = false;

  // Card of the Day: one free card per local day, drawn on the phone.
  String _dailyDate = '';
  String? _dailyId;
  bool _dailyReversed = false;

  bool reminderEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);

  // Local mirror of today's free-reading count. The backend enforces the real
  // limit; this only drives the UI.
  String _usedDay = '';
  int _usedCount = 0;

  static const _kOnboarded = 'onboarded';
  static const _kUsedDay = 'free_used_day';
  static const _kUsedCount = 'free_used_count';
  static const _kTrial = 'trial_used';
  static const _kReversed = 'read_reversed';
  static const _kLookFirst = 'look_first';
  static const _kDailyDate = 'daily_date';
  static const _kDailyId = 'daily_id';
  static const _kDailyRev = 'daily_reversed';
  static const _kReminderOn = 'reminder_on';
  static const _kReminderMin = 'reminder_minutes';

  String get _today {
    final d = _clock();
    return '${d.year}-${d.month}-${d.day}';
  }

  int get freeReadingsUsedToday => _usedDay == _today ? _usedCount : 0;

  bool get canReadForFree => freeReadingsUsedToday < freeReadingsPerDay;

  /// Premium users are unlimited; free users get one single-card reading a day.
  bool canStart(SpreadType spread) {
    if (isPremium) return true;
    if (!canReadForFree) return false;
    return spread.isFree || !trialUsed;
  }

  /// True when this spread would use the one-time free trial reading.
  bool usesTrial(SpreadType spread) =>
      !isPremium && !spread.isFree && !trialUsed;

  /// Loads saved history and settings. Failures leave the app usable.
  Future<void> loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      onboarded = prefs.getBool(_kOnboarded) ?? onboarded;
      _usedDay = prefs.getString(_kUsedDay) ?? '';
      _usedCount = prefs.getInt(_kUsedCount) ?? 0;
      trialUsed = prefs.getBool(_kTrial) ?? false;
      readReversed = prefs.getBool(_kReversed) ?? true;
      lookFirst = prefs.getBool(_kLookFirst) ?? true;
      _dailyDate = prefs.getString(_kDailyDate) ?? '';
      _dailyId = prefs.getString(_kDailyId);
      _dailyReversed = prefs.getBool(_kDailyRev) ?? false;
      reminderEnabled = prefs.getBool(_kReminderOn) ?? false;
      final m = prefs.getInt(_kReminderMin);
      if (m != null) reminderTime = TimeOfDay(hour: m ~/ 60, minute: m % 60);
    } catch (e) {
      debugPrint('Could not load settings: $e');
    }
    try {
      history
        ..clear()
        ..addAll(await _repo.load(deck));
    } catch (e) {
      debugPrint('Could not load history: $e');
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboarded, onboarded);
      await prefs.setString(_kUsedDay, _usedDay);
      await prefs.setInt(_kUsedCount, _usedCount);
      await prefs.setBool(_kTrial, trialUsed);
      await prefs.setBool(_kReversed, readReversed);
      await prefs.setBool(_kLookFirst, lookFirst);
      await prefs.setString(_kDailyDate, _dailyDate);
      if (_dailyId != null) await prefs.setString(_kDailyId, _dailyId!);
      await prefs.setBool(_kDailyRev, _dailyReversed);
      await prefs.setBool(_kReminderOn, reminderEnabled);
      await prefs.setInt(
        _kReminderMin,
        reminderTime.hour * 60 + reminderTime.minute,
      );
    } catch (e) {
      debugPrint('Could not save settings: $e');
    }
  }

  /// Starts the store SDK. A failure must not block the app: the user simply
  /// stays on the free tier until it works.
  Future<void> startSubscriptions() async {
    try {
      await subscriptions.start(await loadInstallId(), setPremium);
    } catch (e) {
      debugPrint('Subscriptions failed to start: $e');
    }
  }

  void setDraftQuestion(String q) {
    draftQuestion = q.trim();
  }

  void selectSpread(SpreadType s) {
    selectedSpread = s;
    notifyListeners();
  }

  void setReadMode(ReadMode m) {
    readMode = m;
    notifyListeners();
  }

  void setLookFirst(bool value) {
    lookFirst = value;
    _savePrefs();
    notifyListeners();
  }

  void setReadReversed(bool value) {
    readReversed = value;
    _savePrefs();
    notifyListeners();
  }

  /// Today's card if one has been drawn, else null.
  DrawnCard? get dailyCardIfDrawn {
    final id = _dailyId;
    if (id == null || _dailyDate != _today) return null;
    final card = deck.byId(id);
    return card == null
        ? null
        : DrawnCard(card: card, reversed: _dailyReversed);
  }

  /// Draws today's card once; later calls on the same day return the same card.
  /// No network and no AI: the text shown is the stored card knowledge.
  /// [notify] false is for calls made while a widget is building.
  DrawnCard drawDailyCard([Random? random, bool notify = true]) {
    final existing = dailyCardIfDrawn;
    if (existing != null) return existing;
    final r = random ?? Random.secure();
    final card = deck.cards[r.nextInt(deck.cards.length)];
    _dailyDate = _today;
    _dailyId = card.id;
    _dailyReversed = readReversed && r.nextDouble() < 0.25;
    _savePrefs();
    if (notify) notifyListeners();
    return DrawnCard(card: card, reversed: _dailyReversed);
  }

  /// Re-notifies listeners (used after a draw made during a widget build).
  void notifyChanged() => notifyListeners();

  void completeOnboarding() {
    onboarded = true;
    _savePrefs();
    notifyListeners();
  }

  void setPremium(bool value) {
    if (isPremium == value) return;
    isPremium = value;
    notifyListeners();
  }

  void addReading(Reading reading) {
    history.insert(0, reading);
    if (!isPremium) {
      if (!reading.spread.isFree) trialUsed = true;
      _usedCount = freeReadingsUsedToday + 1;
      _usedDay = _today;
      _savePrefs();
    }
    _guard(() => _repo.add(reading));
    notifyListeners();
  }

  /// Journal note (Premium feature; the UI gates it).
  void setNote(String id, String? note) {
    final i = history.indexWhere((r) => r.id == id);
    if (i < 0) return;
    history[i] = history[i].withNote(note);
    _guard(() => _repo.setNote(id, note));
    notifyListeners();
  }

  /// Look back about a week later (Premium): saves what the user writes, or
  /// '' to dismiss the prompt for this reading.
  void setRevisit(String id, String text) {
    final i = history.indexWhere((r) => r.id == id);
    if (i < 0) return;
    history[i] = history[i].withRevisit(text);
    _guard(() => _repo.setRevisit(id, text));
    notifyListeners();
  }

  /// Whether [r] is old enough (7+ days) and recent enough (under 60) to ask
  /// "how did this turn out?", and has not been answered or dismissed.
  bool revisitDue(Reading r, {DateTime? now}) {
    if (!isPremium || r.revisit != null) return false;
    final age = (now ?? DateTime.now()).difference(r.createdAt);
    return age.inDays >= 7 && age.inDays < 60;
  }

  /// The newest reading waiting for a look-back, if any.
  Reading? get dueRevisit => history.where(revisitDue).firstOrNull;

  void deleteReading(String id) {
    history.removeWhere((r) => r.id == id);
    _guard(() => _repo.delete(id));
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    history.clear();
    notifyListeners();
    await _guard(_repo.clear);
  }

  /// Turns the daily reminder on or off. Returns false if the user denied the
  /// notification permission (the setting then stays off).
  Future<bool> setReminder(bool on, {TimeOfDay? time}) async {
    if (time != null) reminderTime = time;
    if (on) {
      final ok = await reminders.enable(reminderTime);
      reminderEnabled = ok;
    } else {
      await reminders.disable();
      reminderEnabled = false;
    }
    await _savePrefs();
    notifyListeners();
    return reminderEnabled == on;
  }

  Future<void> _guard(Future<void> Function() op) async {
    try {
      await op();
    } catch (e) {
      debugPrint('History storage error: $e');
    }
  }
}
