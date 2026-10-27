import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../app/app_state.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../core/analytics.dart';

/// Runs when the user closes a reading: at most one gentle ask. After the
/// first reading, offer the daily card reminder (the moment its value is
/// clear); after the 3rd and 10th, Apple's own rating prompt (never a custom
/// one, App Review Guideline 5.6.1).
Future<void> afterReadingClosed(BuildContext context, AppState state) async {
  switch (state.afterReadingAsk) {
    case AfterReadingAsk.reminder:
      state.markReminderAsked();
      await offerReminder(context, state);
    case AfterReadingAsk.review:
      state.markReviewAsked();
      logEvent('review_prompt', {'n': state.history.length});
      try {
        final review = InAppReview.instance;
        if (await review.isAvailable()) await review.requestReview();
      } catch (e) {
        debugPrint('Review prompt failed: $e');
      }
    case AfterReadingAsk.none:
      break;
  }
}

/// "Get your card of the day each morning?" with a time preset to 8:00.
/// Notification permission is asked only if the user says yes.
Future<void> offerReminder(BuildContext context, AppState state) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final time = await showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _ReminderSheet(),
  );
  logEvent('reminder_prompt', {'accepted': time != null});
  if (time == null) return;
  final ok = await state.setReminder(true, time: time);
  if (!ok) {
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          tr(
            'Notifications are off for this app. Turn them on in your phone Settings.',
          ),
        ),
      ),
    );
  }
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet();

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wb_twilight, color: AppColors.gold, size: 32),
          const SizedBox(height: 12),
          Text(
            tr('Get your card of the day each morning?'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            tr(
              'One quiet notification a day, naming the card waiting for you. Turn it off any time in Settings.',
            ),
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          ListTile(
            key: const ValueKey('reminder-time'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule, color: AppColors.gold),
            title: Text(tr('Remind me at')),
            trailing: Text(
              _time.format(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (t != null) setState(() => _time = t);
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('reminder-yes'),
              onPressed: () => Navigator.pop(context, _time),
              child: Text(tr('Yes, remind me')),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('Not now')),
            ),
          ),
        ],
      ),
    ),
  );
}
