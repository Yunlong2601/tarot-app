import 'dart:io';

import 'package:qonversion_flutter/qonversion_flutter.dart';

import 'credit_service.dart';

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
  /// False when no Qonversion project key was provided at build time.
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

  /// Switches the Qonversion identity (account id when signed in, install id
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

/// Used when `QONVERSION_PROJECT_KEY` was not given
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
  Future<DateTime?> introEndsAt() async => null;

  @override
  Future<PlanOption?> referralPlan(String offerTag) async => null;

  @override
  Future<void> redeemOfferCode() => throw const SubscriptionException(_msg);

  @override
  Future<List<PlanOption>> creditPacks() async => const [];

  @override
  Future<bool> switchTo(PlanOption plan) =>
      throw const SubscriptionException(_msg);
}

String _storeSubscriptionsUrl() => Platform.isIOS
    ? 'https://apps.apple.com/account/subscriptions'
    : 'https://play.google.com/store/account/subscriptions';

const premiumEntitlement = 'premium';

/// The Qonversion product ids. Create them in Qonversion with exactly these
/// ids (each linked to the App Store / Google Play product of the same id),
/// and an entitlement `premium` attached to all three.
const annualProductId = 'shentarot_annual';
const quarterlyProductId = 'shentarot_quarterly';
const monthlyProductId = 'shentarot_monthly';

/// A Google Play offer to buy with a product (the friend's referral offer).
class _ProductWithOffer {
  const _ProductWithOffer(this.product, this.offer);
  final QProduct product;
  final QProductOfferDetails offer;
}

class QonversionSubscriptionService implements SubscriptionService {
  QonversionSubscriptionService(this.projectKey);

  final String projectKey;
  bool _started = false;

  Qonversion get _q => Qonversion.getSharedInstance();

  @override
  bool get isConfigured => true;

  static QEntitlement? _premium(Map<String, QEntitlement>? ents) {
    final e = ents?[premiumEntitlement];
    return e != null && e.isActive ? e : null;
  }

  Future<QEntitlement?> _activePremium() async =>
      _premium(await _q.checkEntitlements());

  @override
  Future<void> start(
    String appUserId,
    void Function(bool) onPremiumChanged,
  ) async {
    if (_started) return;
    Qonversion.initialize(
      QonversionConfigBuilder(
        projectKey,
        QLaunchMode.subscriptionManagement,
      ).build(),
    );
    _started = true;
    // Our install / account id is the Qonversion identity; the backend asks
    // Qonversion about the same id.
    await _q.identify(appUserId);
    _q.updatedEntitlementsStream.listen(
      (ents) => onPremiumChanged(_premium(ents) != null),
    );
    onPremiumChanged(await _activePremium() != null);
  }

  String? _monthlyProductId;

  @override
  Future<int?> monthlyMonthsPaid() async {
    if (!_started) return null;
    final ent = await _activePremium();
    if (ent == null || ent.productId.contains('annual')) return null;
    _monthlyProductId = ent.productId;
    final first = ent.firstPurchaseDate ?? ent.startedDate;
    final latest = ent.lastPurchaseDate;
    if (first == null || latest == null) return null;
    return monthsPaidBetween(first, latest);
  }

  @override
  Future<PlanOption?> referralPlan(String offerTag) async {
    if (!_started || !Platform.isAndroid) return null;
    final product = (await _q.products())[annualProductId];
    final offer = product?.storeDetails?.subscriptionOfferDetails
        ?.where((o) => o.tags.contains(offerTag))
        .firstOrNull;
    final intro = offer?.introPhase;
    if (product == null || offer == null || intro == null) return null;
    return PlanOption(
      id: 'annual-friend',
      title: 'Annual',
      priceString: product.prettyPrice ?? '',
      periodLabel: 'per year',
      trialLabel: '${intro.price.formattedPrice} for your first year',
      trialIsFree: false,
      handle: _ProductWithOffer(product, offer),
      price: product.price,
      perMonthString: _perMonth(product, 12),
      productId: annualProductId,
    );
  }

  @override
  Future<List<PlanOption>> creditPacks() async {
    if (!_started) return const [];
    final products = await _q.products();
    final packs = [
      for (final id in creditPackProductIds)
        if (products[id] case final p? when p.prettyPrice != null)
          PlanOption(
            id: 'pack-${creditsInPack(id)}',
            title: '${creditsInPack(id)} credits',
            priceString: p.prettyPrice!,
            periodLabel: 'one time',
            handle: p,
            price: p.price,
            productId: id,
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
    if (Platform.isIOS) await _q.presentCodeRedemptionSheet();
  }

  @override
  Future<DateTime?> introEndsAt() async {
    if (!_started) return null;
    final ent = await _activePremium();
    final end = ent?.expirationDate;
    if (ent == null || end == null || ent.renewsCount > 0) return null;
    // A free trial, or the paid first month on the annual plan: the current
    // period is far shorter than a year.
    final start = ent.lastPurchaseDate ?? ent.startedDate;
    final shortAnnual =
        ent.productId.contains('annual') &&
        start != null &&
        end.difference(start).inDays < 300;
    return ent.trialStartDate != null || shortAnnual ? end : null;
  }

  @override
  Future<String?> currentProductId() async {
    if (!_started) return null;
    return (await _activePremium())?.productId.split(':').first;
  }

  @override
  Future<bool> switchTo(PlanOption plan) async {
    final product = plan.handle;
    if (product is! QProduct) {
      throw const SubscriptionException('Unknown plan.');
    }
    final oldId = _monthlyProductId;
    final old = Platform.isAndroid && oldId != null
        ? (await _q.products())[oldId.split(':').first]
        : null;
    return _buy(
      product,
      old == null ? null : QPurchaseOptionsBuilder().setOldProduct(old).build(),
      'The change could not be completed. You were not charged.',
    );
  }

  @override
  Future<void> switchUser(String appUserId) async {
    if (!_started) return;
    await _q.identify(appUserId);
  }

  @override
  Future<List<PlanOption>> plans() async {
    final products = await _q.products();
    // Annual first (best value), then 3 months, then monthly. Weekly is not
    // offered (owner decision 2026-10-17).
    const order = [
      (annualProductId, 'Annual', 'per year', 12),
      (quarterlyProductId, '3 Months', 'every 3 months', 3),
      (monthlyProductId, 'Monthly', 'per month', 1),
    ];
    return [
      for (final (id, title, period, months) in order)
        if (products[id] case final p? when p.prettyPrice != null)
          _toPlan(p, id, title, period, months),
    ];
  }

  PlanOption _toPlan(
    QProduct p,
    String id,
    String title,
    String period,
    int months,
  ) {
    final (trial, free) = _introLabel(p);
    return PlanOption(
      id: id,
      title: title,
      priceString: p.prettyPrice!,
      periodLabel: period,
      trialLabel: trial,
      trialIsFree: free,
      handle: p,
      price: p.price,
      perMonthString: months == 1 ? null : _perMonth(p, months),
      productId: id,
    );
  }

  /// The introductory offer as the store defines it: free ("7 days free") or
  /// paid ("$1.99 for your first month"). Nothing is hardcoded here.
  (String?, bool) _introLabel(QProduct p) {
    final ios = p.skProduct?.introductoryPrice;
    if (ios != null) {
      final sp = ios.subscriptionPeriod;
      if (sp == null) return (null, true);
      final n = sp.numberOfUnits * ios.numberOfPeriods;
      final unit = switch (sp.unit) {
        SKSubscriptionPeriodUnit.day => 'day',
        SKSubscriptionPeriodUnit.week => 'week',
        SKSubscriptionPeriodUnit.month => 'month',
        SKSubscriptionPeriodUnit.year => 'year',
      };
      if (ios.paymentMode == SKProductDiscountPaymentMode.freeTrial) {
        return ('$n ${_plural(unit, n)} free', true);
      }
      final price = p.prettyIntroductoryPrice;
      return price == null
          ? (null, true)
          : ('$price ${_forFirst(unit, n)}', false);
    }
    final offer = p.storeDetails?.defaultSubscriptionOfferDetails;
    final phase = offer?.trialPhase ?? offer?.introPhase;
    if (phase == null) return (null, true);
    final n = phase.billingPeriod.unitCount * phase.billingCycleCount;
    final unit = switch (phase.billingPeriod.unit) {
      QSubscriptionPeriodUnit.day => 'day',
      QSubscriptionPeriodUnit.week => 'week',
      QSubscriptionPeriodUnit.month => 'month',
      QSubscriptionPeriodUnit.year => 'year',
      QSubscriptionPeriodUnit.unknown => 'day',
    };
    if (phase.isTrial || phase.price.isFree) {
      return ('$n ${_plural(unit, n)} free', true);
    }
    return ('${phase.price.formattedPrice} ${_forFirst(unit, n)}', false);
  }

  String _forFirst(String unit, int n) =>
      'for your first ${n == 1 ? unit : '$n ${_plural(unit, n)}'}';

  String _plural(String unit, int n) => n == 1 ? unit : '${unit}s';

  /// The plan's price per month, written like the store's own price string.
  String? _perMonth(QProduct p, int months) {
    final pretty = p.prettyPrice;
    final price = p.price;
    if (pretty == null || price == null) return null;
    return formatLikePrice(pretty, price / months);
  }

  Future<bool> _buy(
    QProduct product,
    QPurchaseOptions? options,
    String failure,
  ) async {
    final QPurchaseResult result;
    try {
      result = await _q.purchaseWithResult(product, purchaseOptions: options);
    } catch (_) {
      throw SubscriptionException(failure);
    }
    if (result.isCanceled || result.isPending) return false;
    if (result.isSuccess) return _premium(result.entitlements) != null;
    throw SubscriptionException(failure);
  }

  @override
  Future<bool> purchase(PlanOption plan) async {
    const failure =
        'The purchase could not be completed. You were not charged.';
    return switch (plan.handle) {
      _ProductWithOffer h => _buy(
        h.product,
        QPurchaseOptionsBuilder().setOffer(h.offer).build(),
        failure,
      ),
      QProduct p => _buy(p, null, failure),
      _ => throw const SubscriptionException('Unknown plan.'),
    };
  }

  @override
  Future<bool> restore() async {
    try {
      return _premium(await _q.restore()) != null;
    } catch (_) {
      throw const SubscriptionException(
        'Could not restore purchases. Please try again.',
      );
    }
  }

  @override
  Future<String> manageUrl() async => _storeSubscriptionsUrl();
}

/// [value] written in the style of a store price string such as "$39.99",
/// "39,99 €" or "¥5,800": same symbol and position, same decimal mark and
/// number of decimals. Falls back to two decimals with a dot.
String formatLikePrice(String sample, double value) {
  final m = RegExp(r'\d[\d.,\s  ]*\d|\d').firstMatch(sample);
  if (m == null) return value.toStringAsFixed(2);
  final digits = m.group(0)!;
  final dec = RegExp(r'([.,])(\d{1,2})$').firstMatch(digits);
  final places = dec == null ? 0 : dec.group(2)!.length;
  final mark = dec?.group(1) ?? '.';
  var number = value.toStringAsFixed(places);
  if (mark == ',') number = number.replaceAll('.', ',');
  return sample.replaceRange(m.start, m.end, number);
}
