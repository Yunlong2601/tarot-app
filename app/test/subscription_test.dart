import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      price: 52.98,
      perMonthString: 'S\$4.41',
    ),
    PlanOption(
      id: 'monthly',
      title: 'Monthly',
      priceString: 'S\$10.98',
      periodLabel: 'per month',
      price: 10.98,
      productId: 'monthly',
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

  @override
  Future<void> switchUser(String appUserId) async {}

  String? currentId = 'monthly';
  @override
  Future<String?> currentProductId() async => currentId;

  int? monthsPaid;
  @override
  Future<int?> monthlyMonthsPaid() async => monthsPaid;

  PlanOption? switchedTo;
  @override
  Future<bool> switchTo(PlanOption plan) async {
    switchedTo = plan;
    return true;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
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
        initialState: (AppState(
          deck: deck,
          onboarded: true,
          subscriptions: FakeSubscriptions(),
        )..trialUsed = true),
      ),
    );
    await tester.pumpAndSettle();
    await openPaywall(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('S\$52.98 per year'), findsWidgets);
    expect(find.textContaining('7 days free, then'), findsOneWidget);
    expect(find.text('Start 7 days free trial'), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
    // Honest anchoring from store prices: 52.98 vs 10.98 x 12 = 131.76.
    expect(find.text('Best value'), findsOneWidget);
    expect(
      find.textContaining('just S\$4.41/month · save 59% vs monthly'),
      findsOneWidget,
    );
  });

  testWidgets('buying unlocks premium and closes the paywall', (tester) async {
    tall(tester);
    final subs = FakeSubscriptions();
    final state = AppState(deck: deck, onboarded: true, subscriptions: subs)
      ..trialUsed = true;
    await tester.pumpWidget(ShenTarotApp(initialState: state));
    await tester.pumpAndSettle();
    await openPaywall(tester);
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
      ShenTarotApp(
        initialState: AppState(deck: deck, onboarded: true)..trialUsed = true,
      ),
    );
    await tester.pumpAndSettle();
    await openPaywall(tester);
    await tester.pumpAndSettle();
    expect(find.text('Subscriptions are not available yet.'), findsOneWidget);
    final buy = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(buy.onPressed, isNull);
    expect(find.text('Restore Purchases'), findsOneWidget);
  });

  testWidgets('monthly subscribers see the annual offer after 3 months', (
    tester,
  ) async {
    tall(tester);
    final subs = FakeSubscriptions()..monthsPaid = 3;
    final state = AppState(deck: deck, onboarded: true, subscriptions: subs)
      ..setPremium(true);
    await tester.pumpWidget(ShenTarotApp(initialState: state));
    await tester.pumpAndSettle();
    expect(find.text('Thank you for 3 months of Premium'), findsOneWidget);
    expect(
      find.textContaining(
        'S\$10.98 per month. The annual plan is S\$52.98 a year',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Switch to annual'));
    await tester.pumpAndSettle();
    expect(subs.switchedTo?.id, 'annual');
    expect(find.text('Thank you for 3 months of Premium'), findsNothing);
  });

  testWidgets('no annual offer before 3 months, or after it was dismissed', (
    tester,
  ) async {
    tall(tester);
    final subs = FakeSubscriptions()..monthsPaid = 2;
    final state = AppState(deck: deck, onboarded: true, subscriptions: subs)
      ..setPremium(true);
    await tester.pumpWidget(ShenTarotApp(initialState: state));
    await tester.pumpAndSettle();
    expect(find.textContaining('months of Premium'), findsNothing);
    subs.monthsPaid = 4;
    await state.dismissAnnualUpgrade(); // seen once already
    expect(await state.annualUpgradeMonths(), isNull);
    subs.monthsPaid = 6;
    expect(await state.annualUpgradeMonths(), 6); // one reminder later
  });
}
