import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/data/birth_cards.dart';

void main() {
  test('birth cards: add month, day and year, then digits, down to 22', () {
    expect(birthCardNumbers(1990, 7, 15), [5]); // 2012 -> 5
    expect(birthCardNumbers(1981, 12, 25), [11, 2]); // 2018 -> 11 -> 2
    expect(birthCardNumbers(1999, 12, 28), [14, 5]); // 2039 -> 14 -> 5
    expect(birthCardNumbers(1978, 1, 1), [18, 9]); // 1980 -> 18 -> 9
  });

  test('22 is The Fool with The Emperor; the year card is the first card', () {
    expect(birthCardNumbers(1980, 12, 1), [0, 4]); // 1993 -> 22
    expect(yearCardNumber(7, 15, 2026), birthCardNumbers(2026, 7, 15).first);
  });
}
