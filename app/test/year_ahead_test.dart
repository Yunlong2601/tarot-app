import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/data/spreads.dart';

void main() {
  test('the Year Ahead is a 13-card Premium spread, kept in step with the server', () {
    final t = SpreadType.yearAhead;
    expect(t.cardCount, 13);
    expect(t.def.layout, hasLength(13));
    expect(t.isPremium, isTrue);
    final server = File('../backend/src/spreads.ts').readAsStringSync();
    expect(server, contains('year_ahead: {'));
    expect(server, contains('"Theme of the year", "Month 1"'));
  });

  test('its months start the month after the reading was made', () {
    final p = SpreadType.yearAhead.positionsFrom(DateTime(2026, 11, 2));
    expect(p.first, 'Theme of the year');
    expect(p[1], 'December');
    expect(p[2], 'January');
    expect(p.last, 'November');
  });

  test('a question about the year ahead is offered it first', () {
    expect(
      recommendSpread('What do I need to know about the year ahead?'),
      SpreadType.yearAhead,
    );
  });
}
