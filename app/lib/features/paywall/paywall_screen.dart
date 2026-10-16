import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/brand.dart';
import '../../app/theme.dart';
import '../../core/subscription_service.dart';

/// Paywall. Prices, periods and the trial come from the store through
/// RevenueCat (localised); nothing is hardcoded. Shows price, billing period,
/// auto-renew terms, Restore Purchases and Privacy/Terms links next to the
/// buy button, as the store guidelines require (verify current rules in
/// docs/step1-plan.md).
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

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
    _load();
  }

  Future<void> _load() async {
    final service = AppScope.of(context).subscriptions;
    try {
      final plans = await service.plans();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _selected = plans.isEmpty ? null : plans.first.id;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plans = const [];
        _loadError = 'Could not load subscription options. Please try again.';
      });
    }
  }

  Future<void> _buy(PlanOption plan) async {
    final state = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final premium = await state.subscriptions.purchase(plan);
      if (!mounted) return;
      if (premium) {
        context.pop();
        state.setPremium(true);
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
        context.pop();
        state.setPremium(true);
      } else {
        _toast('No active subscription found for this account.');
      }
    } on SubscriptionException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
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
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: CardFan(cardWidth: 64)),
          const SizedBox(height: 4),
          const Center(child: BrandWordmark(size: 13)),
          const SizedBox(height: 12),
          Text(
            'Unlock Premium',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          for (final f in const [
            'Unlimited AI readings (free: 1 a day)',
            'Follow-up questions on your readings',
            'A clarifier card to shed light on a reading',
            'A look back a week later, with a reminder',
            'Helps keep ShenTarot running',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.gold,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (plans == null)
            const Center(child: CircularProgressIndicator())
          else if (plans.isEmpty)
            Text(
              _loadError ?? 'Subscriptions are not available yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
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
                                '${p.title} · ${p.priceString} ${p.periodLabel}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (p.title == 'Annual' &&
                                annualSaving(plans) != null)
                              const _Badge('Best value'),
                          ],
                        ),
                        subtitle: _planDetails(p, plans),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: (plan == null || _busy) ? null : () => _buy(plan),
            child: Text(
              plan?.trialLabel != null
                  ? 'Start ${plan!.trialLabel!.replaceAll(' free', '')} free trial'
                  : 'Subscribe',
            ),
          ),
          const SizedBox(height: 12),
          if (plan != null)
            Text(
              plan.trialLabel != null
                  ? '${plan.trialLabel}, then ${plan.priceString} ${plan.periodLabel}. '
                        'Cancel any time at least 24 hours before the trial ends.'
                  : '${plan.priceString} ${plan.periodLabel}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          const SizedBox(height: 4),
          Text(
            Platform.isIOS
                ? 'Payment is charged to your Apple ID account. The '
                      'subscription renews automatically unless cancelled at '
                      'least 24 hours before the end of the current period. '
                      'Manage or cancel in your App Store account settings.'
                : 'Payment is charged to your Google Play account. The '
                      'subscription renews automatically unless cancelled '
                      'before the end of the current period. Manage or cancel '
                      'in Google Play > Payments & subscriptions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: _busy ? null : _restore,
                child: const Text('Restore Purchases'),
              ),
              TextButton(
                onPressed: () => context.push('/legal/privacy'),
                child: const Text('Privacy Policy'),
              ),
              TextButton(
                onPressed: () => context.push('/legal/terms'),
                child: const Text('Terms of Use'),
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
      '${p.title == 'Annual' ? 'just ' : ''}${p.perMonthString}/month',
    if (p.title == 'Annual' && annualSaving(plans) != null)
      'save ${annualSaving(plans)}% vs monthly',
  ];
  return parts.isEmpty ? null : Text(parts.join(' · '));
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.gold,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.onGold,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
