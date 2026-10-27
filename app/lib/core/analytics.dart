import 'dart:async';

import 'package:flutter/foundation.dart';

/// Sends a batch of events to our server.
abstract class EventSink {
  Future<void> sendEvents(String variant, List<Map<String, Object?>> events);
}

/// Anonymous product events (funnel steps) sent to our own server only: no
/// third-party SDK, no question or reading text, keyed by the install id. The
/// server keeps only names on its allow-list (backend/src/events.ts) for 180
/// days. Users can turn it off in Settings.
class Analytics {
  Analytics._();
  static final instance = Analytics._();

  EventSink? sink;

  /// The test arm this install is in; "control" until a test runs.
  String variant = 'control';
  bool enabled = true;

  final _queue = <Map<String, Object?>>[];
  Timer? _timer;
  static const _batch = 20;

  /// Queues an event; sent within about 10 seconds, or at once when 20 wait.
  void log(String name, [Map<String, Object> props = const {}]) {
    if (!enabled || sink == null) return;
    _queue.add({
      'name': name,
      'at': DateTime.now().millisecondsSinceEpoch,
      if (props.isNotEmpty) 'props': props,
    });
    if (_queue.length >= _batch) {
      flush();
    } else {
      _timer ??= Timer(const Duration(seconds: 10), flush);
    }
  }

  /// Sends what is queued. Failures drop the batch: events are nice to have
  /// and must never slow the app or pile up.
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    final s = sink;
    if (s == null || _queue.isEmpty) return;
    final batch = _queue.take(_batch).toList();
    _queue.removeRange(0, batch.length);
    try {
      await s.sendEvents(variant, batch);
    } catch (e) {
      debugPrint('Events not sent: $e');
    }
    if (_queue.isNotEmpty) _timer ??= Timer(const Duration(seconds: 10), flush);
  }

  /// Drops anything queued (used when the user turns sharing off).
  void clear() {
    _timer?.cancel();
    _timer = null;
    _queue.clear();
  }
}

/// Shorthand for [Analytics.instance.log].
void logEvent(String name, [Map<String, Object> props = const {}]) =>
    Analytics.instance.log(name, props);
