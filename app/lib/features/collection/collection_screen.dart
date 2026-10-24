import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/brand.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../cards/card_art.dart';
import 'insights.dart';

/// Ids of every card that has come up in a saved reading or as today's card.
Set<String> metCardIds(AppState state) => {
  for (final r in state.history)
    for (final c in r.cards) c.card.id,
  if (state.dailyCardIfDrawn case final d?) d.card.id,
};

/// Your deck: all 78 cards, face up once they have come up in a reading,
/// face down until then. Nothing here is stored separately; it is read from
/// the reading history on the phone.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final met = metCardIds(state);
    final cards = state.deck.cards;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Your deck'))),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('{0} of {1} cards met', [met.length, cards.length]),
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: AppColors.gold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: cards.isEmpty ? 0 : met.length / cards.length,
                      minHeight: 6,
                      color: AppColors.gold,
                      backgroundColor: AppColors.surfaceHigh,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    met.length == cards.length
                        ? tr('You have met the whole deck.')
                        : tr(
                            'A card turns face up the first time it comes up in one of your readings.',
                          ),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MonthCard(
                    recap: recapFor(state.history, DateTime.now()),
                    premium: state.isPremium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr('Milestones'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in milestonesFor(state.history, met, cards))
                        _MilestoneChip(m),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr('All 78 cards'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 84,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1 / 1.6,
              ),
              delegate: SliverChildBuilderDelegate(childCount: cards.length, (
                context,
                i,
              ) {
                final card = cards[i];
                final seen = met.contains(card.id);
                return LayoutBuilder(
                  builder: (context, box) => seen
                      ? InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => context.push('/card/${card.id}'),
                          child: CardArt(card: card, width: box.maxWidth),
                        )
                      : Semantics(
                          label: tr('Not met yet'),
                          child: Opacity(
                            opacity: 0.45,
                            child: CardBack(width: box.maxWidth),
                          ),
                        ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// This month: how many readings, the cards that keep coming up and where the
/// cards came from. Free users see the count and the top card; Premium sees all.
class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.recap, required this.premium});
  final MonthRecap recap;
  final bool premium;

  static const _groupNames = {
    'major': 'Major Arcana',
    'wands': 'Wands',
    'cups': 'Cups',
    'swords': 'Swords',
    'pentacles': 'Pentacles',
  };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final total = recap.cardCount;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('This month'),
              style: t.titleMedium?.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: 4),
            Text(
              recap.readings == 1
                  ? tr('1 reading so far')
                  : tr('{0} readings so far', [recap.readings]),
              style: const TextStyle(color: AppColors.textMuted),
            ),
            if (recap.topCards.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                tr(
                  'When a card comes up more than once this month, it will show here.',
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              for (final (i, (card, n)) in recap.topCards.indexed)
                if (premium || i == 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CardArt(card: card, width: 34),
                        const SizedBox(width: 12),
                        Expanded(child: Text(card.name)),
                        Text(
                          tr('{0} times', [n]),
                          style: const TextStyle(color: AppColors.gold),
                        ),
                      ],
                    ),
                  ),
            ],
            if (premium && total > 0) ...[
              const SizedBox(height: 8),
              for (final e in recap.groups.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          tr(_groupNames[e.key]!),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: e.value / total,
                            minHeight: 6,
                            color: AppColors.gold,
                            backgroundColor: AppColors.surfaceHigh,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${e.value}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (!premium && total > 0) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => context.push('/paywall'),
                icon: const Icon(Icons.lock_outline, size: 18),
                label: Text(tr('See your full month with Premium')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  const _MilestoneChip(this.m);
  final Milestone m;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tr(m.detail),
    triggerMode: TooltipTriggerMode.tap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: m.earned ? AppColors.goldTint : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: m.earned ? AppColors.goldDeep : AppColors.surfaceHigh,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            m.earned ? Icons.auto_awesome : Icons.lock_outline,
            size: 16,
            color: m.earned ? AppColors.gold : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            tr(m.title),
            style: TextStyle(
              color: m.earned ? AppColors.gold : AppColors.textMuted,
            ),
          ),
        ],
      ),
    ),
  );
}
