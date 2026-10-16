import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/install_id.dart';
import '../core/reading_service.dart';
import '../core/reminder_service.dart';
import '../core/subscription_service.dart';
import '../data/deck.dart';
import '../data/history_repository.dart';
import '../data/models.dart';

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
  })  : _repo = historyRepository ?? InMemoryHistoryRepository(),
        _clock = clock ?? DateTime.now;

  final Deck deck;
  final ReadingService readingService;
  final SubscriptionService subscriptions;
  final ReminderService reminders;
  final HistoryRepository _repo;
  final DateTime Function() _clock;

  bool onboarded;
  bool isPremium = false;
  static const freeReadingsPerDay = 1;
  final List<Reading> history = [];

  bool reminderEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);

  // Local mirror of today's free-reading count. The backend enforces the real
  // limit; this only drives the UI.
  String _usedDay = '';
  int _usedCount = 0;

  static const _kOnboarded = 'onboarded';
  static const _kUsedDay = 'free_used_day';
  static const _kUsedCount = 'free_used_count';
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
    return !spread.isPremium && canReadForFree;
  }

  /// Loads saved history and settings. Failures leave the app usable.
  Future<void> loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      onboarded = prefs.getBool(_kOnboarded) ?? onboarded;
      _usedDay = prefs.getString(_kUsedDay) ?? '';
      _usedCount = prefs.getInt(_kUsedCount) ?? 0;
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
      await prefs.setBool(_kReminderOn, reminderEnabled);
      await prefs.setInt(
          _kReminderMin, reminderTime.hour * 60 + reminderTime.minute);
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
