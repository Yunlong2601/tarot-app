import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/flags.dart';
import '../../app/brand.dart';
import '../../app/theme.dart';
import '../../core/analytics.dart';
import '../onboarding/focus_questions.dart';
import '../../core/subscription_service.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../core/credit_service.dart';
import 'out_of_credits.dart';
import '../../app/i18n.dart';

/// Paywall. Prices, periods and the trial come from the store through
/// RevenueCat (localised); nothing is hardcoded. Shows price, billing period,
/// auto-renew terms, Restore Purchases and Privacy/Terms links next to the
/// buy button, as the store guidelines require (verify current rules in
/// docs/step1-plan.md).
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, this.reason = PaywallReason.general});

  /// What the user was doing, so the page can say why it opened.
  final PaywallReason reason;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<PlanOption>? _plans;
  String? _loadError;
  String? _selected;
  bool _busy = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    logEvent('paywall_view', {'reason': widget.reason.name});
    _load();
  }

  Future<void> _load() async {
    final state = AppScope.of(context);
    final service = state.subscriptions;
    try {
      var plans = await service.plans();
      // Tester builds before the store products exist: show the planned
      // plans so the page can be reviewed. Buying stays off.
      if (plans.isEmpty && testerMode) plans = previewPlans;
      // A friend's code on Android: the annual plan with the referral offer
      // replaces the normal annual plan.
      final tag = state.referralOffer?.playOfferTag;
      if (tag != null) {
        final friend = await service.referralPlan(tag);
        if (friend != null) {
          plans = [friend, ...plans.where((p) => p.title != 'Annual')];
        }
      }
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _selected = plans.isEmpty ? null : plans.first.id;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plans = [];
        _loadError = tr(
          'Could not load subscription options. Please try again.',
        );
      });
    }
  }

  Future<void> _buy(PlanOption plan) async {
    logEvent('paywall_buy_tap', {
      'product': plan.productId ?? plan.id,
      'reason': widget.reason.name,
    });
    final state = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final premium = await state.subscriptions.purchase(plan);
      if (!mounted) return;
      if (premium) {
        state.setPremium(true);
        context.pushReplacement(
          '/welcome-premium',
          extra: (plan: tr(plan.title), restored: false),
        );
      }
    } on SubscriptionException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final state = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final premium = await state.subscriptions.restore();
      if (!mounted) return;
      if (premium) {
        state.setPremium(true);
        context.pushReplacement(
          '/welcome-premium',
          extra: (plan: null, restored: true),
        );
      } else {
        _toast(tr('No active subscription found for this account.'));
      }
    } on SubscriptionException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _manage() async {
    final url = Uri.parse(await AppScope.of(context).subscriptions.manageUrl());
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _toast(tr('Open Settings > Subscriptions on your device.'));
    }
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final plans = _plans;
    final plan = (plans == null || _selected == null)
        ? null
        : plans.firstWhere((p) => p.id == _selected);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: tr('Close'),
          icon: Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          // Kept small so the plans and their prices show without scrolling.
          Center(child: CardFan(cardWidth: 48)),
          SizedBox(height: 16),
          if (_reasonLine(widget.reason, AppScope.of(context).focusArea)
              case final line?)
            Text(
              line,
              style: TextStyle(color: AppColors.gold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          Text(
            tr('Unlock Premium'),
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          for (final f in [
            tr('Every spread, including the 13-card Year Ahead'),
            if (creditsEnabled)
              tr('All readings and follow-ups included, up to 50 a day'),
            tr('Listen to your readings and save them as PDF'),
            tr('Home screen widgets and four new card backs'),
            tr('A clarifier card, a look back and a monthly letter'),
          ])
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check, color: AppColors.gold, size: 18),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
          SizedBox(height: 16),
          if (AppScope.of(context).referralOffer?.appleOfferCode
              case final code?)
            _AppleFriendOffer(code),
          if (plans != null && plans.any((p) => p.id.startsWith('preview-')))
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                tr(
                  tr(
                    'Preview: planned prices. Buying turns on after the store setup.',
                  ),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gold, fontSize: 12),
              ),
            ),
          if (plans == null)
            Center(child: CircularProgressIndicator())
          else if (plans.isEmpty)
            Text(
              _loadError ?? tr('Subscriptions are not available yet.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            )
          else
            RadioGroup<String>(
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v ?? _selected),
              child: Column(
                children: [
                  for (final p in plans)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        side: BorderSide(
                          color: p.id == _selected
                              ? AppColors.gold
                              : AppColors.hairline,
                          width: p.id == _selected ? 1.5 : 1,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: p.id,
                        // The billed price stays in the title row, the most
                        // prominent text on the tile (Apple 3.1.2(c)).
                        // Name (and badge) over the billed price, the same
                        // on every tile and in every language.
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  tr(p.title),
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (p.title == 'Annual' &&
                                    annualSaving(plans) != null)
                                  _Badge(tr('Best value')),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${p.priceString} ${p.periodLabel}',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        subtitle: _planDetails(p, plans),
                      ),
                    ),
                ],
              ),
            ),
          if (plan != null && plan.trialLabel != null) _Timeline(plan: plan),
          SizedBox(height: 8),
          FilledButton(
            onPressed: (plan == null || _busy || plan.id.startsWith('preview-'))
                ? null
                : () => _buy(plan),
            child: Text(
              plan?.trialLabel != null
                  ? plan!.trialIsFree
                        ? tr('Start {0} free trial', [
                            plan.trialDuration ??
                                plan.trialLabel!.replaceAll(' free', ''),
                          ])
                        : tr('Start for {0}', [
                            plan.trialPrice ??
                                plan.trialLabel!.split(' for ').first,
                          ])
                  : plan?.title == 'Lifetime'
                  ? tr('Buy lifetime')
                  : tr('Subscribe'),
            ),
          ),
          SizedBox(height: 12),
          if (plan != null)
            Text(
              plan.trialLabel != null
                  ? (plan.trialIsFree
                        ? tr(
                            '{0}, then {1} {2}. Cancel any time at least 24 hours before the trial ends.',
                            [
                              plan.trialLabel,
                              plan.priceString,
                              plan.periodLabel,
                            ],
                          )
                        : tr(
                            '{0}, then {1} {2}. Cancel any time at least 24 hours before the first period ends.',
                            [
                              plan.trialLabel,
                              plan.priceString,
                              plan.periodLabel,
                            ],
                          ))
                  : '${plan.priceString} ${plan.periodLabel}.',
              textAlign: TextAlign.center,
              // Same weight as the button: what you pay after the offer.
              style: TextStyle(fontSize: 14),
            ),
          if (plan != null) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: AppColors.gold,
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    plan.trialLabel != null
                        ? tr(
                            'No surprise charges: cancel anytime, and we can remind you 2 days before it ends.',
                          )
                        : plan.title == 'Lifetime'
                        ? tr('Pay once, keep Premium for good.')
                        : tr('No surprise charges: cancel anytime.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 4),
          Text(
            plan?.title == 'Lifetime'
                ? tr(
                    'One-time payment, charged at confirmation of purchase. Nothing renews and there is no subscription to cancel.',
                  )
                : Platform.isIOS
                ? tr(
                    'Payment is charged to your Apple ID account. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your App Store account settings.',
                  )
                : tr(
                    'Payment is charged to your Google Play account. The subscription renews automatically unless cancelled before the end of the current period. Manage or cancel in Google Play > Payments & subscriptions.',
                  ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: _busy ? null : _restore,
                child: Text(tr('Restore Purchases')),
              ),
              TextButton(
                onPressed: _manage,
                child: Text(tr('Manage subscription')),
              ),
              if (AppScope.of(context).guestCouldSignIn)
                TextButton(
                  onPressed: () => context.push('/account'),
                  child: Text(tr('Sign in for 2 free credits a day')),
                ),
              TextButton(
                onPressed: () => context.push('/legal/privacy'),
                child: Text(tr('Privacy Policy')),
              ),
              TextButton(
                onPressed: () => context.push('/legal/terms'),
                child: Text(tr('Terms of Use')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// How much the annual plan saves against paying monthly for a year, in whole
/// percent, from the store's own prices (so it is right in every currency).
/// Null when either price is missing or there is no saving.
int? annualSaving(List<PlanOption> plans) =>
    _saving(plans, 'Weekly', 52) ?? _saving(plans, 'Monthly', 12);

/// "vs weekly" when a weekly plan is offered, else "vs monthly".
String annualSavingLabel(List<PlanOption> plans, int pct) =>
    _saving(plans, 'Weekly', 52) != null
    ? tr('save {0}% vs weekly', [pct])
    : tr('save {0}% vs monthly', [pct]);

int? _saving(List<PlanOption> plans, String other, int perYear) {
  final annual = plans.where((p) => p.title == 'Annual').firstOrNull?.price;
  final o = plans.where((p) => p.title == other).firstOrNull?.price;
  if (annual == null || o == null || o <= 0) return null;
  final pct = ((1 - annual / (o * perYear)) * 100).floor();
  return pct > 0 ? pct : null;
}

/// Trial, per-month equivalent and saving under the billed price. The billed
/// price stays in the title, the most prominent line (Apple 3.1.2(c)).
Widget? _planDetails(PlanOption p, List<PlanOption> plans) {
  final parts = <String>[
    if (p.trialLabel != null) p.trialLabel!,
    if (p.title != 'Monthly' && p.perMonthString != null)
      p.title == 'Annual'
          ? tr('just {0}/month', [p.perMonthString])
          : tr('{0}/month', [p.perMonthString]),
    if (p.title == 'Annual' && annualSaving(plans) != null)
      annualSavingLabel(plans, annualSaving(plans)!),
  ];
  return parts.isEmpty ? null : Text(parts.join(' · '));
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.gold,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.onGold,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// iOS: the friend's 50%-off first year comes as a one-time App Store offer
/// code, redeemed in Apple's own sheet.
class _AppleFriendOffer extends StatelessWidget {
  const _AppleFriendOffer(this.code);
  final String code;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Friend\'s offer: 50% off your first year'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 6),
          SelectableText(tr('Your App Store code: {0}', [code])),
          SizedBox(height: 4),
          Text(
            tr(
              tr(
                'Copy the code, then redeem it in the App Store sheet. The price and renewal terms are shown there before you confirm.',
              ),
            ),
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          SizedBox(height: 8),
          OverflowBar(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                child: Text(tr('Copy code')),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: Size(0, 44)),
                onPressed: () =>
                    AppScope.of(context).subscriptions.redeemOfferCode(),
                child: Text(tr('Redeem in App Store')),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Planned plans, shown only in tester builds while the stores have no
/// products. Real prices always come from the store.
final previewPlans = [
  PlanOption(
    id: 'preview-annual',
    title: 'Annual',
    priceString: '\$39.99',
    periodLabel: 'per year',
    trialLabel: '3 days free',
    price: 39.99,
    perMonthString: '\$3.33',
  ),
  PlanOption(
    id: 'preview-lifetime',
    title: 'Lifetime',
    priceString: '\$99.99',
    periodLabel: 'one time',
    price: 99.99,
  ),
  PlanOption(
    id: 'preview-monthly',
    title: 'Monthly',
    priceString: '\$9.99',
    periodLabel: 'per month',
    price: 9.99,
  ),
  PlanOption(
    id: 'preview-weekly',
    title: 'Weekly',
    priceString: '\$3.99',
    periodLabel: 'per week',
    price: 3.99,
  ),
];

String? _reasonLine(PaywallReason r, String? area) => switch (r) {
  PaywallReason.firstReading => switch (focusAreaTopic(area)) {
    final topic? => tr('Keep exploring your question about {0}', [topic]),
    null => tr('Keep exploring what is on your mind'),
  },
  PaywallReason.general => null,
  PaywallReason.outOfCredits => tr('Keep reading: every reading included'),
  PaywallReason.lockedSpread => tr('This spread is part of Premium'),
  PaywallReason.followUp => tr('Keep the conversation going'),
  PaywallReason.recap => tr('See your whole month'),
};

/// The price of one reading in a credit pack, written like the store price
/// ("\$1.99" -> "\$0.20"). Null when the price or credit count is unknown.
String? perReading(PlanOption pack) {
  final price = pack.price;
  final credits = creditsInPack(pack.productId ?? '');
  if (price == null || credits <= 0) return null;
  final m = RegExp(r'[0-9][0-9.,\s]*[0-9]|[0-9]').firstMatch(pack.priceString);
  if (m == null) return null;
  final comma = RegExp(r',[0-9]{2}$').hasMatch(m.group(0)!);
  var each = (price / credits).toStringAsFixed(2);
  if (comma) each = each.replaceAll('.', ',');
  return pack.priceString.replaceRange(m.start, m.end, each);
}

/// What happens with an introductory offer, step by step: today, the reminder,
/// and the full price after. Plain and visible before the buy button.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.plan});
  final PlanOption plan;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        tr('Today'),
        plan.trialIsFree
            ? tr('Free, with everything in Premium')
            : tr('{0}, with everything in Premium', [
                plan.trialPrice ?? plan.trialLabel!,
              ]),
      ),
      (tr('2 days before it ends'), tr('We send you a reminder')),
      (
        tr('After {0}', [plan.trialDuration ?? plan.trialLabel!]),
        tr('{0} {1}, unless you cancel', [plan.priceString, plan.periodLabel]),
      ),
    ];
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        children: [
          for (final (i, (at, what)) in steps.indexed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0 ? AppColors.gold : Colors.transparent,
                        border: Border.all(color: AppColors.gold),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 1,
                        height: 26,
                        color: AppColors.goldDeep,
                      ),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$at  ',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: what),
                      ],
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
