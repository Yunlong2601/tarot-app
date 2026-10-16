import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

/// Phase A: the camera is a placeholder. "Simulate scan" draws mock cards.
/// Phase C replaces it with a live camera + on-device recognition.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  SpreadType _spread = SpreadType.single;
  final _question = TextEditingController();

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  void _startReading(List<TarotCard> cards) {
    final state = AppScope.of(context);
    if (!state.canStart(_spread)) {
      context.push('/paywall');
      return;
    }
    final id = 'r${DateTime.now().microsecondsSinceEpoch}';
    final q = _question.text.trim();
    state.addReading(Reading(
      id: id,
      createdAt: DateTime.now(),
      spread: _spread,
      cards: [
        for (var i = 0; i < cards.length; i++)
          DrawnCard(card: cards[i], reversed: i.isOdd),
      ],
      interpretation: mockInterpretation,
      question: q.isEmpty ? null : q,
    ));
    context.push('/reading/$id');
  }

  /// Phase B stand-in for the camera: a random, duplicate-free draw.
  List<TarotCard> _mockDraw() {
    final cards = [...AppScope.of(context).deck.cards]..shuffle();
    return cards.take(_spread.cardCount).toList();
  }

  Future<void> _pickManually() async {
    final id = await context.push<String>('/pick');
    if (id == null || !mounted) return;
    final card = AppScope.of(context).deck.byId(id)!;
    final rest =
        _mockDraw().where((c) => c.id != id).take(_spread.cardCount - 1);
    _startReading([card, ...rest]);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined,
                    size: 56, color: AppColors.textMuted),
                SizedBox(height: 8),
                Text('Camera preview arrives in Phase C',
                    style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: [
            for (final s in SpreadType.values)
              ChoiceChip(
                label: Text(
                    s.isPremium && !state.isPremium ? '${s.label} 🔒' : s.label),
                selected: _spread == s,
                onSelected: (_) {
                  if (s.isPremium && !state.isPremium) {
                    context.push('/paywall');
                  } else {
                    setState(() => _spread = s);
                  }
                },
              ),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _question,
            maxLength: 300,
            decoration: const InputDecoration(
                labelText: 'Your question (optional)',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => _startReading(_mockDraw()),
            child: const Text('Simulate scan'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _pickManually,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text("Can't scan? Pick a card manually"),
          ),
          const SizedBox(height: 12),
          Text(
            state.isPremium
                ? 'Premium: unlimited readings'
                : state.canReadForFree
                    ? '1 free reading left today'
                    : 'Free reading used. Come back tomorrow or go Premium.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
