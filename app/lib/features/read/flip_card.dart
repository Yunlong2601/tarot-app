import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';

/// A face-down card that flips over when [flipped] becomes true.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.drawn,
    required this.flipped,
    required this.onTap,
  });
  final DrawnCard drawn;
  final bool flipped;
  final VoidCallback onTap;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(FlipCard old) {
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
