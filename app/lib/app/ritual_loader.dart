import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'brand.dart';
import 'i18n.dart';
import 'theme.dart';

/// Shown while a reading or a spread photo is worked on: gold stars appear one
/// by one and join into a slowly turning constellation. Static when the user
/// has asked for less motion.
class RitualLoader extends StatefulWidget {
  const RitualLoader({super.key, this.size = 120});
  final double size;

  @override
  State<RitualLoader> createState() => _RitualLoaderState();
}

class _RitualLoaderState extends State<RitualLoader>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations || !brandAnimations) {
      _c.stop();
      _c.value = 0.8; // every star shown, before the fade
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: tr('Loading'),
    child: SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _StarsPainter(_c.value)),
      ),
    ),
  );
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.t);
  final double t;

  // Seven stars on a loose ring, joined in order like a constellation.
  static final _stars = [
    for (var i = 0; i < 7; i++)
      (
        angle: i / 7 * 2 * math.pi + (i.isEven ? 0.18 : -0.12),
        radius: i.isEven ? 0.78 : 0.56,
      ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final turn = t * 2 * math.pi / 6;
    // Each star appears in the first 70% of the loop; all fade together at the end.
    final fade = t > 0.85 ? (1 - (t - 0.85) / 0.15) : 1.0;
    Offset at(int i) {
      final s = _stars[i];
      return c + Offset.fromDirection(s.angle + turn, s.radius * r);
    }

    double shown(int i) => ((t / 0.7) * _stars.length - i).clamp(0.0, 1.0);

    final line = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.45 * fade)
      ..strokeWidth = 1.2;
    for (var i = 1; i < _stars.length; i++) {
      final p = shown(i);
      if (p <= 0) break;
      canvas.drawLine(at(i - 1), Offset.lerp(at(i - 1), at(i), p)!, line);
    }
    if (shown(_stars.length - 1) >= 1) {
      canvas.drawLine(at(_stars.length - 1), at(0), line);
    }

    for (var i = 0; i < _stars.length; i++) {
      final p = shown(i);
      if (p <= 0) continue;
      final pos = at(i);
      final glow = Paint()
        ..color = AppColors.gold.withValues(alpha: 0.25 * p * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(pos, 6, glow);
      canvas.drawCircle(
        pos,
        2.4 * p,
        Paint()..color = AppColors.gold.withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.t != t;
}
