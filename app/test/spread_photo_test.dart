import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shentarot/app/app_scope.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/core/reading_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/features/scan/spread_photo.dart';

class _Fake extends UnconfiguredReadingService implements SpreadIdentifier {
  int calls = 0;
  @override
  Future<SpreadScan> identifySpread(List<int> jpegBytes) async {
    calls++;
    return const SpreadScan([
      (id: 'major_19_sun', reversed: false),
      (id: 'cups_five', reversed: true),
    ], unsure: true);
  }
}

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  testWidgets('asks consent once, names the cards, and the check step needs '
      'every card before the reading', (t) async {
    SharedPreferences.setMockInitialValues({});
    final fake = _Fake();
    final state = AppState(deck: deck, onboarded: true, readingService: fake);
    List<DrawnCard>? result;
    await t.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(
          home: Builder(
            builder: (c) => TextButton(
              onPressed: () async => result = await scanWholeSpread(
                c,
                SpreadType.threeCard,
                takePhoto: () async => Uint8List.fromList([1, 2, 3]),
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    expect(find.text('Photo of the whole spread'), findsOneWidget);
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(fake.calls, 1);
    expect(find.text('Check your cards'), findsOneWidget);
    expect(find.text('2 of 3 cards'), findsOneWidget);
    expect(find.text('Five of Cups (reversed)'), findsOneWidget);
    // Only 2 of 3 cards: the reading cannot start yet.
    final button = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Get my reading'),
    );
    expect(button.onPressed, isNull);
    // Flip the second card upright, remove the first.
    await t.tap(find.byTooltip('Upright'));
    await t.pumpAndSettle();
    expect(find.text('Five of Cups'), findsOneWidget);
    await t.tap(find.byTooltip('Delete').first);
    await t.pumpAndSettle();
    expect(find.text('1 of 3 cards'), findsOneWidget);
    expect(result, isNull);
    // The consent is remembered.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('spread_photo_consent'), isTrue);
  });
}
