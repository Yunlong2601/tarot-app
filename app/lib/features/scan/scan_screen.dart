import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/reading_service.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import 'orientation_dialog.dart';

/// Starts a reading by scanning with the camera (Phase C), picking manually,
/// or - in debug builds - simulating a scan.
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

  /// [simulated] readings (debug builds only) skip the backend and use the
  /// built-in sample text.
  Future<void> _startReading(List<DrawnCard> cards,
      {bool simulated = false}) async {
    final state = AppScope.of(context);
    if (!state.canStart(_spread)) {
      context.push('/paywall');
      return;
    }
    final q = _question.text.trim();
    var text = mockInterpretation;
    if (!simulated) {
      final result = await _interpret(state, cards, q);
      if (result == null || !mounted) return;
      text = result.text;
    }
    final id = 'r${DateTime.now().microsecondsSinceEpoch}';
    state.addReading(Reading(
      id: id,
      createdAt: DateTime.now(),
      spread: _spread,
      cards: cards,
      interpretation: text,
      question: q.isEmpty ? null : q,
    ));
    context.push('/reading/$id');
  }

  Future<ReadingResult?> _interpret(
      AppState state, List<DrawnCard> cards, String question) async {
    final nav = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    ReadingException? failure;
    ReadingResult? result;
    try {
      result = await state.readingService.interpret(
          spread: _spread, cards: cards, question: question);
    } on ReadingException catch (e) {
      failure = e;
    } finally {
      nav.pop(); // close the spinner
    }
    if (failure != null && mounted) {
      if (failure.kind == ReadingErrorKind.premiumRequired ||
          failure.kind == ReadingErrorKind.dailyLimit) {
        context.push('/paywall');
      } else {
        _toast(failure.message);
      }
    }
    return result;
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  /// Phase B stand-in for the camera: a random, duplicate-free draw.
  List<TarotCard> _mockDraw() {
    final cards = [...AppScope.of(context).deck.cards]..shuffle();
    return cards.take(_spread.cardCount).toList();
  }

  List<DrawnCard> _asDrawn(List<TarotCard> cards) => [
        for (var i = 0; i < cards.length; i++)
          DrawnCard(card: cards[i], reversed: i.isOdd),
      ];

  Future<void> _scanWithCamera() async {
    if (!AppScope.of(context).canStart(_spread)) {
      context.push('/paywall');
      return;
    }
    final cards = await context
        .push<List<DrawnCard>>('/scan-camera', extra: _spread.cardCount);
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
                Text('Hold up a Rider-Waite-Smith card',
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
          FilledButton.icon(
            onPressed: _scanWithCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan with camera'),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _startReading(_asDrawn(_mockDraw()), simulated: true),
              child: const Text('Simulate scan'),
            ),
          ],
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
