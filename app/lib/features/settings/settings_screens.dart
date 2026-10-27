import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../app/i18n.dart';

/// Reminders: the daily card reminder and its time.
class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Reminders'))),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(tr('Daily card reminder')),
            subtitle: Text(
              state.reminderEnabled
                  ? tr('Every day at {0}', [state.reminderTime.format(context)])
                  : 'Off',
            ),
            value: state.reminderEnabled,
            onChanged: (on) async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await state.setReminder(on);
              if (!ok && on) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      tr(
                        tr(
                          'Notifications are off for this app. Turn them on in your phone Settings.',
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          if (state.reminderEnabled)
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(tr('Reminder time')),
              subtitle: Text(state.reminderTime.format(context)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: state.reminderTime,
                );
                if (t != null) await state.setReminder(true, time: t);
              },
            ),
          if (state.reminderEnabled)
            SwitchListTile(
              key: const ValueKey('streak-nudge'),
              secondary: const Icon(Icons.local_fire_department_outlined),
              title: Text(tr('Streak reminder')),
              subtitle: Text(
                tr(
                  'One quiet evening note when a 3-day streak would end. Silent, no sound.',
                ),
              ),
              value: state.streakNudgeOn,
              onChanged: state.setStreakNudge,
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              tr(
                tr(
                  'No reminder is sent on days you have already drawn your Card of the Day.',
                ),
              ),
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          const Divider(),
          SwitchListTile(
            key: const ValueKey('billing-reminders'),
            secondary: const Icon(Icons.receipt_long_outlined),
            title: Text(tr('Before an intro price ends')),
            subtitle: Text(
              tr(
                'A heads-up 2 days before a first-month price ends and the full price starts.',
              ),
            ),
            value: state.billingReminders,
            onChanged: state.setBillingReminders,
          ),
          SwitchListTile(
            key: const ValueKey('offers-opt-in'),
            secondary: const Icon(Icons.campaign_outlined),
            title: Text(tr('Offers and news')),
            subtitle: Text(
              tr(
                'Occasional notifications about discounts and new features. Off unless you turn it on, and you can turn it off here any time.',
              ),
            ),
            value: state.offersOptIn,
            onChanged: (on) async {
              final messenger = ScaffoldMessenger.of(context);
              if (!await state.setOffersOptIn(on)) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      tr(
                        'Notifications are off for this app. Turn them on in your phone Settings.',
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Reading settings: Look first, auto-reveal, reversed cards.
class ReadingSettingsScreen extends StatelessWidget {
  const ReadingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Reading settings'))),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.visibility_outlined),
            title: Text(tr('Look first')),
            subtitle: Text(
              tr('Note what you see in the cards before the reading'),
            ),
            value: state.lookFirst,
            onChanged: state.setLookFirst,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.flip_outlined),
            title: Text(tr('Auto-reveal cards')),
            subtitle: Text(
              tr('Digital draws turn face up as soon as they land'),
            ),
            value: state.autoReveal,
            onChanged: state.setAutoReveal,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.swap_vert),
            title: Text(tr('Reversed cards')),
            subtitle: Text(
              tr('Digital draws and Card of the Day can come up upside down'),
            ),
            value: state.readReversed,
            onChanged: state.setReadReversed,
          ),
        ],
      ),
    );
  }
}
