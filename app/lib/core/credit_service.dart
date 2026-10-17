/// Reading credits: 1 credit = one extra AI reading after the free daily one,
/// or a follow-up / clarifier for a free user. Bought as a Starter Pack; never
/// never expire; everyone also gets one login credit a day (banked up to 3).
/// The server holds the balance.
abstract class CreditBackend {
  Future<int> balance();

  /// Claims today's login credit; returns how many were added (0 if already
  /// claimed today or the bank is full).
  Future<int> claimDaily();
}

class UnconfiguredCreditBackend implements CreditBackend {
  const UnconfiguredCreditBackend();
  @override
  Future<int> balance() async => 0;

  @override
  Future<int> claimDaily() async => 0;
}

/// Store product id of the Starter Pack (5 credits, consumable).
const starterPackProductId = 'shentarot_credits_5';
