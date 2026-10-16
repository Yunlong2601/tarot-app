import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';

/// Reminders: the daily card reminder and its time.
class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Daily card reminder'),
            subtitle: Text(
              state.reminderEnabled
                  ? 'Every day at ${state.reminderTime.format(context)}'
                  : 'Off',
            ),
            value: state.reminderEnabled,
            onChanged: (on) async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await state.setReminder(on);
              if (!ok && on) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Notifications are off for this app. Turn them on in your phone Settings.',
                    ),
                  ),
                );
              }
            },
          ),
          if (state.reminderEnabled)
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Reminder time'),
              subtitle: Text(state.reminderTime.format(context)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: state.reminderTime,
                );
                if (t != null) await state.setReminder(true, time: t);
              },
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No reminder is sent on days you have already drawn your Card '
              'of the Day.',
              style: TextStyle(color: AppColors.textMuted),
            ),
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
      appBar: AppBar(title: const Text('Reading settings')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.visibility_outlined),
            title: const Text('Look first'),
            subtitle: const Text(
              'Note what you see in the cards before the reading',
            ),
            value: state.lookFirst,
            onChanged: state.setLookFirst,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.flip_outlined),
            title: const Text('Auto-reveal cards'),
            subtitle: const Text(
              'Digital draws turn face up as soon as they land',
            ),
            value: state.autoReveal,
            onChanged: state.setAutoReveal,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.swap_vert),
            title: const Text('Reversed cards'),
            subtitle: const Text(
              'Digital draws and Card of the Day can come up upside down',
            ),
            value: state.readReversed,
            onChanged: state.setReadReversed,
          ),
        ],
      ),
    );
  }
}
