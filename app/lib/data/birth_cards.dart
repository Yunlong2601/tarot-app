/// Birth cards and the year card, a common numerology method (popularised by
/// Mary K. Greer): add the month, the day and the full year as numbers, then
/// add the digits of the total until it is 22 or less. That number is a Major
/// Arcana card (22 counts as The Fool, 0). A two-digit result also gives the
/// card for the sum of its digits, and so on down to one digit, so a birthday
/// gives one to three cards. No AI, nothing stored or sent.
int _digits(int n) =>
    n.toString().split('').fold(0, (s, d) => s + int.parse(d));

/// Major Arcana numbers for a date, largest first (e.g. 19, 10, 1).
List<int> birthCardNumbers(int year, int month, int day) {
  var n = year + month + day;
  while (n > 22) {
    n = _digits(n);
  }
  if (n == 22) return [0, 4]; // The Fool, paired with 2 + 2 = The Emperor
  final out = [n];
  while (n >= 10) {
    n = _digits(n);
    out.add(n);
  }
  return out;
}

/// The card for a year of life: the same sum with that year instead of the
/// birth year. Only the first card is the year card.
int yearCardNumber(int month, int day, int year) =>
    birthCardNumbers(year, month, day).first;
