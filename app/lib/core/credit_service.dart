/// Reading credits: 1 credit = one AI reading or one follow-up / clarifier.
/// Everyone gets new credits every day and Premium also every month; unused ones roll over and never
/// never expire; everyone gets new credits every day.
/// The server holds the balance.
/// What the server says about the credit wallet.
class CreditStatus {
  const CreditStatus({
    required this.balance,
    required this.dailyAmount,
    this.monthlyAmount = 0,
  });

  /// Credits held (daily credits that rolled over plus bonus credits).
  final int balance;

  /// New credits that arrive each day for everyone (2).
  final int dailyAmount;

  /// New credits that arrive each month for Premium (90 to 150); 0 for free users.
  final int monthlyAmount;
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

/// Consumable credit packs (small impulse purchases). Priced per credit well
/// above Premium's monthly credits on purpose: Premium is the better deal, so
/// the packs nudge heavier users toward a subscription. The number in the id
/// is the credit count (the server reads it the same way).
const creditPackProductIds = [
  'shentarot_credits_10',
  'shentarot_credits_25',
  'shentarot_credits_40',
];

/// Credits in a pack product id, e.g. 'shentarot_credits_25' -> 25.
int creditsInPack(String productId) {
  final m = RegExp(r'credits_(\d{1,3})').firstMatch(productId);
  return m == null ? 0 : int.parse(m.group(1)!);
}
