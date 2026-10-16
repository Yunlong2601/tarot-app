import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../reading/start_reading.dart';
import 'flip_card.dart';
import 'question_nudge.dart';

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
  String? _nudge;

  void _onQ() {
    final n = questionNudge(_question.text);
    if (n != _nudge) setState(() => _nudge = n);
  }

  @override
  void initState() {
    super.initState();
    _question.addListener(_onQ);
  }

  late final math.Random _rng = widget.random ?? math.Random.secure();
  List<DrawnCard> _drawn = [];
  Set<int> _flipped = {};
  SpreadType? _drawnFor;

  @override
  void dispose() {
    _question.removeListener(_onQ);
    _question.dispose();
    super.dispose();
  }

  void _draw(SpreadType spread) {
    final state = AppScope.of(context);
    final deck = [...state.deck.cards]..shuffle(_rng);
    setState(() {
      _drawnFor = spread;
      _flipped = {};
      _drawn = [
        for (final c in deck.take(spread.cardCount))
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
            decoration: InputDecoration(
              labelText: 'Your question (optional)',
              border: const OutlineInputBorder(),
              helperText: _nudge,
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < _drawn.length; i++)
                FlipCard(
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
