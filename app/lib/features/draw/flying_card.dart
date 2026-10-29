import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../app/theme.dart';

/// Flies a face-down card across the screen in an overlay, from where it was
/// picked to its slot in the spread, then calls [onLanded].
class FlyingCard extends StatefulWidget {
  const FlyingCard({
    super.key,
    required this.fromCenter,
    required this.fromWidth,
    required this.fromAngle,
    required this.toCenter,
    required this.toWidth,
    required this.toAngle,
    required this.onLanded,
  });

  final Offset fromCenter;
  final double fromWidth;
  final double fromAngle;
  final Offset toCenter;
  final double toWidth;
  final double toAngle;
  final VoidCallback onLanded;

  static const duration = Duration(milliseconds: 560);

  @override
  State<FlyingCard> createState() => _FlyingCardState();
}

class _FlyingCardState extends State<FlyingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: FlyingCard.duration)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onLanded();
        })
        ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(_c.value);
        // Arc upwards a little on the way, like a hand lifting the card.
        final lift = math.sin(t * math.pi) * 48;
        final c = Offset.lerp(
          widget.fromCenter,
          widget.toCenter,
          t,
        )!.translate(0, -lift);
        final w = widget.fromWidth + (widget.toWidth - widget.fromWidth) * t;
        final h = w * 1.6;
        final angle =
            widget.fromAngle + (widget.toAngle - widget.fromAngle) * t;
        return Stack(
          children: [
            Positioned(
              left: c.dx - w / 2,
              top: c.dy - h / 2,
              width: w,
              height: h,
              child: Transform.rotate(
                angle: angle,
                child: Transform.scale(
                  scale: 1 + math.sin(t * math.pi) * 0.12,
                  // A soft gold glow while the card is in the air.
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(
                            alpha: 0.55 * math.sin(t * math.pi),
                          ),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CardBack(width: w),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
