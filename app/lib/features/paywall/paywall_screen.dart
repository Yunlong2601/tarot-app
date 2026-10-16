import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';

class _Plan {
  const _Plan(this.id, this.title, this.price, this.period, {this.note});
  final String id;
  final String title;
  final String price;
  final String period;
  final String? note;
}

/// Phase A mock paywall. Phase E loads real products from RevenueCat and
/// shows the store-localised price. Never hardcode prices in production.
const _plans = [
  _Plan('annual', 'Annual', r'$39.99', 'per year',
      note: '7-day free trial · best value'),
  _Plan('monthly', 'Monthly', r'$7.99', 'per month'),
  _Plan('weekly', 'Weekly', r'$3.99', 'per week'),
];

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selected = 'annual';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final plan = _plans.firstWhere((p) => p.id == _selected);
    final trial = plan.id == 'annual';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Unlock Premium',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          for (final f in const [
            'Three-card and Celtic Cross spreads',
            'Unlimited readings',
            'Follow-up questions',
            'Reading history and journal',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(f)),
              ]),
            ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _selected,
            onChanged: (v) => setState(() => _selected = v ?? _selected),
            child: Column(children: [
              for (final p in _plans)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                        color: p.id == _selected
                            ? AppColors.gold
                            : Colors.transparent,
                        width: 2),
                  ),
                  child: RadioListTile<String>(
                    value: p.id,
                    title: Text('${p.title} · ${p.price} ${p.period}'),
                    subtitle: p.note == null ? null : Text(p.note!),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              // Mock purchase. Phase E calls RevenueCat here.
              state.setPremium(true);
              context.pop();
            },
            child: Text(trial ? 'Start 7-day free trial' : 'Subscribe'),
          ),
          const SizedBox(height: 12),
          Text(
            trial
                ? '7 days free, then ${plan.price} ${plan.period}. '
                    'Cancel any time at least 24 hours before the trial ends.'
                : '${plan.price} ${plan.period}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          const Text(
            'Payment is charged to your Apple ID or Google Play account. '
            'The subscription renews automatically unless cancelled at least '
            '24 hours before the end of the current period. Manage or cancel '
            'in your account settings in the App Store or Google Play.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          Wrap(alignment: WrapAlignment.center, children: [
            TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restore arrives in Phase E'))),
                child: const Text('Restore Purchases')),
            TextButton(
                onPressed: () => context.push('/legal/privacy'),
                child: const Text('Privacy Policy')),
            TextButton(
                onPressed: () => context.push('/legal/terms'),
                child: const Text('Terms of Use')),
          ]),
        ],
      ),
    );
  }
}
