import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'i18n.dart';
import 'theme.dart';

/// The look of the card backs. Classic is free; the others come with Premium.
/// Stored by name: do not rename.
enum DeckTheme { classic, midnight, rose, moonlight, sun }

enum DeckSymbol { eye, star, rose, crescent, sun }

extension DeckThemeLook on DeckTheme {
  String get label => switch (this) {
    DeckTheme.classic => tr('Classic gold'),
    DeckTheme.midnight => tr('Midnight'),
    DeckTheme.rose => tr('Rose'),
    DeckTheme.moonlight => tr('Moonlight'),
    DeckTheme.sun => tr('Sun'),
  };

  bool get isPremium => this != DeckTheme.classic;

  /// Border, symbol and glow.
  Color get accent => switch (this) {
    DeckTheme.classic => AppColors.gold,
    DeckTheme.midnight => const Color(0xFF9DB4E0),
    DeckTheme.rose => const Color(0xFFE3A3A8),
    DeckTheme.moonlight => const Color(0xFFD9D4EC),
    DeckTheme.sun => const Color(0xFFF0B04A),
  };

  /// Top-left and bottom-right of the back's gradient.
  (Color, Color) get fill => switch (this) {
    DeckTheme.classic => (AppColors.surfaceHigh, AppColors.background),
    DeckTheme.midnight => (const Color(0xFF16213A), const Color(0xFF070A14)),
    DeckTheme.rose => (const Color(0xFF2E1A1E), const Color(0xFF120A0C)),
    DeckTheme.moonlight => (const Color(0xFF24223A), const Color(0xFF0C0B16)),
    DeckTheme.sun => (const Color(0xFF2E2210), const Color(0xFF110C05)),
  };

  DeckSymbol get symbol => switch (this) {
    DeckTheme.classic => DeckSymbol.eye,
    DeckTheme.midnight => DeckSymbol.star,
    DeckTheme.rose => DeckSymbol.rose,
    DeckTheme.moonlight => DeckSymbol.crescent,
    DeckTheme.sun => DeckSymbol.sun,
  };
}

DeckTheme deckThemeNamed(String? name) => DeckTheme.values.firstWhere(
  (t) => t.name == name,
  orElse: () => DeckTheme.classic,
);

/// The star, rose, crescent and sun marks for the themed backs, drawn in
/// code like the eye (original art, no assets).
class DeckSymbolPainter extends CustomPainter {
  const DeckSymbolPainter(this.symbol, this.color);
  final DeckSymbol symbol;
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
    final r = w * 0.3;
    switch (symbol) {
      case DeckSymbol.eye:
        break;
      case DeckSymbol.star:
        // An eight-pointed star.
        final p = Path();
        for (var i = 0; i < 16; i++) {
          final a = i * math.pi / 8 - math.pi / 2;
          final d = i.isEven ? r : r * 0.42;
          final pt = c + Offset(math.cos(a), math.sin(a)) * d;
          i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(p..close(), stroke);
        canvas.drawCircle(c, r * 0.12, fill);
      case DeckSymbol.rose:
        // Five petals around a centre.
        for (var i = 0; i < 5; i++) {
          final a = i * 2 * math.pi / 5 - math.pi / 2;
          canvas.drawCircle(
            c + Offset(math.cos(a), math.sin(a)) * r * 0.48,
            r * 0.42,
            stroke,
          );
        }
        canvas.drawCircle(c, r * 0.16, fill);
      case DeckSymbol.crescent:
        final moon = Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCircle(center: c, radius: r)),
          Path()..addOval(
            Rect.fromCircle(
              center: c + Offset(r * 0.45, -r * 0.2),
              radius: r * 0.82,
            ),
          ),
        );
        canvas.drawPath(moon, fill);
        canvas.drawCircle(c + Offset(r * 0.55, r * 0.55), r * 0.07, fill);
        canvas.drawCircle(c + Offset(r * 0.8, -r * 0.75), r * 0.05, fill);
      case DeckSymbol.sun:
        canvas.drawCircle(c, r * 0.45, stroke);
        for (var i = 0; i < 12; i++) {
          final a = i * math.pi / 6;
          final dir = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(
            c + dir * r * 0.65,
            c + dir * r * (i.isEven ? 1.0 : 0.85),
            stroke,
          );
        }
    }
  }

  @override
  bool shouldRepaint(DeckSymbolPainter old) =>
      old.symbol != symbol || old.color != color;
}
