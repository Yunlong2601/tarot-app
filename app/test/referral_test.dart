import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/app/flags.dart';
import 'package:shentarot/core/referral_service.dart';
import 'package:shentarot/core/subscription_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/main.dart';

import 'subscription_test.dart' show FakeSubscriptions;

class _FakeReferrals implements ReferralBackend {
  final redeemed = <String>[];
  @override
  Future<ReferralInfo> me() async => const ReferralInfo(
    code: 'ABCD2345',
    friendsJoined: 4,
    friendsPaid: 3,
    monthsEarned: 2,
    monthsPending: 1,
    maxPerYear: 6,
    friends: [(joined: '2026-10-10', status: 'credited')],
  );
  @override
  Future<ReferralOffer> redeem(String code, String platform) async {
    redeemed.add('$code/$platform');
    return const ReferralOffer(playOfferTag: 'referral-50');
  }
}

void main() {
  brandAnimations = false;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
  setUp(() => SharedPreferences.setMockInitialValues({}));

  void tall(WidgetTester t) {
    t.view.physicalSize = const Size(1080, 6000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
  }

  test('tiers by friends who paid', () {
    expect(tierFor(0), isNull);
    expect(tierFor(1)!.name, 'Seeker');
    expect(tierFor(5)!.name, 'Adept');
    expect(tierFor(10)!.name, 'Oracle');
    expect(nextTier(3)!.name, 'Mystic');
    expect(nextTier(12), isNull);
  });

  testWidgets('hidden unless referrals are on', (t) async {
    tall(t);
    await t.pumpWidget(
      ShenTarotApp(initialState: AppState(deck: deck, onboarded: true)),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('You').last);
    await t.pumpAndSettle();
    expect(find.text('Invite friends'), findsNothing);
  });

  testWidgets('invite screen: tier, credits, friends; a friend code opens '
      'the 50% annual offer', (t) async {
    tall(t);
    referralsEnabled = true;
    addTearDown(() => referralsEnabled = false);
    final refs = _FakeReferrals();
    final subs = FakeSubscriptions()
      ..friendPlan = const PlanOption(
        id: 'annual-friend',
        title: 'Annual',
        priceString: '\$99.99',
        periodLabel: 'per year',
        trialLabel: '\$49.99 for your first year',
        trialIsFree: false,
        price: 99.99,
      );
    final s = AppState(
      deck: deck,
      onboarded: true,
      referralApi: refs,
      subscriptions: subs,
    );
    await t.pumpWidget(ShenTarotApp(initialState: s));
    await t.pumpAndSettle();
    await t.tap(find.text('You').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Invite friends'));
    await t.pumpAndSettle();
    expect(find.text('Adept'), findsOneWidget); // 3 friends paid
    expect(
      find.text('3 of 6 friends who subscribed to reach Mystic'),
      findsOneWidget,
    );
    expect(find.text('ABCD2345'), findsOneWidget);
    expect(
      find.text('2 earned · 1 pending · 4 friends joined'),
      findsOneWidget,
    );
    expect(find.text('A friend joined on 2026-10-10'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'wxyz6789');
    await t.tap(find.text('Use code'));
    await t.pumpAndSettle();
    expect(refs.redeemed.single, 'wxyz6789/android');
    // The paywall now leads with the friend's annual offer.
    expect(find.text('Start for \$49.99'), findsOneWidget);
    expect(
      find.textContaining('\$49.99 for your first year, then \$99.99 per year'),
      findsOneWidget,
    );
  });
}
