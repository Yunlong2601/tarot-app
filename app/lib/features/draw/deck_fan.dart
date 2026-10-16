import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../app/brand.dart';

/// Where a picked card sat on screen, so it can fly from there to its slot.
class FanPick {
  const FanPick({
    required this.deckIndex,
    required this.center,
    required this.angle,
  });

  /// Index into the shuffled deck the fan was built from.
  final int deckIndex;

  /// Global centre of the card when it was picked.
  final Offset center;

  /// Its tilt in the fan, in radians.
  final double angle;
}

/// The shuffled deck spread face down in an arc. Plays a riffle-and-spread
/// shuffle when built (and whenever [shuffleKey] changes), spins with a
/// horizontal drag or fling, and reports the card the user taps.
///
/// Screen readers get one button that draws the card nearest the middle, so
/// the swipe is never the only way to pick.
class DeckFan extends StatefulWidget {
  const DeckFan({
    super.key,
    required this.remaining,
    required this.onPick,
    required this.shuffleKey,
    this.enabled = true,
    this.cardWidth = 58,
  });

  /// Indices into the shuffled deck still in the fan, in fan order.
  final List<int> remaining;

  final ValueChanged<FanPick> onPick;

  /// Changing this replays the shuffle animation.
  final Object shuffleKey;

  /// False while a picked card is still flying, so picks don't overlap.
  final bool enabled;
  final double cardWidth;

  /// Angle between neighbouring cards, in radians.
  static const step = 0.042;

  /// Cards further than this from the middle are not built.
  static const maxVisibleAngle = 1.05;

  @override
  State<DeckFan> createState() => _DeckFanState();
}

class _DeckFanState extends State<DeckFan> with TickerProviderStateMixin {
  late final AnimationController _shuffle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  /// Fan rotation in radians; 0 puts the middle card upright.
  late final AnimationController _spin = AnimationController.unbounded(
    vsync: this,
  );

  final _boxKey = GlobalKey();
  double _radius = 400;
  bool _started = false;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  double get _spinLimit =>
      math.max(0, (widget.remaining.length - 1) / 2 * DeckFan.step);

  @override
  void initState() {
    super.initState();
    _spin.addListener(_clampSpin);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _playShuffle();
    }
  }

  @override
  void didUpdateWidget(DeckFan old) {
    super.didUpdateWidget(old);
    if (old.shuffleKey != widget.shuffleKey) _playShuffle();
    _clampSpin();
  }

  void _playShuffle() {
    _spin.stop();
    _spin.value = 0;
    if (_reduceMotion) {
      _shuffle.value = 1;
    } else {
      _shuffle.forward(from: 0);
    }
  }

  void _clampSpin() {
    final limit = _spinLimit;
    final v = _spin.value;
    if (v.abs() > limit) {
      if (_spin.isAnimating) _spin.stop();
      _spin.value = v.clamp(-limit, limit);
    }
  }

  @override
  void dispose() {
    _shuffle.dispose();
    _spin.dispose();
    super.dispose();
  }

  bool get _interactive => widget.enabled && _shuffle.isCompleted;

  double _angleOf(int fanPos) {
    final n = widget.remaining.length;
    return (fanPos - (n - 1) / 2) * DeckFan.step + _spin.value;
  }

  void _pick(int fanPos, double angle, Offset localCenter) {
    if (!_interactive) return;
    final box = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    _spin.stop();
    HapticFeedback.selectionClick();
    widget.onPick(
      FanPick(
        deckIndex: widget.remaining[fanPos],
        center: box.localToGlobal(localCenter),
        angle: angle,
      ),
    );
  }

  /// The card closest to upright: what the accessible "draw" button takes.
  void _pickMiddle() {
    if (!_interactive || widget.remaining.isEmpty) return;
    var best = 0;
    for (var i = 1; i < widget.remaining.length; i++) {
      if (_angleOf(i).abs() < _angleOf(best).abs()) best = i;
    }
    final box = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final a = _angleOf(best);
    _pick(best, a, _cardCenter(a, box.size.width, 1));
  }

  Offset _cardCenter(double angle, double width, double spread) {
    final ch = widget.cardWidth * 1.6;
    final a = angle * spread;
    return Offset(
      width / 2 + _radius * math.sin(a),
      16 + ch / 2 + _radius * (1 - math.cos(a)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cw = widget.cardWidth, ch = cw * 1.6;
    return Semantics(
      button: true,
      enabled: _interactive,
      label: 'Deck. Tap to draw the next card.',
      hint: 'Or swipe the fan and tap any card.',
      excludeSemantics: true,
      onTap: _pickMiddle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => _spin.stop(),
        onHorizontalDragUpdate: (d) {
          if (!_shuffle.isCompleted) return;
          _spin.value += d.delta.dx / _radius;
        },
        onHorizontalDragEnd: (d) {
          if (!_shuffle.isCompleted || _reduceMotion) return;
          final v = d.velocity.pixelsPerSecond.dx / _radius;
          _spin.animateWith(FrictionSimulation(0.12, _spin.value, v));
        },
        child: SizedBox(
          key: _boxKey,
          height: ch + 56,
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              _radius = math.max(320, w * 1.15);
              return AnimatedBuilder(
                animation: Listenable.merge([_shuffle, _spin]),
                builder: (context, _) => _buildCards(w, cw, ch),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCards(double w, double cw, double ch) {
    final t = _shuffle.value;
    // 0..0.55: the stacked deck riffles side to side. 0.55..1: it spreads.
    final riffleT = (t / 0.55).clamp(0.0, 1.0);
    final spread = Curves.easeOutCubic.transform(
      ((t - 0.55) / 0.45).clamp(0.0, 1.0),
    );
    final riffle = math.sin(riffleT * math.pi * 4) * (1 - riffleT) * 0.9;
    final n = widget.remaining.length;
    final cards = <Widget>[];
    for (var i = 0; i < n; i++) {
      final angle = _angleOf(i);
      if (angle.abs() > DeckFan.maxVisibleAngle && spread == 1) continue;
      var center = _cardCenter(angle, w, spread);
      if (spread == 0) {
        // Alternate halves slide out and back in, like a riffle shuffle.
        final side = i.isEven ? 1.0 : -1.0;
        center = center.translate(side * riffle * cw * 0.7, -i * 0.05);
      }
      final shown = angle * spread;
      cards.add(
        Positioned(
          key: ValueKey(widget.remaining[i]),
          left: center.dx - cw / 2,
          top: center.dy - ch / 2,
          width: cw,
          height: ch,
          child: Transform.rotate(
            angle: shown,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _pick(i, shown, center),
              child: CardBack(width: cw),
            ),
          ),
        ),
      );
    }
    return ExcludeSemantics(
      child: Stack(clipBehavior: Clip.none, children: cards),
    );
  }
}
