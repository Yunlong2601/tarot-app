/// Refer and earn: the friend gets 50% off their first year of annual when they
/// subscribe; the referrer gets 1 free month per friend who pays (max 6 a year).
class ReferralInfo {
  const ReferralInfo({
    required this.code,
    required this.friendsJoined,
    required this.friendsPaid,
    required this.monthsEarned,
    required this.monthsPending,
    required this.maxPerYear,
    required this.friends,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> j) => ReferralInfo(
    code: j['code'] as String,
    friendsJoined: (j['friendsJoined'] as num?)?.toInt() ?? 0,
    friendsPaid: (j['friendsPaid'] as num?)?.toInt() ?? 0,
    monthsEarned: (j['monthsEarned'] as num?)?.toInt() ?? 0,
    monthsPending: (j['monthsPending'] as num?)?.toInt() ?? 0,
    maxPerYear: (j['maxPerYear'] as num?)?.toInt() ?? 6,
    friends: [
      for (final f in (j['friends'] as List? ?? const []))
        (joined: (f as Map)['joined'] as String, status: f['status'] as String),
    ],
  );

  final String code;
  final int friendsJoined;
  final int friendsPaid;
  final int monthsEarned;
  final int monthsPending;
  final int maxPerYear;

  /// Anonymous: the date a friend joined and "joined" / "pending" / "credited".
  final List<({String joined, String status})> friends;
}

/// What the friend's code unlocks at the paywall.
class ReferralOffer {
  const ReferralOffer({this.appleOfferCode, this.playOfferTag});
  final String? appleOfferCode;
  final String? playOfferTag;
}

class ReferralException implements Exception {
  const ReferralException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract class ReferralBackend {
  Future<ReferralInfo> me();
  Future<ReferralOffer> redeem(String code, String platform);
}

class UnconfiguredReferralBackend implements ReferralBackend {
  const UnconfiguredReferralBackend();
  static const _e = ReferralException('Invites are not available yet.');
  @override
  Future<ReferralInfo> me() => throw _e;
  @override
  Future<ReferralOffer> redeem(String code, String platform) => throw _e;
}

/// Tiers by friends who paid. Rewards beyond the free months are cosmetic;
/// their art is not made yet (see docs/referral-setup.md).
class ReferralTier {
  const ReferralTier(this.name, this.friends, this.perk);
  final String name;
  final int friends;
  final String perk;
}

const referralTiers = [
  ReferralTier('Seeker', 1, '1 free month for each friend who subscribes'),
  ReferralTier('Adept', 3, 'An exclusive card back'),
  ReferralTier('Mystic', 6, 'An alternate app icon and reading theme'),
  ReferralTier('Oracle', 10, 'The Oracle title, every cosmetic, early access'),
];

/// The highest tier reached, or null below Seeker.
ReferralTier? tierFor(int friendsPaid) =>
    referralTiers.where((t) => friendsPaid >= t.friends).lastOrNull;

ReferralTier? nextTier(int friendsPaid) =>
    referralTiers.where((t) => friendsPaid < t.friends).firstOrNull;
