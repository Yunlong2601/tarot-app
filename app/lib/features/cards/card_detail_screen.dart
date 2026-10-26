import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import 'card_art.dart';
import '../../app/i18n.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key, required this.cardId});
  final String cardId;

  String _subtitle(TarotCard c) {
    if (c.arcana == Arcana.major) return tr('Major Arcana · {0}', [c.number]);
    final suit = c.suit!.name[0].toUpperCase() + c.suit!.name.substring(1);
    return tr('Minor Arcana · {0}', [suit]);
  }

  @override
  Widget build(BuildContext context) {
    final card = AppScope.of(context).deck.byId(cardId);
    if (card == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(tr('Card not found'))),
      );
    }
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(card.name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Semantics(
              button: true,
              label: tr('Zoom in on the card'),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder<void>(
                    opaque: false,
                    barrierColor: Colors.black87,
                    pageBuilder: (_, _, _) => _Lightbox(card: card),
                  ),
                ),
                child: Hero(
                  tag: 'art-${card.id}',
                  child: CardArt(card: card, width: 160),
                ),
              ),
            ),
          ),
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
                if (card.element != null)
                  tr('Element: {0}', [tr(card.element!)]),
                if (card.association != null)
                  tr('Traditional association: {0}', [tr(card.association!)]),
              ].join('  ·  '),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          if (card.knowledge != null) ..._richSections(card.knowledge!, t),
          Text(
            tr('Upright'),
            style: t.titleMedium?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 4),
          Text(card.knowledge?.uprightCore ?? card.upright),
          if (card.knowledge != null) ...[
            const SizedBox(height: 6),
            Text(
              tr('Light: {0}.  Shadow: {1}.', [
                card.knowledge!.light,
                card.knowledge!.shadow,
              ]),
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              tr('To reflect on: {0}', [card.knowledge!.uprightQuestion]),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            tr('Reversed'),
            style: t.titleMedium?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 4),
          Text(card.knowledge?.reversedCore ?? card.reversed),
          if (card.knowledge != null) ...[
            const SizedBox(height: 6),
            for (final m in card.knowledge!.modes)
              Text('• $m', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Text(
              tr('To reflect on: {0}', [card.knowledge!.reversedQuestion]),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            tr(
              'Art: Pamela Colman Smith, 1909. Public domain, not AI-generated.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

List<Widget> _richSections(CardKnowledge k, TextTheme t) => [
  Text(k.essence, style: t.titleLarge, textAlign: TextAlign.center),
  const SizedBox(height: 16),
  Text(
    tr('What is pictured'),
    style: t.titleMedium?.copyWith(color: AppColors.gold),
  ),
  const SizedBox(height: 4),
  Text(k.imagery),
  const SizedBox(height: 16),
  Text(
    tr('Why it means this'),
    style: t.titleMedium?.copyWith(color: AppColors.gold),
  ),
  const SizedBox(height: 4),
  Text(k.why),
  const SizedBox(height: 20),
];

/// The card art full screen: pinch to zoom, tap anywhere to close.
class _Lightbox extends StatelessWidget {
  const _Lightbox({required this.card});
  final TarotCard card;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                maxScale: 5,
                child: Hero(
                  tag: 'art-${card.id}',
                  child: LayoutBuilder(
                    builder: (context, box) => CardArt(
                      card: card,
                      width: (box.maxHeight / 1.6).clamp(0, box.maxWidth - 32),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: tr('Close'),
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
