import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/brand.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../reading/start_reading.dart';
import '../spreads/spread_layout.dart';
import 'flip_card.dart';

/// Digital card reading: the app shuffles; the user draws cards from the deck
/// into the spread's numbered slots, turns each over, then gets the same AI
/// reading as a scanned physical deck.
class DigitalReadingScreen extends StatefulWidget {
  const DigitalReadingScreen({super.key, this.random});

  /// Injectable for tests.
  final math.Random? random;

  @override
  State<DigitalReadingScreen> createState() => _DigitalReadingScreenState();
}

class _DigitalReadingScreenState extends State<DigitalReadingScreen> {
  late final math.Random _rng = widget.random ?? math.Random.secure();
  late final SpreadType _spread = AppScope.of(context).selectedSpread;
  List<DrawnCard> _drawn = [];
  int _placed = 0;
  Set<int> _flipped = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_drawn.isEmpty) _shuffle();
  }

  void _shuffle() {
    final state = AppScope.of(context);
    final deck = [...state.deck.cards]..shuffle(_rng);
    setState(() {
      _placed = 0;
      _flipped = {};
      _drawn = [
        for (final c in deck.take(_spread.cardCount))
          DrawnCard(
            card: c,
            reversed: state.readReversed && _rng.nextDouble() < 0.25,
          ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final n = _spread.cardCount;
    final allPlaced = _placed == n;
    final allFlipped = allPlaced && _flipped.length == n;
    final question = state.draftQuestion;
    final hint = !allPlaced
        ? 'Tap the deck to draw card ${_placed + 1} of $n: ${_spread.positions[_placed]}'
        : allFlipped
        ? 'All cards turned. Ready when you are.'
        : 'Tap each card to turn it over.';
    return Scaffold(
      appBar: AppBar(title: Text(_spread.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            question.isEmpty ? 'General reading' : question,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          const Text(
            'Take a breath and hold your question in mind.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SpreadLayoutView(
                type: _spread,
                highlight: allPlaced ? null : _placed,
                slotBuilder: (i, w, h) {
                  if (i >= _placed) {
                    return _EmptySlot(number: i + 1, highlighted: i == _placed);
                  }
                  return FlipCard(
                    key: ValueKey('slot-$i-${_drawn[i].card.id}'),
                    drawn: _drawn[i],
                    width: w,
                    showCaption: false,
                    flipped: _flipped.contains(i),
                    onTap: () => setState(() => _flipped = {..._flipped, i}),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(hint, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          if (!allPlaced)
            Center(child: _DeckFan(onDraw: () => setState(() => _placed++))),
          if (_placed == 0)
            Center(
              child: TextButton.icon(
                onPressed: _shuffle,
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle again'),
              ),
            ),
          if (_flipped.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final i in (_flipped.toList()..sort()))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${i + 1}. ${_spread.positions[i]}: ${_drawn[i].card.name}'
                  '${_drawn[i].reversed ? ' (reversed)' : ''}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
          ],
          if (allFlipped) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => startReading(
                context,
                spread: _spread,
                cards: _drawn,
                question: question,
              ),
              child: const Text('Get my reading'),
            ),
          ],
          const SizedBox(height: 8),
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

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.number, required this.highlighted});
  final int number;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: highlighted ? 0.9 : 0.3),
          width: highlighted ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        textScaler: TextScaler.noScaling,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    ),
  );
}

/// A fanned deck of face-down cards; tapping it draws the next card.
class _DeckFan extends StatelessWidget {
  const _DeckFan({required this.onDraw});
  final VoidCallback onDraw;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Deck. Tap to draw the next card.',
    excludeSemantics: true,
    onTap: onDraw,
    child: GestureDetector(
      onTap: onDraw,
      child: SizedBox(
        width: 260,
        height: 112,
        child: Stack(
          children: [
            for (var i = 0; i < 9; i++)
              Positioned(
                left: i * 24.0,
                top: 8 + (i - 4).abs() * 1.5,
                child: Transform.rotate(
                  angle: (i - 4) * 0.045,
                  child: const CardBack(width: 56),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
