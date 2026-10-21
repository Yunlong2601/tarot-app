import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';
import 'orientation_dialog.dart';

/// After scanning or picking: check every card before the reading starts.
/// Change a card, flip it, drag to reorder, remove or add one. Pops with the
/// final cards in position order, or null if the user backs out.
class ReviewCardsScreen extends StatefulWidget {
  const ReviewCardsScreen({super.key, required this.cards});
  final List<DrawnCard> cards;

  @override
  State<ReviewCardsScreen> createState() => _ReviewCardsScreenState();
}

class _ReviewCardsScreenState extends State<ReviewCardsScreen> {
  late final List<DrawnCard> _cards = [...widget.cards];

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  /// Picks a card not already in the reading, with its orientation.
  Future<DrawnCard?> _pickCard({String? replacing}) async {
    final id = await context.push<String>('/pick');
    if (id == null || !mounted) return null;
    if (_cards.any((c) => c.card.id == id && c.card.id != replacing)) {
      _toast('That card is already in this reading.');
      return null;
    }
    final reversed = await askOrientation(context);
    if (reversed == null || !mounted) return null;
    return DrawnCard(
      card: AppScope.of(context).deck.byId(id)!,
      reversed: reversed,
    );
  }

  Future<void> _change(int i) async {
    final c = await _pickCard(replacing: _cards[i].card.id);
    if (c != null) setState(() => _cards[i] = c);
  }

  Future<void> _add() async {
    final c = await _pickCard();
    if (c != null) setState(() => _cards.add(c));
  }

  void _flip(int i) => setState(
    () => _cards[i] = DrawnCard(
      card: _cards[i].card,
      reversed: !_cards[i].reversed,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final spread = AppScope.of(context).selectedSpread;
    final need = spread.cardCount;
    final ready = _cards.length == need;
    return Scaffold(
      appBar: AppBar(title: const Text('Check your cards')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              'Make sure each card and its direction match your table. '
              'Drag to change the order.',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _cards.length,
              onReorderItem: (from, to) =>
                  setState(() => _cards.insert(to, _cards.removeAt(from))),
              itemBuilder: (context, i) {
                final d = _cards[i];
                return Card(
                  key: ValueKey(d.card.id),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        CardArt(card: d.card, reversed: d.reversed, width: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i < need ? spread.positions[i] : 'Extra card',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(d.card.name),
                              Text(
                                d.reversed ? 'Reversed' : 'Upright',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Flip upright or reversed',
                          icon: const Icon(Icons.swap_vert),
                          onPressed: () => _flip(i),
                        ),
                        IconButton(
                          tooltip: 'Change card',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _change(i),
                        ),
                        IconButton(
                          tooltip: 'Remove card',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _cards.removeAt(i)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_cards.length < need)
                  OutlinedButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add),
                    label: Text('Add a card (${_cards.length} of $need)'),
                  ),
                if (_cards.length > need)
                  Text(
                    'This spread uses $need cards. Remove ${_cards.length - need}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: ready ? () => context.pop(_cards) : null,
                  child: const Text('Looks right: read my cards'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
