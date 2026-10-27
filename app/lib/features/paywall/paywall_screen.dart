import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/flags.dart';
import '../../app/brand.dart';
import '../../app/theme.dart';
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
  List<PlanOption> _packs = [];
  String? _loadError;
  String? _selected;
  bool _busy = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
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
      final packs = creditsEnabled
          ? await service.creditPacks()
          : <PlanOption>[];
      if (!mounted) return;
      setState(() {
        _packs = packs;
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

  Future<void> _buyPack(PlanOption pack) async {
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await state.subscriptions.purchase(pack);
      // The server adds the credits when the store confirms; check twice.
      for (var i = 0; i < 2; i++) {
        await Future<void>.delayed(Duration(seconds: 2));
        await state.refreshCredits();
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(tr('You have {0} reading credits.', [state.credits])),
        ),
      );
    } on SubscriptionException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _buy(PlanOption plan) async {
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
          Center(child: CardFan(cardWidth: 64)),
          SizedBox(height: 4),
          Center(child: BrandWordmark(size: 13)),
          SizedBox(height: 12),
          if (_reasonLine(widget.reason) case final line?)
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
          SizedBox(height: 16),
          for (final f in [
            tr('Every spread, including the 10-card Celtic Cross'),
            if (creditsEnabled)
              tr(
                '90 to 150 new credits every month by plan (free: 1 a day, 2 when signed in), and unused credits roll over',
              ),
            tr('A clarifier card to shed light on a reading'),
            tr('A look back a week later, with a reminder'),
            tr('Helps keep ShenTarot running'),
          ])
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.gold, size: 20),
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
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: p.id == _selected
                              ? AppColors.gold
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: p.id,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${tr(p.title)} · ${p.priceString} ${p.periodLabel}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (p.title == 'Annual' &&
                                annualSaving(plans) != null)
                              _Badge(tr('Best value')),
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
                        : tr('No surprise charges: cancel anytime.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.gold),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 4),
          Text(
            Platform.isIOS
                ? tr(
                    'Payment is charged to your Apple ID account. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your App Store account settings.',
                  )
                : tr(
                    'Payment is charged to your Google Play account. The subscription renews automatically unless cancelled before the end of the current period. Manage or cancel in Google Play > Payments & subscriptions.',
                  ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          // One-time packs after the subscription and its terms, so the
          // timeline and price above read as one offer.
          if (creditsEnabled && plans != null)
            // With no store products yet the card is a preview: shown, not buyable.
            _CreditPacksCard(packs: _packs, busy: _busy, onBuy: _buyPack),
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
int? annualSaving(List<PlanOption> plans) {
  final annual = plans.where((p) => p.title == 'Annual').firstOrNull?.price;
  final monthly = plans.where((p) => p.title == 'Monthly').firstOrNull?.price;
  if (annual == null || monthly == null || monthly <= 0) return null;
  final pct = ((1 - annual / (monthly * 12)) * 100).floor();
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
      tr('save {0}% vs monthly', [annualSaving(plans)]),
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
      borderRadius: BorderRadius.circular(8),
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

/// One-time credit packs for people not ready to subscribe. They cost more
/// per credit than Premium's monthly credits on purpose, and the card says so.
class _CreditPacksCard extends StatelessWidget {
  const _CreditPacksCard({
    required this.packs,
    required this.busy,
    required this.onBuy,
  });

  /// Empty while the store products do not exist yet (preview).
  final List<PlanOption> packs;
  final bool busy;
  final void Function(PlanOption) onBuy;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.only(top: 16),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Not ready to subscribe?'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 4),
          Text(
            tr(
              tr(
                'Buy a few credits once, no subscription. 1 credit = 1 reading or follow-up, and credits never expire.',
              ),
            ),
          ),
          SizedBox(height: 8),
          if (packs.isEmpty)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton(
                onPressed: null,
                child: Text(tr('Coming soon')),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                for (final pack in packs)
                  OutlinedButton(
                    onPressed: busy ? null : () => onBuy(pack),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          Text('${pack.title} · ${pack.priceString}'),
                          if (perReading(pack) case final each?)
                            Text(
                              tr('about {0} a reading', [each]),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
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
    trialLabel: '\$1.99 for your first month',
    trialIsFree: false,
    price: 39.99,
    perMonthString: '\$3.33',
  ),
  PlanOption(
    id: 'preview-quarterly',
    title: '3 Months',
    priceString: '\$14.99',
    periodLabel: 'every 3 months',
    price: 14.99,
    perMonthString: '\$5.00',
  ),
  PlanOption(
    id: 'preview-monthly',
    title: 'Monthly',
    priceString: '\$6.99',
    periodLabel: 'per month',
    price: 6.99,
  ),
];

String? _reasonLine(PaywallReason r) => switch (r) {
  PaywallReason.general => null,
  PaywallReason.outOfCredits => tr('Keep reading: more credits, your way'),
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
