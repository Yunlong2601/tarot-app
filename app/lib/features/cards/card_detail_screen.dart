import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import 'card_art.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key, required this.cardId});
  final String cardId;

  String _subtitle(TarotCard c) {
    if (c.arcana == Arcana.major) return 'Major Arcana · ${c.number}';
    final suit = c.suit!.name[0].toUpperCase() + c.suit!.name.substring(1);
    return 'Minor Arcana · $suit';
  }

  @override
  Widget build(BuildContext context) {
    final card = AppScope.of(context).deck.byId(cardId);
    if (card == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Card not found')),
      );
    }
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(card.name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: CardArt(card: card, width: 160)),
          const SizedBox(height: 16),
          Text(
            _subtitle(card),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [for (final k in card.keywords) Chip(label: Text(k))],
          ),
          if (card.element != null || card.association != null) ...[
            const SizedBox(height: 8),
            Text(
              [
                if (card.element != null) 'Element: ${card.element}',
                if (card.association != null)
                  'Traditional association: ${card.association}',
              ].join('  ·  '),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Upright',
            style: t.titleMedium?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 4),
          Text(card.upright),
          const SizedBox(height: 20),
          Text(
            'Reversed',
            style: t.titleMedium?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 4),
          Text(card.reversed),
          const SizedBox(height: 24),
          const Text(
            'For entertainment and self-reflection only.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
