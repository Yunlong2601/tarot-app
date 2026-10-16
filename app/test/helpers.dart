import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Read tab -> "Photo reading" (the default main button).
Future<void> goPhoto(WidgetTester t) async {
  await tapVisible(t, find.text('Photo reading'));
}

/// You tab -> Reading History.
Future<void> goHistory(WidgetTester t) async {
  await t.tap(find.text('You').last);
  await t.pumpAndSettle();
  await tapVisible(t, find.text('Reading History'));
}

/// Scrolls the first scrollable until [f] is built and on screen, then taps it.
/// Needed at large text sizes where list items start below the fold.
Future<void> tapVisible(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  } else {
    await t.ensureVisible(f.first);
  }
  await t.pumpAndSettle();
  await t.tap(f.first);
  await t.pumpAndSettle();
}
