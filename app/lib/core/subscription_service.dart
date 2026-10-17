import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'credit_service.dart';
import '../app/i18n.dart';

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
    this.trialDuration,
    this.trialPrice,
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

  /// Translated length of the introductory offer, e.g. "7 days".
  final String? trialDuration;

  /// Store-formatted price of a paid introductory offer, e.g. "$1.99".
  final String? trialPrice;
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

  /// When the active introductory period (free trial or paid first month)
  /// ends, or null if the user is not in one.
  Future<DateTime?> introEndsAt();

  /// Google Play: the annual plan with the friend's offer (tagged [offerTag]),
  /// or null if the store has no such offer for this user.
  Future<PlanOption?> referralPlan(String offerTag);

  /// iOS: Apple's sheet to redeem an offer code.
  Future<void> redeemOfferCode();

  /// Credit packs (consumables), smallest first; empty until the products exist.
  Future<List<PlanOption>> creditPacks();

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

  static String get _msg => tr('Subscriptions are not available yet.');

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
  Future<bool> purchase(PlanOption plan) => throw SubscriptionException(_msg);

  @override
  Future<bool> restore() => throw SubscriptionException(_msg);

  @override
  Future<String> manageUrl() async => _storeSubscriptionsUrl();

  @override
  Future<void> switchUser(String appUserId) async {}

  @override
  Future<int?> monthlyMonthsPaid() async => null;

  @override
  Future<String?> currentProductId() async => null;

  @override
  Future<DateTime?> introEndsAt() async => null;

  @override
  Future<PlanOption?> referralPlan(String offerTag) async => null;

  @override
  Future<void> redeemOfferCode() => throw SubscriptionException(_msg);

  @override
  Future<List<PlanOption>> creditPacks() async => const [];

  @override
  Future<bool> switchTo(PlanOption plan) => throw SubscriptionException(_msg);
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
  Future<PlanOption?> referralPlan(String offerTag) async {
    if (!_started || !Platform.isAndroid) return null;
    final pkg = (await Purchases.getOfferings()).current?.annual;
    final option = pkg?.storeProduct.subscriptionOptions
        ?.where((o) => o.tags.contains(offerTag))
        .firstOrNull;
    final intro = option?.introPhase;
    if (pkg == null || option == null || intro == null) return null;
    return PlanOption(
      id: 'annual-friend',
      title: 'Annual',
      priceString: pkg.storeProduct.priceString,
      periodLabel: 'per year',
      trialLabel: '${intro.price.formatted} for your first year',
      trialIsFree: false,
      handle: option,
      price: pkg.storeProduct.price,
      perMonthString: pkg.storeProduct.pricePerMonthString,
      productId: pkg.storeProduct.identifier.split(':').first,
    );
  }

  @override
  Future<List<PlanOption>> creditPacks() async {
    if (!_started) return const [];
    final products = await Purchases.getProducts(
      creditPackProductIds,
      productCategory: ProductCategory.nonSubscription,
    );
    final packs = [
      for (final p in products)
        PlanOption(
          id: 'pack-${creditsInPack(p.identifier)}',
          title: tr('{0} credits', [creditsInPack(p.identifier)]),
          priceString: p.priceString,
          periodLabel: 'one time',
          handle: p,
          price: p.price,
          productId: p.identifier,
        ),
    ];
    packs.sort(
      (a, b) =>
          creditsInPack(a.productId ?? '')
              .compareTo(creditsInPack(b.productId ?? '')),
    );
    return packs;
  }

  @override
  Future<void> redeemOfferCode() async {
    if (Platform.isIOS) await Purchases.presentCodeRedemptionSheet();
  }

  @override
  Future<DateTime?> introEndsAt() async {
    if (!_started) return null;
    final ent = (await Purchases.getCustomerInfo())
        .entitlements
        .active[premiumEntitlement];
    if (ent == null ||
        (ent.periodType != PeriodType.intro &&
            ent.periodType != PeriodType.trial)) {
      return null;
    }
    final end = ent.expirationDate;
    return end == null ? null : DateTime.tryParse(end);
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
    if (pkg is! Package) throw SubscriptionException(tr('Unknown plan.'));
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
      throw SubscriptionException(
        tr('The change could not be completed. You were not charged.'),
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
      PackageType.annual => ('Annual', tr('per year')),
      PackageType.threeMonth => ('3 Months', tr('every 3 months')),
      PackageType.monthly => ('Monthly', tr('per month')),
      PackageType.weekly => ('Weekly', tr('per week')),
      _ => (p.storeProduct.title, ''),
    };
    final intro = p.storeProduct.introductoryPrice;
    // The introductory offer as the store defines it: free ("7 days free")
    // or paid ("7 days for $1.98"). Nothing is hardcoded here.
    final n = intro == null ? 0 : intro.periodNumberOfUnits * intro.cycles;
    final duration = intro == null ? null : _duration(intro.periodUnit, n);
    final trial = intro == null
        ? null
        : intro.price == 0
        ? tr('{0} free', [duration])
        : (n == 1
              ? tr('{0} for your first {1}', [
                  intro.priceString,
                  _unitName(intro.periodUnit),
                ])
              : tr('{0} for your first {1}', [intro.priceString, duration]));
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
      trialDuration: duration,
      trialPrice: intro == null || intro.price == 0 ? null : intro.priceString,
    );
  }

  String _unitName(PeriodUnit u) => switch (u) {
    PeriodUnit.week => tr('week'),
    PeriodUnit.month => tr('month'),
    PeriodUnit.year => tr('year'),
    _ => tr('day'),
  };

  String _duration(PeriodUnit u, int n) => switch (u) {
    PeriodUnit.week => n == 1 ? tr('1 week') : tr('{0} weeks', [n]),
    PeriodUnit.month => n == 1 ? tr('1 month') : tr('{0} months', [n]),
    PeriodUnit.year => n == 1 ? tr('1 year') : tr('{0} years', [n]),
    _ => n == 1 ? tr('1 day') : tr('{0} days', [n]),
  };

  @override
  Future<bool> purchase(PlanOption plan) async {
    final handle = plan.handle;
    final params = switch (handle) {
      Package p => PurchaseParams.package(p),
      SubscriptionOption o => PurchaseParams.subscriptionOption(o),
      StoreProduct p => PurchaseParams.storeProduct(p),
      _ => throw SubscriptionException(tr('Unknown plan.')),
    };
    try {
      final result = await Purchases.purchase(params);
      return _isPremium(result.customerInfo);
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      throw SubscriptionException(
        tr('The purchase could not be completed. You were not charged.'),
      );
    }
  }

  @override
  Future<bool> restore() async {
    try {
      return _isPremium(await Purchases.restorePurchases());
    } on PlatformException {
      throw SubscriptionException(
        tr('Could not restore purchases. Please try again.'),
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
