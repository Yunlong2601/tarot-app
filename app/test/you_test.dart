import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/features/you/you_screen.dart';

void main() {
  test('reading streak counts days in a row ending today or yesterday', () {
    final now = DateTime(2026, 10, 17, 9);
    expect(readingStreak([], now), 0);
    expect(
      readingStreak([
        DateTime(2026, 10, 17, 8),
        DateTime(2026, 10, 16, 20),
        DateTime(2026, 10, 16, 7),
        DateTime(2026, 10, 15),
        DateTime(2026, 10, 12),
      ], now),
      3,
    );
    expect(readingStreak([DateTime(2026, 10, 16)], now), 1);
    expect(readingStreak([DateTime(2026, 10, 14)], now), 0);
  });
}
