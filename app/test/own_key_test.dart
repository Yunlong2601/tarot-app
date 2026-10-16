import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/core/user_key_store.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/main.dart';

void main() {
  brandAnimations = false;
  ownKeyEnabled = true;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
  final key = 'sk-ant-${'k' * 40}';

  test('key shapes match the backend', () {
    expect(looksLikeKey(AiProvider.anthropic, key), isTrue);
    expect(looksLikeKey(AiProvider.openai, 'sk-${'o' * 40}'), isTrue);
    expect(looksLikeKey(AiProvider.anthropic, 'sk-${'o' * 40}'), isFalse);
    expect(looksLikeKey(AiProvider.openai, 'hello'), isFalse);
  });

  test('the key is used only while Premium; delete-all removes it', () async {
    final store = MemoryUserKeyStore();
    final s = AppState(deck: deck, userKeys: store);
    await s.setOwnKey(UserKey(AiProvider.anthropic, key));
    expect(await s.activeUserKey(), isNull); // not Premium
    s.setPremium(true);
    expect((await s.activeUserKey())!.key, key);
    await s.deleteAllData();
    expect(await store.read(), isNull);
    expect(s.usesOwnKey, isFalse);
  });

  testWidgets('Premium user saves a key from the You tab', (t) async {
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    final store = MemoryUserKeyStore();
    final s = AppState(deck: deck, onboarded: true, userKeys: store)
      ..setPremium(true);
    await t.pumpWidget(ShenTarotApp(initialState: s));
    await t.pumpAndSettle();
    await t.tap(find.text('You').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Your own AI key'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'not-a-key');
    await t.tap(find.text('Save key'));
    await t.pumpAndSettle();
    expect(find.textContaining('does not look like'), findsOneWidget);
    expect(await store.read(), isNull);
    await t.enterText(find.byType(TextField), key);
    await t.tap(find.text('Save key'));
    await t.pumpAndSettle();
    expect((await store.read())!.key, key);
    expect(find.text('Using your Anthropic (Claude) key'), findsOneWidget);
    expect(find.text(key), findsNothing);
  });

  testWidgets('hidden from the You tab when the flag is off', (t) async {
    ownKeyEnabled = false;
    addTearDown(() => ownKeyEnabled = true);
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    final s = AppState(deck: deck, onboarded: true)..setPremium(true);
    await s.setOwnKey(UserKey(AiProvider.anthropic, key));
    await t.pumpWidget(ShenTarotApp(initialState: s));
    await t.pumpAndSettle();
    await t.tap(find.text('You').last);
    await t.pumpAndSettle();
    expect(find.text('Your own AI key'), findsNothing);
    expect(await s.activeUserKey(), isNull);
  });

  testWidgets('free users are pointed to Premium', (t) async {
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    final s = AppState(deck: deck, onboarded: true);
    await t.pumpWidget(ShenTarotApp(initialState: s));
    await t.pumpAndSettle();
    await t.tap(find.text('You').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Your own AI key'));
    await t.pumpAndSettle();
    expect(find.text('Available with Premium'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
