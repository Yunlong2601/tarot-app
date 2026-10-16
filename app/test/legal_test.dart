import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/main.dart';
import 'package:shentarot/app/brand.dart';

void main() {
  brandAnimations = false;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  test('bundled legal texts exist and carry the key statements', () {
    final privacy = File('assets/legal/privacy.txt').readAsStringSync();
    final terms = File('assets/legal/terms.txt').readAsStringSync();
    final disclaimer = File('assets/legal/disclaimer.txt').readAsStringSync();
    expect(privacy, contains('not saved and is not sent'));
    expect(privacy, contains('Anthropic'));
    expect(terms, contains('renews automatically'));
    expect(terms, contains('cancelled at least 24 hours'));
    expect(disclaimer, contains('entertainment and self-reflection'));
  });

  testWidgets('privacy screen shows the bundled text', (tester) async {
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('analysed on your phone'), findsOneWidget);
  });

  testWidgets(
    'the disclaimer lives inside the Terms of Use, not as its own tab',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('You').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Disclaimer'), findsNothing);
      await tester.tap(find.text('Terms of Use'));
      await tester.pumpAndSettle();
      expect(find.text('Disclaimer'), findsOneWidget);
      expect(find.textContaining('not predictions'), findsWidgets);
    },
  );
}
