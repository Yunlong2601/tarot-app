import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/core/daily_question.dart';
import 'package:shentarot/core/moon.dart';

void main() {
  test('the moon phase index agrees with New and Full Moon days for a year', () {
    var checked = 0;
    for (var i = 0; i < 365; i++) {
      final d = DateTime(2026, 1, 1 + i);
      final p = moonPhaseOn(d);
      if (p == null) continue;
      final idx = moonPhaseIndex(d);
      expect(idx, p.full ? 4 : 0, reason: '$d');
      checked++;
    }
    expect(checked, greaterThan(20));
  });

  test('a new question each day, repeating after thirty', () {
    final a = questionOfTheDay(DateTime(2026, 11, 2));
    expect(questionOfTheDay(DateTime(2026, 11, 3)), isNot(a));
    expect(questionOfTheDay(DateTime(2026, 12, 2)), a);
  });

  test('the widgets get a week of moons and questions, keyed by day', () {
    final m = AppState.premiumWidgetData(DateTime(2026, 11, 30, 22), 4);
    expect(m['qotd_2026-11-30'], isA<String>());
    expect(m['qotd_2026-12-7'], isA<String>());
    expect(m['moon_2026-12-1'], isA<int>());
    expect(m['streakTitle'], '4 days in a row');
  });
}
