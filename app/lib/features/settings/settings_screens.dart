import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../app/i18n.dart';
import '../../app/brand.dart';
import '../../app/deck_theme.dart';
import '../../core/analytics.dart';
import '../onboarding/focus_questions.dart';
import '../paywall/out_of_credits.dart';

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

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
          if (state.reminderEnabled)
            SwitchListTile(
              key: const ValueKey('moon-notes'),
              secondary: const Icon(Icons.nightlight_outlined),
              title: Text(tr('New and Full Moon')),
              subtitle: Text(
                tr('A quiet note on moon nights, with a spread for each.'),
              ),
              value: state.moonNotes,
              onChanged: state.setMoonNotes,
            ),
          if (state.reminderEnabled)
            SwitchListTile(
              key: const ValueKey('weekly-notes'),
              secondary: const Icon(Icons.calendar_view_week_outlined),
              title: Text(tr('Your week in cards')),
              subtitle: Text(
                tr(
                  'A Sunday evening note when you read at least twice that week.',
                ),
              ),
              value: state.weeklyNotes,
              onChanged: state.setWeeklyNotes,
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
          ListTile(
            key: const ValueKey('your-focus'),
            leading: const Icon(Icons.center_focus_weak),
            title: Text(tr('Your focus')),
            subtitle: Text(
              [
                if (state.focusArea case final a?) focusAreaLabel(a),
                if (state.focusFeeling case final f?) focusFeelingLabel(f),
              ].join(' · ').ifEmpty(tr('Not set')),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/focus'),
          ),
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
          const DeckThemePicker(),
        ],
      ),
    );
  }
}

/// The card backs: Classic gold for everyone, four more with Premium.
class DeckThemePicker extends StatelessWidget {
  const DeckThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final current = state.activeDeckTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Card backs'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (!state.isPremium)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                tr('More card backs come with Premium'),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 136,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final t in DeckTheme.values)
                  _ThemeChoice(
                    theme: t,
                    selected: t == current,
                    locked: t.isPremium && !state.isPremium,
                    onTap: () {
                      if (t.isPremium && !state.isPremium) {
                        logEvent('deck_theme', {'locked': t.name});
                        openPaywall(context);
                        return;
                      }
                      logEvent('deck_theme', {'set': t.name});
                      state.setDeckTheme(t);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.theme,
    required this.selected,
    required this.locked,
    required this.onTap,
  });
  final DeckTheme theme;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: locked ? tr('{0}, Premium', [theme.label]) : theme.label,
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.gold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CardBack(width: 52, theme: theme),
                if (locked)
                  const Icon(Icons.lock, size: 18, color: AppColors.ink),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              theme.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
