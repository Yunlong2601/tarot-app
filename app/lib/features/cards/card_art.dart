import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/models.dart';

/// Shows the card's bundled public-domain art when present, otherwise a
/// styled placeholder. Reversed cards render upside down, like on the table.
class CardArt extends StatelessWidget {
  const CardArt({
    super.key,
    required this.card,
    this.reversed = false,
    this.width = 90,
  });
  final TarotCard card;
  final bool reversed;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.6;
    final placeholder = Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.gold, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        card.name,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: width / 7.5, color: AppColors.gold),
      ),
    );
    return Semantics(
      label: '${card.name}${reversed ? ', reversed' : ''}',
      image: true,
      excludeSemantics: true,
      child: Transform.rotate(
        angle: reversed ? 3.14159265 : 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            card.artAsset,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          ),
        ),
      ),
    );
  }
}
