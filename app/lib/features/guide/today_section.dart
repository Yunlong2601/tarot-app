import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../cards/card_art.dart';
import '../../app/i18n.dart';

/// Top of the Guide tab: today's card with a question to carry through the
/// day, and "Your journey" built from the reading history on this phone.
class TodaySection extends StatelessWidget {
  const TodaySection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final daily = state.dailyCardIfDrawn;
    final t = Theme.of(context).textTheme;
    final k = daily?.card.knowledge;
    final question = k == null
        ? null
        : (daily!.reversed ? k.reversedQuestion : k.uprightQuestion);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: daily == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Today'), style: t.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        tr(
                          tr(
                            'Draw your Card of the Day for a question to carry with you today. Free, every day.',
                          ),
                        ),
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push('/daily'),
                        child: Text(tr('Draw today\'s card')),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () => context.push('/daily'),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CardArt(
                          card: daily.card,
                          reversed: daily.reversed,
                          width: 96,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('TODAY\'S CARD'),
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                cardLabel(daily.card.name, daily.reversed),
                                style: t.titleMedium?.copyWith(
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (k != null) Text(k.essence),
                              if (question != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  tr('Today\'s guidance: {0}', [question]),
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (state.history.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Journey(state),
        ],
      ],
    );
  }
}

class _Journey extends StatelessWidget {
  const _Journey(this.state);
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final h = state.history;
    final counts = <String, int>{};
    for (final r in h) {
      for (final c in r.cards) {
        counts[c.card.name] = (counts[c.card.name] ?? 0) + 1;
      }
    }
    final top = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final first = h
        .map((r) => r.createdAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    Widget stat(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: AppColors.gold),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Your journey'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                stat('${h.length}', h.length == 1 ? 'reading' : 'readings'),
                stat('${counts.length}', 'different cards'),
                stat(
                  MaterialLocalizations.of(context).formatShortDate(first),
                  'first reading',
                ),
              ],
            ),
            if (top.isNotEmpty && top.first.value > 1) ...[
              const SizedBox(height: 12),
              Text(
                tr(
                  tr(
                    'The card that keeps appearing: {0} ({1} times). What might it be asking of you?',
                  ),
                  [top.first.key, top.first.value],
                ),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
