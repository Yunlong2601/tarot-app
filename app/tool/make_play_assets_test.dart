// Renders the Google Play feature graphic (1024x500) and the 512x512 icon into
// ../store/play/. No text is drawn (test fonts are placeholders); the logo,
// card fan and colours carry the brand.
// Run: flutter test tool/make_play_assets_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/app/theme.dart';

Future<void> _png(WidgetTester t, GlobalKey key, String path, double ratio) async {
  await t.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).createSync(recursive: true);
    File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('feature graphic', (t) async {
    brandAnimations = false;
    final key = GlobalKey();
    t.view.physicalSize = const Size(1024, 500);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: RepaintBoundary(
          key: key,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.35, -0.2),
                radius: 1.1,
                colors: [Color(0xFF2A2415), Color(0xFF0B0B0B)],
              ),
            ),
            child: const Center(child: CardFan(cardWidth: 150)),
          ),
        ),
      ),
    );
    await t.pump();
    await _png(t, key, '../store/play/feature-graphic.png', 1);
  });
}
