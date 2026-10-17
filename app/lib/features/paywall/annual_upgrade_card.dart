import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/subscription_service.dart';
import '../../app/i18n.dart';

/// For monthly or 3-month subscribers after a few months: plain maths on switching to
/// annual, with store prices only. Shown on the Read tab (never during a
/// reading), dismissible, at most twice (see AppState.annualUpgradeMonths).
class AnnualUpgradeCard extends StatefulWidget {
  const AnnualUpgradeCard({super.key});

  @override
  State<AnnualUpgradeCard> createState() => _AnnualUpgradeCardState();
}

class _AnnualUpgradeCardState extends State<AnnualUpgradeCard> {
  int? _months;
  PlanOption? _current;
  PlanOption? _annual;
  bool _hidden = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_months == null && !_hidden) _load();
  }

  Future<void> _load() async {
    final state = AppScope.of(context);
    try {
      final months = await state.annualUpgradeMonths();
      if (months == null) return;
      final plans = await state.subscriptions.plans();
      final annual = plans.where((p) => p.title == 'Annual').firstOrNull;
      final currentId = await state.subscriptions.currentProductId();
      final current = plans
          .where((p) => p.productId != null && p.productId == currentId)
          .firstOrNull;
      if (annual == null || current == null || !mounted) return;
      setState(() {
        _months = months;
        _annual = annual;
        _current = current;
      });
    } catch (_) {
      // Nothing to show if the store is unreachable.
    }
  }

  Future<void> _dismiss() async {
    setState(() => _hidden = true);
    await AppScope.of(context).dismissAnnualUpgrade();
  }

  Future<void> _switch() async {
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      if (await state.subscriptions.switchTo(_annual!)) {
        await state.dismissAnnualUpgrade();
        if (mounted) setState(() => _hidden = true);
        messenger.showSnackBar(
          SnackBar(content: Text(tr('You are on the annual plan now.'))),
        );
      }
    } on SubscriptionException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = _months;
    if (_hidden || months == null) return const SizedBox.shrink();
    final a = _annual!;
    final m = _current!;
    final perMonth = a.perMonthString == null
        ? ''
        : tr(' (about {0} a month)', [a.perMonthString]);
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(top: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Thank you for {0} months of Premium', [months]),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                tr('You pay {0} {1}. The annual plan is {2} a year{3}.', [
                  m.priceString,
                  m.periodLabel,
                  a.priceString,
                  perMonth,
                ]),
              ),
              const SizedBox(height: 4),
              Text(
                tr(
                  tr(
                    tr(
                      'Switching is optional. The store shows the exact change before you confirm.',
                    ),
                  ),
                ),
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: _busy ? null : _dismiss,
                    child: Text(tr('Not now')),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: _busy ? null : _switch,
                    child: Text(tr('Switch to annual')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
