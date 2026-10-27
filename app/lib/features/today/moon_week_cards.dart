import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../core/analytics.dart';
import '../../core/moon.dart';
import '../../data/spreads.dart';
import '../collection/insights.dart';

/// On a New or Full Moon day: the moon's spread, one tap away.
class MoonCard extends StatelessWidget {
  const MoonCard({super.key, this.now});

  /// For tests; defaults to the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final phase = moonPhaseOn(now ?? DateTime.now());
    if (phase == null) return const SizedBox.shrink();
    final state = AppScope.of(context);
    final spread = phase.full ? SpreadType.fullMoon : SpreadType.newMoon;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const ValueKey('moon-card'),
        child: ListTile(
          leading: Icon(
            phase.full ? Icons.brightness_1 : Icons.brightness_1_outlined,
            color: AppColors.gold,
          ),
          title: Text(
            phase.full ? tr('Full Moon tonight') : tr('New Moon tonight'),
          ),
          subtitle: Text(
            spread.blurb,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            logEvent('moon_card', {'full': phase.full});
            state
              ..setReadMode(ReadMode.digital)
              ..setDraftQuestion('')
              ..selectSpread(spread);
            context.push('/digital');
          },
        ),
      ),
    );
  }
}

/// "Your week in cards", Sunday to Tuesday, after 2 or more readings.
class WeekCard extends StatelessWidget {
  const WeekCard({super.key, this.now});

  final DateTime? now;

  static String _group(String g) => switch (g) {
    'major' => tr('Major Arcana'),
    'wands' => tr('Wands'),
    'cups' => tr('Cups'),
    'swords' => tr('Swords'),
    _ => tr('Pentacles'),
  };

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final week = weekToShow(state.history, now ?? DateTime.now());
    if (week == null) return const SizedBox.shrink();
    final r = week.recap;
    final top = r.topCards.firstOrNull;
    final mostly =
        (r.groups.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .first;
    final lines = [
      week.thisWeek
          ? tr('{0} readings this week', [r.readings])
          : tr('{0} readings last week', [r.readings]),
      if (top != null) tr('{0} came up {1} times', [top.$1.name, top.$2]),
      if (mostly.value > 0) tr('Mostly {0}', [_group(mostly.key)]),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const ValueKey('week-card'),
        child: ListTile(
          leading: const Icon(
            Icons.auto_stories_outlined,
            color: AppColors.gold,
          ),
          title: Text(tr('Your week in cards')),
          subtitle: Text(
            lines.join(' · '),
            style: const TextStyle(color: AppColors.textMuted),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            logEvent('week_card');
            context.push('/collection');
          },
        ),
      ),
    );
  }
}

/// After a 7-day streak (iPhone): how to add the Card of the Day widget.
/// Widgets are rarely found without a nudge; this shows once until closed.
class WidgetTipCard extends StatelessWidget {
  const WidgetTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (kIsWeb || !Platform.isIOS || state.widgetTipSeen || state.streak < 7) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const ValueKey('widget-tip'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.widgets_outlined, color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tr('A week in a row. Keep your card on your Home Screen'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: tr('Close'),
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      logEvent('widget_tip', {'action': 'close'});
                      state.closeWidgetTip();
                    },
                  ),
                ],
              ),
              Text(
                tr(
                  'Touch and hold an empty spot on your Home Screen, tap Edit, then Add Widget, and search for ShenTarot. It shows today\'s card and your streak. It also fits the Lock Screen.',
                ),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
