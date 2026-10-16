import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Read tab -> "Photo reading" -> skip the question -> the recommended spread
/// (Past, Present, Future for a blank question) -> the photo reading screen.
Future<void> goPhoto(WidgetTester t) async {
  await tapVisible(t, find.text('Photo reading'));
  await tapVisible(t, find.text('Skip: general reading'));
  await tapVisible(t, find.text('Start reading'));
}

/// Read tab, with the trial reading already used: Library > Classics >
/// Celtic Cross sends a free user to the paywall.
Future<void> openPaywall(WidgetTester t) async {
  await t.tap(find.text('Library').last);
  await t.pumpAndSettle();
  await tapVisible(t, find.text('Classics'));
  for (var i = 0; i < 20 && find.text('Celtic Cross').evaluate().isEmpty; i++) {
    await t.drag(find.byType(ListView).last, const Offset(0, -500));
    await t.pumpAndSettle();
  }
  await t.ensureVisible(find.text('Celtic Cross'));
  await t.pumpAndSettle();
  await t.tap(find.text('Celtic Cross'));
  await t.pumpAndSettle();
}

/// You tab -> Reading History.
Future<void> goHistory(WidgetTester t) async {
  await t.tap(find.text('You').last);
  await t.pumpAndSettle();
  await tapVisible(t, find.text('Reading History'));
}

/// Scrolls the first scrollable until [f] is built and on screen, then taps it.
/// Needed at large text sizes where list items start below the fold.
Future<void> tapVisible(
  WidgetTester t,
  Finder f, {
  bool lastScrollable = false,
}) async {
  if (f.evaluate().isEmpty) {
    final sc = find.byType(Scrollable);
    await t.scrollUntilVisible(
      f,
      200,
      scrollable: lastScrollable ? sc.last : sc.first,
    );
  } else {
    await t.ensureVisible(f.first);
  }
  await t.pumpAndSettle();
  await t.tap(f.first);
  await t.pumpAndSettle();
}
