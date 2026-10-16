import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// One purchasable plan, with the store-localised price. Never hardcode prices.
class PlanOption {
  const PlanOption({
    required this.id,
    required this.title,
    required this.priceString,
    required this.periodLabel,
    this.trialLabel,
    this.trialIsFree = true,
    this.handle,
    this.price,
    this.perMonthString,
    this.productId,
  });

  final String id;
  final String title;
  final String priceString;

  /// For example "per year".
  final String periodLabel;

  /// For example "7 days free". Null when the plan has no free trial.
  final String? trialLabel;

  /// False when the introductory offer is paid (e.g. "7 days for $1.98").
  final bool trialIsFree;

  /// Opaque store object used by the service when purchasing.
  final Object? handle;

  /// Numeric store price in the user's currency (for honest comparisons).
  final double? price;

  /// Store-formatted price per month, e.g. "$3.33" for an annual plan.
  final String? perMonthString;

  /// Store product id (Play ids may carry ":baseplan"; compare the part before).
  final String? productId;
}

class SubscriptionException implements Exception {
  const SubscriptionException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class SubscriptionService {
  /// False when no store/RevenueCat key was provided at build time.
  bool get isConfigured;

  /// Starts the SDK with the anonymous install ID and reports entitlement
  /// changes ("premium") through [onPremiumChanged].
  Future<void> start(
    String appUserId,
    void Function(bool premium) onPremiumChanged,
  );

  Future<List<PlanOption>> plans();

  /// Returns true if the user now has Premium. A cancelled purchase returns false.
  Future<bool> purchase(PlanOption plan);

  Future<bool> restore();

  /// The store page where the user can manage or cancel.
  Future<String> manageUrl();

  /// Switches the RevenueCat app user (account id when signed in, install id
  /// when not), so Premium follows the account.
  Future<void> switchUser(String appUserId);

  /// Months of Premium so far when the active plan is shorter than a year
  /// (monthly, 3-month), else null. (Name kept from the monthly-only version.)
  Future<int?> monthlyMonthsPaid();

  /// Store product id of the active plan (without any ":baseplan"), or null.
  Future<String?> currentProductId();

  /// Moves an active monthly subscriber to [plan] (the store handles the
  /// change; on Google Play the old product is replaced).
  Future<bool> switchTo(PlanOption plan);
}

/// Months paid on a monthly plan, from the first and latest purchase dates.
int monthsPaidBetween(DateTime first, DateTime latest) =>
    1 + (latest.difference(first).inDays / 30.4).round();

/// Used when `REVENUECAT_IOS_KEY` / `REVENUECAT_ANDROID_KEY` were not given
/// via `--dart-define`. No purchases are possible; nothing is faked.
class UnconfiguredSubscriptionService implements SubscriptionService {
  const UnconfiguredSubscriptionService();

  static const _msg = 'Subscriptions are not available yet.';

  @override
  bool get isConfigured => false;

  @override
  Future<void> start(
    String appUserId,
    void Function(bool) onPremiumChanged,
  ) async {}

  @override
  Future<List<PlanOption>> plans() async => const [];

  @override
  Future<bool> purchase(PlanOption plan) =>
      throw const SubscriptionException(_msg);

  @override
  Future<bool> restore() => throw const SubscriptionException(_msg);

  @override
  Future<String> manageUrl() async => _storeSubscriptionsUrl();

  @override
  Future<void> switchUser(String appUserId) async {}

  @override
  Future<int?> monthlyMonthsPaid() async => null;

  @override
  Future<String?> currentProductId() async => null;

  @override
  Future<bool> switchTo(PlanOption plan) =>
      throw const SubscriptionException(_msg);
}

String _storeSubscriptionsUrl() => Platform.isIOS
    ? 'https://apps.apple.com/account/subscriptions'
    : 'https://play.google.com/store/account/subscriptions';

const premiumEntitlement = 'premium';

class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService(this.apiKey);

  final String apiKey;
  bool _started = false;

  @override
  bool get isConfigured => true;

  bool _isPremium(CustomerInfo info) =>
      info.entitlements.active.containsKey(premiumEntitlement);

  @override
  Future<void> start(
    String appUserId,
    void Function(bool) onPremiumChanged,
  ) async {
    if (_started) return;
    final config = PurchasesConfiguration(apiKey)..appUserID = appUserId;
    await Purchases.configure(config);
    _started = true;
    Purchases.addCustomerInfoUpdateListener(
      (info) => onPremiumChanged(_isPremium(info)),
    );
    onPremiumChanged(_isPremium(await Purchases.getCustomerInfo()));
  }

  String? _monthlyProductId;

  @override
  Future<int?> monthlyMonthsPaid() async {
    if (!_started) return null;
    final ent = (await Purchases.getCustomerInfo())
        .entitlements
        .active[premiumEntitlement];
    if (ent == null || ent.productIdentifier.contains('annual')) return null;
    if (ent.periodType != PeriodType.normal) return null;
    _monthlyProductId = ent.productIdentifier;
    final first = DateTime.tryParse(ent.originalPurchaseDate);
    final latest = DateTime.tryParse(ent.latestPurchaseDate);
    if (first == null || latest == null) return null;
    return monthsPaidBetween(first, latest);
  }

  @override
  Future<String?> currentProductId() async {
    if (!_started) return null;
    final ent = (await Purchases.getCustomerInfo())
        .entitlements
        .active[premiumEntitlement];
    return ent?.productIdentifier.split(':').first;
  }

  @override
  Future<bool> switchTo(PlanOption plan) async {
    final pkg = plan.handle;
    if (pkg is! Package) throw const SubscriptionException('Unknown plan.');
    final old = _monthlyProductId;
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(
          pkg,
          productChangeInfo: Platform.isAndroid && old != null
              ? StoreProductChangeInfo(old.split(':').first)
              : null,
        ),
      );
      return _isPremium(result.customerInfo);
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      throw const SubscriptionException(
        'The change could not be completed. You were not charged.',
      );
    }
  }

  @override
  Future<void> switchUser(String appUserId) async {
    if (!_started) return;
    await Purchases.logIn(appUserId);
  }

  @override
  Future<List<PlanOption>> plans() async {
    final packages =
        (await Purchases.getOfferings()).current?.availablePackages ?? const [];
    // Annual first (best value), then 3 months, then monthly. Weekly is not
    // offered (owner decision 2026-10-17); a weekly package is ignored.
    const order = [
      PackageType.annual,
      PackageType.threeMonth,
      PackageType.monthly,
    ];
    final known = [
      for (final t in order) ...packages.where((p) => p.packageType == t),
    ];
    return [for (final p in known) _toPlan(p)];
  }

  PlanOption _toPlan(Package p) {
    final (title, period) = switch (p.packageType) {
      PackageType.annual => ('Annual', 'per year'),
      PackageType.threeMonth => ('3 Months', 'every 3 months'),
      PackageType.monthly => ('Monthly', 'per month'),
      PackageType.weekly => ('Weekly', 'per week'),
      _ => (p.storeProduct.title, ''),
    };
    final intro = p.storeProduct.introductoryPrice;
    // The introductory offer as the store defines it: free ("7 days free")
    // or paid ("7 days for $1.98"). Nothing is hardcoded here.
    final n = intro == null ? 0 : intro.periodNumberOfUnits * intro.cycles;
    final trial = intro == null
        ? null
        : intro.price == 0
        ? '$n ${_unit(intro.periodUnit, n)} free'
        : '$n ${_unit(intro.periodUnit, n)} for ${intro.priceString}';
    return PlanOption(
      id: p.identifier,
      title: title,
      priceString: p.storeProduct.priceString,
      periodLabel: period,
      trialLabel: trial,
      trialIsFree: intro == null || intro.price == 0,
      handle: p,
      price: p.storeProduct.price,
      perMonthString: p.storeProduct.pricePerMonthString,
      productId: p.storeProduct.identifier.split(':').first,
    );
  }

  String _unit(PeriodUnit u, int n) {
    final base = switch (u) {
      PeriodUnit.day => 'day',
      PeriodUnit.week => 'week',
      PeriodUnit.month => 'month',
      PeriodUnit.year => 'year',
      _ => 'day',
    };
    return n == 1 ? base : '${base}s';
  }

  @override
  Future<bool> purchase(PlanOption plan) async {
    final pkg = plan.handle;
    if (pkg is! Package) throw const SubscriptionException('Unknown plan.');
    try {
      final result = await Purchases.purchase(PurchaseParams.package(pkg));
      return _isPremium(result.customerInfo);
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      throw const SubscriptionException(
        'The purchase could not be completed. You were not charged.',
      );
    }
  }

  @override
  Future<bool> restore() async {
    try {
      return _isPremium(await Purchases.restorePurchases());
    } on PlatformException {
      throw const SubscriptionException(
        'Could not restore purchases. Please try again.',
      );
    }
  }

  @override
  Future<String> manageUrl() async {
    try {
      return (await Purchases.getCustomerInfo()).managementURL ??
          _storeSubscriptionsUrl();
    } catch (_) {
      return _storeSubscriptionsUrl();
    }
  }
}
