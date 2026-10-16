import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily "your card" reminder. Local notifications only; nothing is sent to a
/// server. Notification permission is requested only when the user turns the
/// reminder on.
abstract class ReminderService {
  /// Schedules a daily reminder. Returns false if the user denied permission.
  Future<bool> enable(TimeOfDay time);
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
  Future<bool> enable(TimeOfDay time) async => false;
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

  @override
  Future<bool> enable(TimeOfDay time) async {
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

    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _id,
      title: 'Your daily card',
      body: 'Take a quiet moment for today\'s reading.',
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
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }

  @override
  Future<void> disable() async {
    await _init();
    await _plugin.cancel(id: _id);
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
