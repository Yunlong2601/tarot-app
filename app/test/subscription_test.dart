import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/core/subscription_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/main.dart';

import 'dart:io';

import 'helpers.dart';

import 'package:shentarot/app/brand.dart';

class FakeSubscriptions implements SubscriptionService {
  FakeSubscriptions({this.restores = false});
  final bool restores;
  int purchases = 0;
  void Function(bool)? _notify;

  @override
  bool get isConfigured => true;
  @override
  Future<void> start(String id, void Function(bool) cb) async => _notify = cb;
  @override
  Future<List<PlanOption>> plans() async => const [
    PlanOption(
      id: 'annual',
      title: 'Annual',
      priceString: 'S\$52.98',
      periodLabel: 'per year',
      trialLabel: '7 days free',
    ),
    PlanOption(
      id: 'monthly',
      title: 'Monthly',
      priceString: 'S\$10.98',
      periodLabel: 'per month',
    ),
  ];
  @override
  Future<bool> purchase(PlanOption plan) async {
    purchases++;
    _notify?.call(true);
    return true;
  }

  @override
  Future<bool> restore() async => restores;
  @override
  Future<String> manageUrl() async => 'https://example.invalid';
}

void main() {
  brandAnimations = false;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  void tall(WidgetTester t) {
    t.view.physicalSize = const Size(1080, 5000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
  }

  testWidgets('paywall shows store prices, trial terms and required links', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      ShenTarotApp(
        initialState: AppState(
          deck: deck,
          onboarded: true,
          subscriptions: FakeSubscriptions(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await goPhoto(tester);
    await tester.tap(find.textContaining('Three cards'));
    await tester.pumpAndSettle();
    expect(find.textContaining('S\$52.98 per year'), findsWidgets);
    expect(find.textContaining('7 days free, then'), findsOneWidget);
    expect(find.text('Start 7 days free trial'), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
  });

  testWidgets('buying unlocks premium and closes the paywall', (tester) async {
    tall(tester);
    final subs = FakeSubscriptions();
    final state = AppState(deck: deck, onboarded: true, subscriptions: subs);
    await tester.pumpWidget(ShenTarotApp(initialState: state));
    await tester.pumpAndSettle();
    await goPhoto(tester);
    await tester.tap(find.textContaining('Three cards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start 7 days free trial'));
    await tester.pumpAndSettle();
    expect(subs.purchases, 1);
    expect(state.isPremium, isTrue);
    expect(find.text('Unlock Premium'), findsNothing);
  });

  testWidgets('without store keys the paywall cannot sell anything', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
    );
    await tester.pumpAndSettle();
    await goPhoto(tester);
    await tester.tap(find.textContaining('Three cards'));
    await tester.pumpAndSettle();
    expect(find.text('Subscriptions are not available yet.'), findsOneWidget);
    final buy = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(buy.onPressed, isNull);
    expect(find.text('Restore Purchases'), findsOneWidget);
  });
}
