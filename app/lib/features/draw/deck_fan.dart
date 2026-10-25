import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../app/brand.dart';
import '../../app/i18n.dart';

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
    duration: const Duration(milliseconds: 2200),
  )..addListener(_shuffleHaptics);

  /// A picked card rises and glows for a beat before it flies to its slot.
  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  int? _lifted;

  /// Soft ticks while the halves riffle together, one firm tap as the fan settles.
  int _lastTick = -1;
  void _shuffleHaptics() {
    final t = _shuffle.value;
    if (t >= _splitEnd && t < _riffleEnd) {
      final tick = ((t - _splitEnd) / (_riffleEnd - _splitEnd) * 7).floor();
      if (tick != _lastTick) {
        _lastTick = tick;
        HapticFeedback.selectionClick();
      }
    }
    if (_shuffle.isCompleted && _lastTick != 99) {
      _lastTick = 99;
      HapticFeedback.mediumImpact();
    }
  }

  // Shuffle phases, as fractions of the shuffle: split the deck in two, riffle
  // the halves back together, square the deck, then spread it into a fan.
  static const _splitEnd = 0.14, _riffleEnd = 0.52, _squareEnd = 0.6;

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
    _lastTick = -1;
    _lifted = null;
    _lift.value = 0;
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
    _lift.dispose();
    super.dispose();
  }

  bool get _interactive =>
      widget.enabled && _shuffle.isCompleted && _lifted == null;

  double _angleOf(int fanPos) {
    final n = widget.remaining.length;
    return (fanPos - (n - 1) / 2) * DeckFan.step + _spin.value;
  }

  static const _liftBy = 26.0;

  Future<void> _pick(int fanPos, double angle, Offset localCenter) async {
    if (!_interactive) return;
    final box = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    _spin.stop();
    HapticFeedback.lightImpact();
    final deckIndex = widget.remaining[fanPos];
    if (!_reduceMotion) {
      setState(() => _lifted = deckIndex);
      await _lift.forward(from: 0);
      if (!mounted) return;
    }
    final lifted = localCenter.translate(
      _liftBy * math.sin(angle),
      -_liftBy * math.cos(angle),
    );
    widget.onPick(
      FanPick(
        deckIndex: deckIndex,
        center: box.localToGlobal(_reduceMotion ? localCenter : lifted),
        angle: angle,
      ),
    );
    if (mounted) {
      setState(() => _lifted = null);
      _lift.value = 0;
    }
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
      label: tr('Deck. Tap to draw the next card.'),
      hint: tr('Or swipe the fan and tap any card.'),
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
                animation: Listenable.merge([_shuffle, _spin, _lift]),
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
    final n = widget.remaining.length;
    // Cards past the box edges are not built: past the sides (from the radius
    // and width) or past the visible arc. Applies during the shuffle too, so
    // the fan never paints over the slots or off screen.
    final sideLimit = math.asin(math.min(1.0, (w / 2 + cw) / _radius));
    final limit = math.min(DeckFan.maxVisibleAngle, sideLimit);
    final split = Curves.easeOutCubic.transform(
      (t / _splitEnd).clamp(0.0, 1.0),
    );
    final square = ((t - _riffleEnd) / (_squareEnd - _riffleEnd)).clamp(
      0.0,
      1.0,
    );
    final fanning = t >= _squareEnd;
    // The card nearest upright, raised a little and lit, once the fan is out.
    var middle = -1;
    if (_interactive) {
      var best = double.infinity;
      for (var i = 0; i < n; i++) {
        final a = _angleOf(i).abs();
        if (a < best) {
          best = a;
          middle = i;
        }
      }
    }
    final cards = <Widget>[];
    for (var i = 0; i < n; i++) {
      final angle = _angleOf(i);
      final order = n <= 1 ? 0.0 : i / (n - 1);
      // Cards leave the stack from the middle outwards, each a little later.
      final delay =
          (angle.abs() / DeckFan.maxVisibleAngle).clamp(0.0, 1.0) * 0.18;
      final spread = fanning
          ? Curves.easeOutBack.transform(
              ((t - _squareEnd - delay) / (1 - _squareEnd - 0.18)).clamp(
                0.0,
                1.0,
              ),
            )
          : 0.0;
      if (angle.abs() > limit && spread > 0.02) continue;
      var center = _cardCenter(angle, w, spread);
      var tilt = angle * spread;
      if (!fanning) {
        // Split: even cards to the left half, odd to the right, tilted apart.
        // Riffle: each card drops back to the middle in turn, interleaved.
        final side = i.isEven ? -1.0 : 1.0;
        final drop = Curves.easeInOut.transform(
          ((t - _splitEnd - order * 0.26) / 0.12).clamp(0.0, 1.0),
        );
        final apart = split * (1 - drop);
        center = center.translate(
          side * apart * cw * 0.95,
          -i * 0.06 + math.sin(square * math.pi) * -6,
        );
        tilt = side * apart * 0.16;
      }
      final isLifted = _lifted == widget.remaining[i];
      final isMiddle = i == middle;
      final raise = isLifted
          ? _liftBy * Curves.easeOut.transform(_lift.value)
          : (isMiddle ? 8.0 : 0.0);
      center = center.translate(
        raise * math.sin(tilt),
        -raise * math.cos(tilt),
      );
      final glow = isLifted ? 0.6 * _lift.value + 0.25 : (isMiddle ? 0.3 : 0.0);
      final shown = tilt;
      final hitCenter = center;
      cards.add(
        Positioned(
          key: ValueKey(widget.remaining[i]),
          left: center.dx - cw / 2,
          top: center.dy - ch / 2,
          width: cw,
          height: ch,
          child: Transform.rotate(
            angle: shown,
            child: Transform.scale(
              scale: isLifted ? 1 + 0.08 * _lift.value : 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _pick(i, shown, hitCenter),
                child: glow == 0
                    ? CardBack(width: cw)
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEBD48C)
                                  .withValues(alpha: glow),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CardBack(width: cw),
                      ),
              ),
            ),
          ),
        ),
      );
    }
    // The lifted card paints on top of its neighbours.
    final liftedAt = cards.indexWhere((c) => c.key == ValueKey(_lifted));
    if (liftedAt >= 0) cards.add(cards.removeAt(liftedAt));
    return ExcludeSemantics(
      // Clipped to the fan's own box: nothing spills over the spread above
      // or past the screen edges, whatever the device size or text size.
      child: Stack(clipBehavior: Clip.hardEdge, children: cards),
    );
  }
}
