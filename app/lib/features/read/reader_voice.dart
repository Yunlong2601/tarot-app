import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';

/// The reader's voice, shared by the question screen and the conversation
/// under a reading: serif lines that write themselves in, quiet suggestions,
/// and the user's own words set right. The reader is always labelled as AI.

/// True when lines should appear at once: reduced motion, or tests.
bool readerCalm(BuildContext context) =>
    !brandAnimations || MediaQuery.disableAnimationsOf(context);

/// A small candle-lit mark with an honest label: the reader is AI.
class ReaderSigil extends StatelessWidget {
  const ReaderSigil({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.goldDeep, width: 0.8),
          gradient: RadialGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.28),
              AppColors.background.withValues(alpha: 0),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: const BrandMark(size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('The reader'),
              style: const TextStyle(
                fontFamily: displayFont,
                fontFamilyFallback: displayFallback,
                fontSize: 18,
                color: AppColors.gold,
              ),
            ),
            Text(
              tr('AI · for reflection, not prediction'),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    ],
  );
}

/// One line from the reader: serif, with a fine gold rule in the margin. It
/// writes itself in like ink, unless the user asked for less motion.
class ReaderLine extends StatelessWidget {
  const ReaderLine(
    this.text, {
    super.key,
    this.delay = 0,
    this.muted = false,
    this.body = false,
  });
  final String text;
  final double delay;
  final bool muted;

  /// A longer answer: upright serif at reading size.
  final bool body;

  @override
  Widget build(BuildContext context) {
    final serif = !muted && !body;
    final style = TextStyle(
      fontFamily: serif ? displayFont : null,
      fontFamilyFallback: serif ? displayFallback : null,
      fontSize: muted ? 16 : (body ? 17 : 23),
      height: body ? 1.5 : 1.35,
      fontWeight: muted ? FontWeight.w400 : FontWeight.w500,
      color: muted ? const Color(0xFFC9C4B8) : AppColors.ink,
    );
    Widget line(String shown) => Container(
      padding: const EdgeInsetsDirectional.only(start: 14, bottom: 6, top: 2),
      decoration: const BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: AppColors.goldDeep, width: 0.8),
        ),
      ),
      child: shown.length == text.length
          ? Text(text, style: style)
          : Stack(
              children: [
                // The full text keeps the line's height steady while it writes in.
                Opacity(opacity: 0, child: Text(text, style: style)),
                Text(shown, style: style),
              ],
            ),
    );
    if (readerCalm(context)) {
      return Semantics(
        label: text,
        child: ExcludeSemantics(child: line(text)),
      );
    }
    final ms = math.min(450 + text.length * 14, 1800);
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: ms + (delay * 1000).round()),
          builder: (_, v, _) {
            final start = delay * 1000 / (ms + delay * 1000);
            final p = ((v - start) / (1 - start)).clamp(0.0, 1.0);
            final n = (text.length * Curves.easeOut.transform(p)).round();
            return line(text.substring(0, math.min(n, text.length)));
          },
        ),
      ),
    );
  }
}

/// A suggested opening, offered quietly rather than as a button.
class ReaderWhisper extends StatelessWidget {
  const ReaderWhisper({
    super.key,
    required this.text,
    required this.onTap,
    this.icon = Icons.auto_awesome,
  });
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.goldDeep),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.goldLight,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The user's question once sent: set right, in quotation marks.
class UserLine extends StatelessWidget {
  const UserLine(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Container(
        padding: const EdgeInsetsDirectional.only(end: 14, top: 2, bottom: 6),
        decoration: const BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(color: AppColors.textMuted, width: 0.8),
          ),
        ),
        child: Text(
          '“$text”',
          textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 17, height: 1.4),
        ),
      ),
    ),
  );
}
