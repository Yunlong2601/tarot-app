/// Reading credits: 1 credit = one extra AI reading after the free daily one,
/// or a follow-up / clarifier for a free user. Bought as a Starter Pack; never
/// expire. The server holds the balance.
abstract class CreditBackend {
  Future<int> balance();
}

class UnconfiguredCreditBackend implements CreditBackend {
  const UnconfiguredCreditBackend();
  @override
  Future<int> balance() async => 0;
}

/// Store product id of the Starter Pack (5 credits, consumable).
const starterPackProductId = 'shentarot_credits_5';
