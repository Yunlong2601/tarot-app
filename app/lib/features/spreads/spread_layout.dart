import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/spreads.dart';

/// Draws a spread's layout. By default each slot is a small outlined card with
/// its number; pass [slotBuilder] to put real content (card backs, faces) in
/// the slots. Position 2 of the Celtic Cross lies across position 1.
class SpreadLayoutView extends StatelessWidget {
  const SpreadLayoutView({
    super.key,
    required this.type,
    this.slotBuilder,
    this.cardWidth,
    this.highlight,
  });

  final SpreadType type;

  /// Builds the content of slot [index] at the given size. Null = outline.
  final Widget Function(int index, double width, double height)? slotBuilder;

  /// Overrides the automatic card width.
  final double? cardWidth;

  /// Slot to emphasise (the next card to place).
  final int? highlight;

  /// Width / height of the layout box for each spread shape.
  static double aspectOf(SpreadType t) => switch (t) {
    SpreadType.single || SpreadType.yesNo => 1.0,
    SpreadType.threeCard ||
    SpreadType.threeDecision ||
    SpreadType.threeHhh ||
    SpreadType.growthShadowLight ||
    SpreadType.newMoon ||
    SpreadType.fullMoon ||
    SpreadType.loveConnection ||
    SpreadType.loveBring ||
    SpreadType.careerPath => 2.1,
    SpreadType.fiveCross || SpreadType.careerStrengths => 1.05,
    SpreadType.celticCross => 1.0,
    _ => 1.15, // seven-card arcs
  };

  double _autoWidth(double w) {
    final n = type.cardCount;
    if (n == 1) return w * 0.34;
    if (n == 3) return w * 0.22;
    if (n == 5) return w * 0.17;
    if (n == 7) return w * 0.12;
    return w * 0.13;
  }

  @override
  Widget build(BuildContext context) {
    final def = type.def;
    return AspectRatio(
      aspectRatio: aspectOf(type),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth, h = box.maxHeight;
          final cw = math.min(cardWidth ?? _autoWidth(w), h * 0.62);
          final ch = cw * 1.6;
          final slots = <Widget>[];
          for (var i = 0; i < def.layout.length; i++) {
            final p = def.layout[i];
            final rotate = type == SpreadType.celticCross && i == 1;
            var left = p.dx * w - cw / 2;
            var top = p.dy * h - ch / 2;
            left = left.clamp(0.0, math.max(0.0, w - cw));
            top = top.clamp(0.0, math.max(0.0, h - ch));
            final child = slotBuilder != null
                ? slotBuilder!(i, cw, ch)
                : _OutlineSlot(
                    number: i + 1,
                    width: cw,
                    height: ch,
                    highlighted: highlight == i,
                  );
            slots.add(
              Positioned(
                left: left,
                top: top,
                width: cw,
                height: ch,
                child: rotate
                    ? Transform.rotate(angle: math.pi / 2, child: child)
                    : child,
              ),
            );
          }
          return Stack(clipBehavior: Clip.none, children: slots);
        },
      ),
    );
  }
}

class _OutlineSlot extends StatelessWidget {
  const _OutlineSlot({
    required this.number,
    required this.width,
    required this.height,
    required this.highlighted,
  });
  final int number;
  final double width;
  final double height;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final size = math.min(width * 0.5, 22.0);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: highlighted ? 1 : 0.55),
          width: highlighted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(math.max(3, width * 0.1)),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
        ),
        child: Text(
          '$number',
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: size * 0.5, color: AppColors.gold),
        ),
      ),
    );
  }
}
