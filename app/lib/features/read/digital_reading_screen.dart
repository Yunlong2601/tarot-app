import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/brand.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';
import '../reading/start_reading.dart';

/// Digital card reading: the app draws random, duplicate-free cards for the
/// chosen spread; the user taps each face-down card to flip it, then gets the
/// same AI reading as a scanned physical deck.
class DigitalReadingScreen extends StatefulWidget {
  const DigitalReadingScreen({super.key, this.random});

  /// Injectable for tests.
  final math.Random? random;

  @override
  State<DigitalReadingScreen> createState() => _DigitalReadingScreenState();
}

class _DigitalReadingScreenState extends State<DigitalReadingScreen> {
  final _question = TextEditingController();
  late final math.Random _rng = widget.random ?? math.Random.secure();
  List<DrawnCard> _drawn = [];
  Set<int> _flipped = {};
  SpreadType? _drawnFor;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  void _draw(SpreadType spread) {
    final deck = [...AppScope.of(context).deck.cards]..shuffle(_rng);
    setState(() {
      _drawnFor = spread;
      _flipped = {};
      _drawn = [
        for (final c in deck.take(spread.cardCount))
          DrawnCard(card: c, reversed: _rng.nextDouble() < 0.25),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final spread = state.selectedSpread;
    if (_drawnFor != spread) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _drawnFor != spread) _draw(spread);
      });
    }
    final allFlipped = _drawn.isNotEmpty && _flipped.length == _drawn.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Digital card reading')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Take a breath and think of your question. ${spread.label}: tap each card to turn it over.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _question,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Your question (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < _drawn.length; i++)
                _FlipCard(
                  key: ValueKey('${_drawnFor?.name}-$i-${_drawn[i].card.id}'),
                  drawn: _drawn[i],
                  flipped: _flipped.contains(i),
                  onTap: () => setState(() => _flipped = {..._flipped, i}),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_flipped.isEmpty)
            OutlinedButton.icon(
              onPressed: () => _draw(spread),
              icon: const Icon(Icons.shuffle),
              label: const Text('Shuffle again'),
            ),
          if (allFlipped)
            FilledButton(
              onPressed: () => startReading(
                context,
                spread: spread,
                cards: _drawn,
                question: _question.text,
              ),
              child: const Text('Get my reading'),
            ),
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

class _FlipCard extends StatefulWidget {
  const _FlipCard({
    super.key,
    required this.drawn,
    required this.flipped,
    required this.onTap,
  });
  final DrawnCard drawn;
  final bool flipped;
  final VoidCallback onTap;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(_FlipCard old) {
    super.didUpdateWidget(old);
    if (widget.flipped && !old.flipped) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.drawn.card.name;
    return Semantics(
      button: !widget.flipped,
      label: widget.flipped
          ? '$name${widget.drawn.reversed ? ', reversed' : ''}'
          : 'Face-down card. Tap to turn over.',
      excludeSemantics: true,
      onTap: widget.flipped ? null : widget.onTap,
      child: GestureDetector(
        onTap: widget.flipped ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) {
            final angle = _c.value * math.pi;
            final showFront = angle > math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: showFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Column(
                        children: [
                          CardArt(
                            card: widget.drawn.card,
                            reversed: widget.drawn.reversed,
                            width: 90,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 96,
                            child: Text(
                              '$name${widget.drawn.reversed ? ' (reversed)' : ''}',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const CardBack(width: 90),
            );
          },
        ),
      ),
    );
  }
}
