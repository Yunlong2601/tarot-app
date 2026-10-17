import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../read/flip_card.dart';
import '../reading/start_reading.dart';
import '../spreads/spread_layout.dart';
import 'deck_fan.dart';
import 'flying_card.dart';
import '../../app/i18n.dart';

/// Digital card reading: the deck is shuffled with a riffle animation and
/// spread face down in a fan. The user swipes the fan, taps any card to send
/// it flying into the next slot of the spread, turns each card over, then
/// gets the same AI reading as a scanned physical deck.
class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key, this.random});

  /// Injectable for tests.
  final math.Random? random;

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  late final math.Random _rng = widget.random ?? math.Random.secure();
  late final SpreadType _spread = AppScope.of(context).selectedSpread;
  late final List<GlobalKey> _slotKeys = List.generate(
    _spread.cardCount,
    (_) => GlobalKey(),
  );

  /// The whole shuffled deck, and which way up each card will land.
  List<DrawnCard> _deck = [];

  /// Indices into [_deck] still in the fan.
  List<int> _remaining = [];
  final List<DrawnCard> _drawn = [];
  Set<int> _flipped = {};
  int _shuffleCount = 0;
  OverlayEntry? _flying;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_deck.isEmpty) _shuffle();
  }

  @override
  void dispose() {
    _flying?.remove();
    super.dispose();
  }

  void _shuffle() {
    final state = AppScope.of(context);
    final cards = [...state.deck.cards]..shuffle(_rng);
    setState(() {
      _deck = [
        for (final c in cards)
          DrawnCard(
            card: c,
            reversed: state.readReversed && _rng.nextDouble() < 0.25,
          ),
      ];
      _remaining = List.generate(_deck.length, (i) => i);
      _drawn.clear();
      _flipped = {};
      _shuffleCount++;
    });
  }

  void _onPick(FanPick pick) {
    if (_flying != null || _drawn.length >= _spread.cardCount) return;
    final slot = _drawn.length;
    final card = _deck[pick.deckIndex];
    setState(() => _remaining = [..._remaining]..remove(pick.deckIndex));

    void land() {
      _flying?.remove();
      _flying = null;
      if (!mounted) return;
      HapticFeedback.lightImpact();
      final autoReveal = AppScope.of(context).autoReveal;
      setState(() {
        if (autoReveal) _flipped = {..._flipped, _drawn.length};
        _drawn.add(card);
      });
    }

    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    final slotBox =
        _slotKeys[slot].currentContext?.findRenderObject() as RenderBox?;
    if (MediaQuery.disableAnimationsOf(context) ||
        overlayBox == null ||
        slotBox == null) {
      land();
      return;
    }
    final toGlobal = slotBox.localToGlobal(slotBox.size.center(Offset.zero));
    final m = slotBox.getTransformTo(null);
    _flying = OverlayEntry(
      builder: (_) => FlyingCard(
        fromCenter: overlayBox.globalToLocal(pick.center),
        fromWidth: _fanCardWidth,
        fromAngle: pick.angle,
        toCenter: overlayBox.globalToLocal(toGlobal),
        toWidth: slotBox.size.width,
        toAngle: math.atan2(m.entry(1, 0), m.entry(0, 0)),
        onLanded: land,
      ),
    );
    overlay.insert(_flying!);
    setState(() {});
  }

  static const _fanCardWidth = 58.0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final n = _spread.cardCount;
    final placed = _drawn.length;
    final allPlaced = placed == n;
    final allFlipped = allPlaced && _flipped.length == n;
    final question = state.draftQuestion;
    final hint = !allPlaced
        ? tr('Swipe the fan and pick card {0} of {1}: {2}', [
            placed + 1,
            n,
            _spread.positions[placed],
          ])
        : allFlipped
        ? tr('All cards turned. Ready when you are.')
        : tr('Tap each card to turn it over.');
    return Scaffold(
      appBar: AppBar(title: Text(_spread.label)),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.isEmpty ? tr('General reading') : question,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('Take a breath and hold your question in mind.'),
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: SpreadLayoutView(
                      type: _spread,
                      highlight: allPlaced ? null : placed,
                      slotBuilder: (i, w, h) => SizedBox(
                        key: _slotKeys[i],
                        width: w,
                        height: h,
                        child: i >= placed
                            ? _EmptySlot(
                                number: i + 1,
                                highlighted: i == placed,
                              )
                            : FlipCard(
                                key: ValueKey('slot-$i-${_drawn[i].card.id}'),
                                drawn: _drawn[i],
                                width: w,
                                showCaption: false,
                                flipped: _flipped.contains(i),
                                onTap: () =>
                                    setState(() => _flipped = {..._flipped, i}),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              hint,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (!allPlaced) ...[
              DeckFan(
                remaining: _remaining,
                shuffleKey: _shuffleCount,
                enabled: _flying == null,
                cardWidth: _fanCardWidth,
                onPick: _onPick,
              ),
              Center(
                child: TextButton.icon(
                  // Reshuffling is only offered before the first card is down.
                  onPressed: placed == 0 && _flying == null ? _shuffle : null,
                  icon: const Icon(Icons.shuffle),
                  label: Text(tr('Shuffle again')),
                ),
              ),
            ] else
              _Results(
                spread: _spread,
                drawn: _drawn,
                flipped: _flipped,
                ready: allFlipped,
                onRead: () => startReading(
                  context,
                  spread: _spread,
                  cards: _drawn,
                  question: question,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The names of the turned cards, then the button to get the reading.
class _Results extends StatelessWidget {
  const _Results({
    required this.spread,
    required this.drawn,
    required this.flipped,
    required this.ready,
    required this.onRead,
  });
  final SpreadType spread;
  final List<DrawnCard> drawn;
  final Set<int> flipped;
  final bool ready;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.32,
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final i in (flipped.toList()..sort()))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${i + 1}. ${spread.positions[i]}: ${drawn[i].card.name}'
                '${drawn[i].reversed ? ' (reversed)' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          if (ready) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onRead, child: Text(tr('Get my reading'))),
          ],
        ],
      ),
    ),
  );
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.number, required this.highlighted});
  final int number;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: highlighted ? 0.9 : 0.3),
          width: highlighted ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ]
            : const [],
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
