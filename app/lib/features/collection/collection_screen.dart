import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/brand.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../cards/card_art.dart';

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
