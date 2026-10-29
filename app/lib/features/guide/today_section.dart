import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/brand.dart';
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
                // Not drawn yet: the face-down card is the invitation.
                ? InkWell(
                    onTap: () => context.push('/daily'),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const CardBack(width: 104),
                        const SizedBox(height: 20),
                        Text(tr('Card of the Day'), style: t.headlineSmall),
                        const SizedBox(height: 6),
                        Text(
                          tr(
                            'Draw your Card of the Day for a question to carry with you today. Free, every day.',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.push('/daily'),
                          child: Text(tr('Draw today\'s card')),
                        ),
                      ],
                    ),
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
                                cardLabel(daily.card.name, daily.reversed),
                                style: t.titleLarge?.copyWith(
                                  color: AppColors.goldLight,
                                ),
                              ),
                              Text(
                                tr('Card of the Day'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (k != null) Text(k.essence),
                              if (question != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  tr('Today\'s guidance: {0}', [question]),
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
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
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Your journey'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${h.length == 1 ? tr('1 reading so far') : tr('{0} readings so far', [h.length])} · ${tr('{0} of {1} cards met', [counts.length, 78])}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              if (top.isNotEmpty && top.first.value > 1) ...[
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(
                          'The card that keeps appearing: {0} ({1} times). What might it be asking of you?',
                          [top.first.key, top.first.value],
                        ),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
