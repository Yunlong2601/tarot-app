import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/theme.dart';
import 'package:shentarot/core/subscription_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';
import 'package:shentarot/main.dart';

import 'helpers.dart';

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final l1 = _lum(a), l2 = _lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

class _Plans implements SubscriptionService {
  @override
  bool get isConfigured => true;
  @override
  Future<void> start(String id, void Function(bool) cb) async {}
  @override
  Future<List<PlanOption>> plans() async => const [
    PlanOption(
      id: 'a',
      title: 'Annual',
      priceString: r'$39.99',
      periodLabel: 'per year',
      trialLabel: '7 days free',
    ),
    PlanOption(
      id: 'm',
      title: 'Monthly',
      priceString: r'$7.99',
      periodLabel: 'per month',
    ),
  ];
  @override
  Future<bool> purchase(PlanOption p) async => true;
  @override
  Future<bool> restore() async => false;
  @override
  Future<String> manageUrl() async => 'https://example.invalid';
}

void main() {
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());

  group('colour contrast (WCAG AA 4.5:1 for text)', () {
    test('text colours on the dark backgrounds', () {
      for (final bg in [
        AppColors.background,
        AppColors.surface,
        AppColors.surfaceHigh,
      ]) {
        expect(
          contrast(AppColors.textMuted, bg),
          greaterThanOrEqualTo(4.5),
          reason: 'muted on $bg',
        );
        expect(
          contrast(AppColors.gold, bg),
          greaterThanOrEqualTo(4.5),
          reason: 'gold on $bg',
        );
      }
    });

    test('button label on the gold primary button', () {
      final scheme = buildTheme().colorScheme;
      expect(
        contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  Reading sample() => Reading(
    id: 'a',
    createdAt: DateTime(2026, 5, 5),
    spread: SpreadType.celticCross,
    cards: [
      for (final c in deck.cards.take(10)) DrawnCard(card: c, reversed: true),
    ],
    interpretation: 'A long reflective paragraph. ' * 12,
    question: 'What should I focus on this week, and why does it matter to me?',
  );

  AppState state({bool premium = false}) {
    final s = AppState(deck: deck, onboarded: true, subscriptions: _Plans());
    if (premium) s.setPremium(true);
    s.addReading(sample());
    return s;
  }

  void phone(WidgetTester t, {double scale = 1}) {
    t.view.physicalSize = const Size(750, 1334); // iPhone SE-size at 2x
    t.view.devicePixelRatio = 2;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.view.reset);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> open(WidgetTester t, AppState s, String tab) async {
    await t.pumpWidget(ShenTarotApp(initialState: s));
    await t.pumpAndSettle();
    if (tab != 'Read') {
      await t.tap(find.text(tab).last);
      await t.pumpAndSettle();
    }
  }

  group('largest text size, small phone: nothing overflows', () {
    for (final tab in ['Read', 'Guide', 'Library', 'You']) {
      testWidgets(tab, (t) async {
        phone(t, scale: 2.0);
        await open(t, state(premium: true), tab);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('onboarding', (t) async {
      phone(t, scale: 2.0);
      await t.pumpWidget(ShenTarotApp(initialState: AppState(deck: deck)));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });

    testWidgets('reading with ten cards', (t) async {
      phone(t, scale: 2.0);
      await open(t, state(premium: true), 'Read');
      await goHistory(t);
      await tapVisible(t, find.textContaining('Celtic Cross'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });

    testWidgets('paywall', (t) async {
      phone(t, scale: 2.0);
      await open(t, state(), 'Read');
      await goPhoto(t);
      await tapVisible(t, find.textContaining('Three cards'));
      await t.pumpAndSettle();
      expect(find.text('Unlock Premium'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('semantics guidelines', () {
    testWidgets('scan screen: tap targets and labels', (t) async {
      phone(t);
      final h = t.ensureSemantics();
      await open(t, state(), 'Read');
      await goPhoto(t);
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      h.dispose();
    });

    testWidgets('settings screen', (t) async {
      phone(t);
      final h = t.ensureSemantics();
      await open(t, state(), 'You');
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      h.dispose();
    });

    testWidgets('paywall', (t) async {
      phone(t);
      final h = t.ensureSemantics();
      await open(t, state(), 'Read');
      await goPhoto(t);
      await tapVisible(t, find.textContaining('Three cards'));
      await t.pumpAndSettle();
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      h.dispose();
    });

    testWidgets('reading screen announces each card with orientation', (
      t,
    ) async {
      phone(t);
      final h = t.ensureSemantics();
      await open(t, state(premium: true), 'Read');
      await goHistory(t);
      await tapVisible(t, find.textContaining('Celtic Cross'));
      await t.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp(r', reversed$')), findsWidgets);
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      h.dispose();
    });
  });
}
