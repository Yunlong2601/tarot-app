import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/core/subscription_service.dart';

void main() {
  test('per-month prices follow the store price style', () {
    expect(formatLikePrice(r'$39.99', 39.99 / 12), r'$3.33');
    expect(formatLikePrice('39,99 €', 39.99 / 12), '3,33 €');
    expect(formatLikePrice('¥5,800', 5800 / 12), '¥483');
    expect(formatLikePrice(r'S$59.98', 59.98 / 12), r'S$5.00');
  });
}
