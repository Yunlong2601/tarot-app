// Renders the original Veilscan app icon to assets/icon/*.png.
// Run: flutter test tool/make_icon_test.dart   (then: dart run flutter_launcher_icons)
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

const _gold = ui.Color(0xFFD9B26F);
const _bgTop = ui.Color(0xFF241D42);
const _bgBottom = ui.Color(0xFF0E0B1A);

void _paintMark(ui.Canvas c, double size, double scale) {
  c.save();
  c.translate(size / 2, size / 2);
  c.scale(scale);
  final stroke = ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..color = _gold
    ..strokeWidth = size * 0.018
    ..strokeCap = ui.StrokeCap.round
    ..strokeJoin = ui.StrokeJoin.round;
  final fill = ui.Paint()..color = _gold;

  // Card outline (tarot proportions ~ 0.6).
  final h = size * 0.74;
  final w = h * 0.6;
  c.drawRRect(
      ui.RRect.fromRectAndRadius(
          ui.Rect.fromCenter(center: ui.Offset.zero, width: w, height: h),
          ui.Radius.circular(size * 0.05)),
      stroke);
  c.drawRRect(
      ui.RRect.fromRectAndRadius(
          ui.Rect.fromCenter(center: ui.Offset.zero, width: w * 0.88, height: h * 0.9),
          ui.Radius.circular(size * 0.035)),
      stroke..strokeWidth = size * 0.007);
  stroke.strokeWidth = size * 0.018;

  // Eye: two arcs meeting at the corners.
  final ew = w * 0.62;
  final eh = ew * 0.42;
  final eye = ui.Path()
    ..moveTo(-ew / 2, 0)
    ..quadraticBezierTo(0, -eh * 1.6, ew / 2, 0)
    ..quadraticBezierTo(0, eh * 1.6, -ew / 2, 0)
    ..close();
  c.drawPath(eye, stroke);
  c.drawCircle(ui.Offset.zero, eh * 0.62, stroke);
  c.drawCircle(ui.Offset.zero, eh * 0.24, fill);

  // Rays above and below.
  for (final sign in [-1.0, 1.0]) {
    for (var i = -2; i <= 2; i++) {
      final a = i * 0.32;
      final r1 = h * 0.2;
      final r2 = h * (i == 0 ? 0.31 : 0.27);
      c.drawLine(
        ui.Offset(math.sin(a) * r1, sign * math.cos(a) * r1),
        ui.Offset(math.sin(a) * r2, sign * math.cos(a) * r2),
        stroke..strokeWidth = size * 0.012,
      );
    }
  }
  // Tiny stars in the card corners.
  for (final p in [
    ui.Offset(-w * 0.32, -h * 0.4),
    ui.Offset(w * 0.32, -h * 0.4),
    ui.Offset(-w * 0.32, h * 0.4),
    ui.Offset(w * 0.32, h * 0.4),
  ]) {
    c.drawCircle(p, size * 0.012, fill);
  }
  c.restore();
}

Future<void> _write(String path, double size, {required bool background, required double scale}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  if (background) {
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size, size),
      ui.Paint()
        ..shader = ui.Gradient.radial(ui.Offset(size / 2, size * 0.4), size * 0.75,
            [_bgTop, _bgBottom]),
    );
  }
  _paintMark(canvas, size, scale);
  final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('render icons', () async {
    await _write('assets/icon/icon.png', 1024, background: true, scale: 1.0);
    // Adaptive-icon foreground: content kept inside the central safe zone.
    await _write('assets/icon/icon_foreground.png', 1024, background: false, scale: 0.72);
    // iOS launch mark (transparent, shown on the dark launch background).
    const dir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
    await _write('$dir/LaunchImage.png', 168, background: false, scale: 1.0);
    await _write('$dir/LaunchImage@2x.png', 336, background: false, scale: 1.0);
    await _write('$dir/LaunchImage@3x.png', 504, background: false, scale: 1.0);
  });
}
