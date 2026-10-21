import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/features/paywall/paywall_screen.dart';

void main() {
  test('per-credit prices keep the store currency format', () {
    expect(perUnitString('\$1.99', 1.99 / 10), '\$0.20');
    expect(perUnitString('1,99 €', 0.199), '0,20 €');
    expect(perUnitString('¥300', 30), '¥30');
    expect(perUnitString('free', 1), isNull);
  });

  test('Premium per credit uses the cheapest plan', () {
    // Annual \$39.99 / (150 x 12) is about \$0.02; monthly \$6.99 / 90 is \$0.08.
    expect(premiumPerCredit(previewPlans), '\$0.02');
  });
}
