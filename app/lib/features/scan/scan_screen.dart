import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../reading/start_reading.dart';
import '../spreads/spread_layout.dart';
import 'orientation_dialog.dart';

/// Starts a reading by scanning with the camera (Phase C), picking manually,
/// or - in debug builds - simulating a scan.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late final SpreadType _spread = AppScope.of(context).selectedSpread;

  String get _question => AppScope.of(context).draftQuestion;

  Future<void> _startReading(List<DrawnCard> cards, {bool simulated = false}) =>
      startReading(
        context,
        spread: _spread,
        cards: cards,
        question: _question,
        simulated: simulated,
      );

  void _toast(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  /// Debug-only stand-in for the camera: a random, duplicate-free draw.
  List<TarotCard> _mockDraw() {
    final cards = [...AppScope.of(context).deck.cards]..shuffle();
    return cards.take(_spread.cardCount).toList();
  }

  List<DrawnCard> _asDrawn(List<TarotCard> cards) => [
    for (var i = 0; i < cards.length; i++)
      DrawnCard(card: cards[i], reversed: i.isOdd),
  ];

  Future<void> _scanWithCamera() async {
    final cards = await context.push<List<DrawnCard>>(
      '/scan-camera',
      extra: _spread.cardCount,
    );
    if (cards == null || !mounted) return;
    _startReading(cards);
  }

  Future<void> _pickManually() async {
    final picked = <DrawnCard>[];
    final deck = AppScope.of(context).deck;
    while (picked.length < _spread.cardCount) {
      final id = await context.push<String>('/pick');
      if (id == null || !mounted) return;
      if (picked.any((c) => c.card.id == id)) {
        _toast('That card is already in this reading.');
        continue;
      }
      final reversed = await askOrientation(context);
      if (reversed == null || !mounted) return;
      picked.add(DrawnCard(card: deck.byId(id)!, reversed: reversed));
    }
    _startReading(picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final q = state.draftQuestion;
    return Scaffold(
      appBar: AppBar(title: const Text('Photo reading')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _spread.label,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            q.isEmpty ? 'General reading' : q,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: SpreadLayoutView(type: _spread),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _spread.cardCount == 1
                ? 'Shuffle your deck while you hold your question, draw one card, then scan it.'
                : 'Shuffle your deck while you hold your question, draw ${_spread.cardCount} cards, lay them out as shown, then scan them one at a time.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _scanWithCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan with camera'),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  _startReading(_asDrawn(_mockDraw()), simulated: true),
              child: const Text('Simulate scan'),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _pickManually,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text("Can't scan? Pick a card manually"),
          ),
          const SizedBox(height: 12),
          Text(
            state.creditLine,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
