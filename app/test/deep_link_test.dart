import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/features/read/ask_screen.dart';
import 'package:shentarot/features/read/read_home_screen.dart';
import 'package:shentarot/main.dart';

void main() {
  brandAnimations = false;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  testWidgets('a shared reading link opens "ask your own question"', (t) async {
    await t.pumpWidget(
      ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
    );
    await t.pumpAndSettle();
    GoRouter.of(t.element(find.byType(ReadHomeScreen))).go('/s/abc123');
    await t.pumpAndSettle();
    expect(find.byType(AskScreen), findsOneWidget);
  });
}
