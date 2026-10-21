import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// ShenTarot brand pieces, all drawn in code (original art, no assets).

/// Turn off for tests: an endless animation stops `pumpAndSettle` from finishing.
bool brandAnimations = true;

/// The logo: a tarot card outline with an eye, same drawing as the app icon.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'ShenTarot logo',
    image: true,
    child: SizedBox(
      width: size * 0.62,
      height: size,
      child: CustomPaint(painter: EyeCardPainter(AppColors.gold)),
    ),
  );
}

/// "SHENTAROT" in spaced capitals with a soft gold gradient.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.size = 15});
  final double size;

  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (r) =>
        const LinearGradient(colors: [AppColors.goldLight, AppColors.gold])
            .createShader(r),
    blendMode: BlendMode.srcIn,
    child: Text(
      'SHENTAROT',
      // A logo stays one size; it should not grow with the text-size setting.
      textScaler: TextScaler.noScaling,
      style: TextStyle(
        fontSize: size,
        letterSpacing: size * 0.28,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );
}

/// Logo + wordmark side by side.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.size = 26});
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      BrandMark(size: size),
      SizedBox(width: size * 0.4),
      BrandWordmark(size: size * 0.6),
    ],
  );
}

class EyeCardPainter extends CustomPainter {
  const EyeCardPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = math.max(1, w * 0.045)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          stroke.strokeWidth / 2,
          stroke.strokeWidth / 2,
          w - stroke.strokeWidth,
          h - stroke.strokeWidth,
        ),
        Radius.circular(w * 0.1),
      ),
      stroke,
    );
    final c = Offset(w / 2, h / 2);
    final ew = w * 0.62, eh = ew * 0.4;
    final eye = Path()
      ..moveTo(c.dx - ew / 2, c.dy)
      ..quadraticBezierTo(c.dx, c.dy - eh * 1.6, c.dx + ew / 2, c.dy)
      ..quadraticBezierTo(c.dx, c.dy + eh * 1.6, c.dx - ew / 2, c.dy)
      ..close();
    canvas.drawPath(eye, stroke);
    canvas.drawCircle(c, eh * 0.6, stroke);
    canvas.drawCircle(c, eh * 0.22, fill);
  }

  @override
  bool shouldRepaint(EyeCardPainter old) => old.color != color;
}

/// Card back used for face-down cards, the landing fan and the paywall.
class CardBack extends StatelessWidget {
  const CardBack({super.key, this.width = 90});
  final double width;

  @override
  Widget build(BuildContext context) {
    final r = width * 0.09;
    return Container(
      width: width,
      height: width * 1.6,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceHigh, AppColors.background],
        ),
        border: Border.all(color: AppColors.gold, width: 1.5),
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.22),
            blurRadius: width * 0.25,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(width * 0.07),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(r * 0.6),
        ),
        child: Center(
          child: SizedBox(
            width: width * 0.44,
            height: width * 0.7,
            child: CustomPaint(
              painter: EyeCardPainter(AppColors.gold.withValues(alpha: 0.85)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three card backs fanned out and gently floating. Stays still when the
/// device asks for reduced motion.
class CardFan extends StatefulWidget {
  const CardFan({super.key, this.cardWidth = 120});
  final double cardWidth;

  @override
  State<CardFan> createState() => _CardFanState();
}

class _CardFanState extends State<CardFan> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!brandAnimations || MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.cardWidth;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = Curves.easeInOut.transform(_c.value);
          Widget card(double angle, double dx, double dy) =>
              Transform.translate(
                offset: Offset(
                  dx * w,
                  dy * w + (t - 0.5) * 8 * (angle == 0 ? 1.4 : 1),
                ),
                child: Transform.rotate(
                  angle: angle,
                  child: CardBack(width: w),
                ),
              );
          return SizedBox(
            width: w * 2.4,
            height: w * 1.9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                card(-0.28, -0.62, 0.08),
                card(0.28, 0.62, 0.08),
                card(0, 0, -0.02),
              ],
            ),
          );
        },
      ),
    );
  }
}
