/// Reading credits: 1 credit = one AI reading or one follow-up / clarifier.
/// Everyone gets new credits every day; unused ones roll over and never
/// never expire; everyone gets new credits every day.
/// The server holds the balance.
/// What the server says about the credit wallet.
class CreditStatus {
  const CreditStatus({required this.balance, required this.dailyAmount});

  /// Credits held (daily credits that rolled over plus bonus credits).
  final int balance;

  /// New credits that arrive each day for this user (free 2; Premium 30 to 50).
  final int dailyAmount;
}

abstract class CreditBackend {
  Future<CreditStatus> status();

  /// Claims today's daily credits; returns how many were added (0 if already
  /// claimed today or the bank is full).
  Future<int> claimDaily();
}

class UnconfiguredCreditBackend implements CreditBackend {
  const UnconfiguredCreditBackend();
  @override
  Future<CreditStatus> status() async =>
      const CreditStatus(balance: 0, dailyAmount: 0);

  @override
  Future<int> claimDaily() async => 0;
}

/// Store product id of the Starter Pack (5 credits, consumable).
const starterPackProductId = 'shentarot_credits_5';
