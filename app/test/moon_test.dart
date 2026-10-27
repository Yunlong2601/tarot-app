import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/core/moon.dart';

void main() {
  test('New and Full Moon times match published values', () {
    // Published (UTC): New Moon 11 Jan 2024 11:57, Full Moon 25 Jan 2024 17:54.
    final p = moonPhasesAfter(DateTime.utc(2024, 1, 1));
    expect(p[0].full, isFalse);
    expect(
      p[0].at.difference(DateTime.utc(2024, 1, 11, 11, 57)).inMinutes.abs(),
      lessThan(10),
    );
    expect(p[1].full, isTrue);
    expect(
      p[1].at.difference(DateTime.utc(2024, 1, 25, 17, 54)).inMinutes.abs(),
      lessThan(10),
    );
  });

  test('phases alternate about every 15 days', () {
    final p = moonPhasesAfter(DateTime.utc(2026, 10, 1), count: 6);
    for (var i = 1; i < p.length; i++) {
      expect(p[i].full, !p[i - 1].full);
      final gap = p[i].at.difference(p[i - 1].at).inHours;
      expect(gap, inInclusiveRange(13 * 24, 16 * 24));
    }
  });
}
