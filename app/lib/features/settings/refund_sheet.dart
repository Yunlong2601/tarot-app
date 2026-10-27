import 'package:flutter/material.dart';

import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../core/analytics.dart';
import '../../core/credit_service.dart';
import '../../core/refund_service.dart';

/// A readable name for a store product id.
String purchaseLabel(String productId) {
  final credits = creditsInPack(productId);
  if (credits > 0) return tr('{0} credits', [credits]);
  if (productId.contains('annual')) return tr('Premium · yearly');
  if (productId.contains('quarter')) return tr('Premium · 3 months');
  if (productId.contains('month')) return tr('Premium · monthly');
  return productId;
}

/// Lists recent purchases and opens Apple's refund sheet for the one the
/// user picks. Apple decides; the copy never promises a refund.
Future<void> showRefundSheet(
  BuildContext context, [
  RefundService service = const RefundService(),
]) async {
  final messenger = ScaffoldMessenger.of(context);
  List<RecentPurchase> purchases;
  try {
    purchases = await service.recentPurchases();
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(tr('Could not load your purchases. Please try again.')),
      ),
    );
    return;
  }
  if (!context.mounted) return;
  if (purchases.isEmpty) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          tr('No purchases from the last 90 days on this Apple ID.'),
        ),
      ),
    );
    return;
  }
  final picked = await showModalBottomSheet<RecentPurchase>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Request a refund'),
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              tr(
                'Pick a purchase. Apple reviews every request and emails you their decision.',
              ),
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            for (final p in purchases)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.receipt_outlined,
                  color: AppColors.gold,
                ),
                title: Text(purchaseLabel(p.productId)),
                subtitle: Text(
                  MaterialLocalizations.of(ctx).formatMediumDate(p.date),
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(ctx, p),
              ),
          ],
        ),
      ),
    ),
  );
  if (picked == null) return;
  try {
    final sent = await service.request(picked.id);
    logEvent('refund_sheet', {'sent': sent});
    if (sent) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            tr('Sent to Apple. They will email you with their decision.'),
          ),
        ),
      );
    }
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          tr('Could not open the refund request. Please try again.'),
        ),
      ),
    );
  }
}
