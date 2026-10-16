import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../app/theme.dart';

/// Landing backdrop. Shows `assets/hero/hero.jpg` when the owner adds it,
/// otherwise a painted starry placeholder (original, no third-party art).
class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _StarsPainter()),
        Image.asset(
          'assets/hero/hero.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, _, _) => const Align(
            alignment: Alignment(0, -0.45),
            child: CardFan(cardWidth: 118),
          ),
        ),
        // Fade to the app background so the text and button stay readable.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.45, 0.85],
              colors: [Colors.transparent, AppColors.background],
            ),
          ),
        ),
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.3, -0.4),
          radius: 1.1,
          colors: [Color(0xFF2A2415), AppColors.background],
        ).createShader(Offset.zero & size),
    );
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.gold.withValues(alpha: 0.18);
    final c = Offset(size.width * 0.62, size.height * 0.32);
    for (final r in [0.25, 0.4, 0.58]) {
      canvas.drawCircle(c, size.width * r, ring);
    }
    final rng = math.Random(7);
    final dot = Paint();
    for (var i = 0; i < 70; i++) {
      final o = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height * 0.7,
      );
      dot.color = AppColors.gold.withValues(
        alpha: 0.2 + rng.nextDouble() * 0.6,
      );
      canvas.drawCircle(o, 0.6 + rng.nextDouble() * 1.6, dot);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
