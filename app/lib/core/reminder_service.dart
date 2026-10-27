import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../app/i18n.dart';
import 'analytics.dart';

/// Title and body of one scheduled notification.
typedef ReminderCopy = ({String title, String body});

/// Daily "your card" reminder. Local notifications only; nothing is sent to a
/// server. Notification permission is requested only when the user turns the
/// reminder on.
abstract class ReminderService {
  /// Schedules the daily reminder for the next two weeks (one notification a
  /// day, refreshed when the app opens). With [skipToday], none is sent today
  /// (the Card of the Day is already drawn). [copy] gives each day's text
  /// (for example naming the card waiting that day); without it a plain line
  /// is used. Returns false if permission was denied.
  Future<bool> enable(
    TimeOfDay time, {
    bool skipToday = false,
    ReminderCopy Function(DateTime day)? copy,
  });
  Future<void> disable();

  /// One-off "look back" nudge for a reading, about a week later. Only used
  /// when the daily reminder is on (permission already granted).
  Future<void> scheduleLookBack(String readingId, DateTime at);
  Future<void> cancelLookBack(String readingId);

  /// One-off reminder 2 days before a paid introductory period (e.g. the
  /// US$1.99 first month) ends and the full price is charged.
  Future<void> scheduleIntroEnding(DateTime at);
  Future<void> cancelIntroEnding();

  /// One quiet evening nudge when a streak would break today. Cancelled as
  /// soon as the user reads.
  Future<void> scheduleStreakNudge(DateTime at, ReminderCopy copy);
  Future<void> cancelStreakNudge();

  /// A one-off quiet note of [kind] (moon nights, the Sunday weekly recap).
  /// Scheduling a kind again replaces the earlier one.
  Future<void> scheduleNote(NoteKind kind, DateTime at, ReminderCopy copy);
  Future<void> cancelNote(NoteKind kind);

  /// Asks for notification permission without turning on the daily reminder.
  Future<bool> requestPermission();
}

const _introEndingId = 2;
const _streakNudgeId = 3;

/// One-off notes, each with its own notification id.
enum NoteKind {
  week(4),
  newMoon(5),
  fullMoon(6);

  const NoteKind(this.id);
  final int id;
}

/// Stable notification id for a reading's look-back (1 is the daily reminder).
int lookBackNotificationId(String readingId) =>
    1000 + (readingId.hashCode & 0x7fffff);

class NoopReminderService implements ReminderService {
  const NoopReminderService();
  @override
  Future<bool> enable(
    TimeOfDay time, {
    bool skipToday = false,
    ReminderCopy Function(DateTime day)? copy,
  }) async => false;
  @override
  Future<void> disable() async {}
  @override
  Future<void> scheduleLookBack(String readingId, DateTime at) async {}
  @override
  Future<void> cancelLookBack(String readingId) async {}
  @override
  Future<void> scheduleIntroEnding(DateTime at) async {}
  @override
  Future<void> cancelIntroEnding() async {}
  @override
  Future<void> scheduleStreakNudge(DateTime at, ReminderCopy copy) async {}
  @override
  Future<void> cancelStreakNudge() async {}
  @override
  Future<void> scheduleNote(
    NoteKind kind,
    DateTime at,
    ReminderCopy copy,
  ) async {}
  @override
  Future<void> cancelNote(NoteKind kind) async {}
  @override
  Future<bool> requestPermission() async => false;
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
      onDidReceiveNotificationResponse: (r) =>
          logEvent('push_open', {'kind': r.payload ?? 'unknown'}),
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

  /// Call at app start: registers the tap handler and logs an open when the
  /// app was launched from one of our notifications.
  Future<void> listenForOpens() async {
    await _init();
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      logEvent('push_open', {
        'kind': launch?.notificationResponse?.payload ?? 'unknown',
        'launch': true,
      });
    }
  }

  static const _days = 14;
  static const _firstDailyId = 100;

  @override
  Future<bool> requestPermission() async {
    await _init();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return (await ios?.requestPermissions(alert: true, sound: true)) ??
        (await android?.requestNotificationsPermission()) ??
        false;
  }

  @override
  Future<bool> enable(
    TimeOfDay time, {
    bool skipToday = false,
    ReminderCopy Function(DateTime day)? copy,
  }) async {
    if (!await requestPermission()) return false;

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
      final text =
          copy?.call(DateTime(day.year, day.month, day.day)) ??
          (
            title: tr('Your card of the day'),
            body: tr('Take a quiet moment with today\'s card.'),
          );
      await _plugin.zonedSchedule(
        id: _firstDailyId + d,
        title: text.title,
        body: text.body,
        payload: 'daily',
        scheduledDate: at,
        notificationDetails: NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            'daily_reminder',
            tr('Daily reminder'),
            channelDescription: tr('A once-a-day nudge to draw your card'),
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
      title: tr('Look back'),
      body: tr(
        'How did last week\'s reading turn out? Add a line to your journal.',
      ),
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      payload: 'look_back',
      notificationDetails: NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          'look_back',
          tr('Look back'),
          channelDescription: tr('A nudge a week after a reading'),
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
      title: tr('Your introductory offer ends in 2 days'),
      body: tr(
        'Premium then renews at the full price. You can manage or cancel in your store subscription settings.',
      ),
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      payload: 'billing',
      notificationDetails: NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          'billing_reminder',
          tr('Billing reminder'),
          channelDescription: tr('Before an introductory price ends'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelIntroEnding() async {
    await _init();
    await _plugin.cancel(id: _introEndingId);
  }

  @override
  Future<void> scheduleStreakNudge(DateTime at, ReminderCopy copy) async {
    if (!at.isAfter(DateTime.now())) return;
    await _init();
    await _plugin.zonedSchedule(
      id: _streakNudgeId,
      title: copy.title,
      body: copy.body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      payload: 'streak',
      notificationDetails: NotificationDetails(
        // Passive: no sound, does not light up the screen.
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.passive,
        ),
        android: AndroidNotificationDetails(
          'streak_nudge',
          tr('Streak reminder'),
          channelDescription: tr('One evening nudge when a streak would end'),
          importance: Importance.low,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelStreakNudge() async {
    await _init();
    await _plugin.cancel(id: _streakNudgeId);
  }

  @override
  Future<void> scheduleNote(
    NoteKind kind,
    DateTime at,
    ReminderCopy copy,
  ) async {
    await _init();
    await _plugin.cancel(id: kind.id);
    if (!at.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: kind.id,
      title: copy.title,
      body: copy.body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      payload: kind.name,
      notificationDetails: NotificationDetails(
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.passive,
        ),
        android: AndroidNotificationDetails(
          'notes',
          tr('Moon and weekly notes'),
          channelDescription: tr(
            'New and Full Moon nights, and your week in cards',
          ),
          importance: Importance.low,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelNote(NoteKind kind) async {
    await _init();
    await _plugin.cancel(id: kind.id);
  }
}
