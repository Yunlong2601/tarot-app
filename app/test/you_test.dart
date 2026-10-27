import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';

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

  test('one rest day a week keeps the streak; two do not', () {
    // Mon 19 Oct 2026 to Sun 25 Oct. Read Mon, Tue, (rest Wed), Thu, Fri.
    final now = DateTime(2026, 10, 23, 20);
    final run = streakWithRest([
      DateTime(2026, 10, 19),
      DateTime(2026, 10, 20),
      DateTime(2026, 10, 22),
      DateTime(2026, 10, 23),
    ], now);
    expect(run.days, 4);
    expect(run.rested, DateTime(2026, 10, 21));
    // A second missed day in the same week ends it (Wed and Fri count, the
    // gap before Wed is the second miss).
    expect(
      readingStreak([
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 21),
        DateTime(2026, 10, 23),
      ], now),
      2,
    );
    // Rest days in different weeks are both fine.
    expect(
      readingStreak([
        DateTime(2026, 10, 15),
        DateTime(2026, 10, 17),
        DateTime(2026, 10, 18),
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 21),
        DateTime(2026, 10, 22),
        DateTime(2026, 10, 23),
      ], now),
      7,
    );
  });
}
