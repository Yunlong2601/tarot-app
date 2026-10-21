import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily "your card" reminder. Local notifications only; nothing is sent to a
/// server. Notification permission is requested only when the user turns the
/// reminder on.
abstract class ReminderService {
  /// Schedules the daily reminder for the next two weeks (one notification a
  /// day, refreshed when the app opens). With [skipToday], none is sent today
  /// (the Card of the Day is already drawn). Returns false if permission was
  /// denied.
  Future<bool> enable(TimeOfDay time, {bool skipToday = false});
  Future<void> disable();

  /// One-off "look back" nudge for a reading, about a week later. Only used
  /// when the daily reminder is on (permission already granted).
  Future<void> scheduleLookBack(String readingId, DateTime at);
  Future<void> cancelLookBack(String readingId);

  /// One-off reminder 2 days before a paid introductory period (e.g. the
  /// US$1.99 first month) ends and the full price is charged.
  Future<void> scheduleIntroEnding(DateTime at);
}

const _introEndingId = 2;

/// Stable notification id for a reading's look-back (1 is the daily reminder).
int lookBackNotificationId(String readingId) =>
    1000 + (readingId.hashCode & 0x7fffff);

class NoopReminderService implements ReminderService {
  const NoopReminderService();
  @override
  Future<bool> enable(TimeOfDay time, {bool skipToday = false}) async => false;
  @override
  Future<void> disable() async {}
  @override
  Future<void> scheduleLookBack(String readingId, DateTime at) async {}
  @override
  Future<void> cancelLookBack(String readingId) async {}
  @override
  Future<void> scheduleIntroEnding(DateTime at) async {}
}

class LocalNotificationReminderService implements ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  static const _id = 1;

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier),
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  static const _days = 14;
  static const _firstDailyId = 100;

  @override
  Future<bool> enable(TimeOfDay time, {bool skipToday = false}) async {
    await _init();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted =
        (await ios?.requestPermissions(alert: true, sound: true)) ??
        (await android?.requestNotificationsPermission()) ??
        false;
    if (!granted) return false;

    await _cancelDaily();
    final now = tz.TZDateTime.now(tz.local);
    for (var d = 0; d < _days; d++) {
      final day = now.add(Duration(days: d));
      final at = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );
      if (d == 0 && (skipToday || !at.isAfter(now))) continue;
      await _plugin.zonedSchedule(
        id: _firstDailyId + d,
        title: 'Your card of the day',
        body: 'Take a quiet moment with today\'s card.',
        scheduledDate: at,
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily reminder',
            channelDescription: 'A once-a-day nudge to draw your card',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    return true;
  }

  Future<void> _cancelDaily() async {
    await _plugin.cancel(id: _id); // the old repeating reminder
    for (var d = 0; d < _days; d++) {
      await _plugin.cancel(id: _firstDailyId + d);
    }
  }

  @override
  Future<void> disable() async {
    await _init();
    await _cancelDaily();
  }

  @override
  Future<void> scheduleLookBack(String readingId, DateTime at) async {
    await _init();
    await _plugin.zonedSchedule(
      id: lookBackNotificationId(readingId),
      title: 'Look back',
      body:
          'How did last week\'s reading turn out? Add a line to your journal.',
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          'look_back',
          'Look back',
          channelDescription: 'A nudge a week after a reading',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelLookBack(String readingId) async {
    await _init();
    await _plugin.cancel(id: lookBackNotificationId(readingId));
  }

  @override
  Future<void> scheduleIntroEnding(DateTime at) async {
    if (!at.isAfter(DateTime.now())) return;
    await _init();
    await _plugin.zonedSchedule(
      id: _introEndingId,
      title: 'Your first month ends in 2 days',
      body:
          'Premium then renews at the yearly price. You can manage or cancel '
          'in your store subscription settings.',
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          'billing_reminder',
          'Billing reminder',
          channelDescription: 'Before an introductory price ends',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
