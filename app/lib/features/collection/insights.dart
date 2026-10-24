import '../../data/models.dart';

/// This month in your readings, worked out on the phone from saved history.
class MonthRecap {
  const MonthRecap({
    required this.readings,
    required this.topCards,
    required this.groups,
  });
  final int readings;

  /// Cards that came up more than once this month, most often first (up to 3).
  final List<(TarotCard, int)> topCards;

  /// How many cards came from each group: 'major', then the four suits.
  final Map<String, int> groups;

  int get cardCount => groups.values.fold(0, (a, b) => a + b);
}

MonthRecap recapFor(List<Reading> history, DateTime now) {
  final month = [
    for (final r in history)
      if (r.createdAt.year == now.year && r.createdAt.month == now.month) r,
  ];
  final counts = <String, (TarotCard, int)>{};
  final groups = <String, int>{
    'major': 0,
    for (final s in Suit.values) s.name: 0,
  };
  for (final r in month) {
    for (final d in r.cards) {
      final c = d.card;
      counts[c.id] = (c, (counts[c.id]?.$2 ?? 0) + 1);
      final g = c.arcana == Arcana.major ? 'major' : c.suit!.name;
      groups[g] = groups[g]! + 1;
    }
  }
  final top = counts.values.where((e) => e.$2 > 1).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
  return MonthRecap(
    readings: month.length,
    topCards: top.take(3).toList(),
    groups: groups,
  );
}

/// Longest run of days in a row with at least one reading.
int longestStreak(List<DateTime> dates) {
  final days = {
    for (final d in dates) DateTime(d.year, d.month, d.day),
  }.toList()..sort();
  var best = 0, run = 0;
  DateTime? prev;
  for (final d in days) {
    run = prev != null && d.difference(prev).inHours.round() <= 24
        ? run + 1
        : 1;
    if (run > best) best = run;
    prev = d;
  }
  return best;
}

class Milestone {
  const Milestone(this.title, this.detail, this.earned);
  final String title;
  final String detail;
  final bool earned;
}

/// Milestones from real use only; nothing is earned by tapping around.
/// Titles and details are English keys for tr().
List<Milestone> milestonesFor(
  List<Reading> history,
  Set<String> metIds,
  List<TarotCard> deck,
) {
  final majors = deck.where((c) => c.arcana == Arcana.major).map((c) => c.id);
  return [
    Milestone('First reading', 'Your first saved reading', history.isNotEmpty),
    Milestone('Ten readings', '10 saved readings', history.length >= 10),
    Milestone(
      'Celtic Cross',
      'A full ten-card Celtic Cross',
      history.any((r) => r.spread == SpreadType.celticCross),
    ),
    Milestone(
      'Seven days',
      'Readings on 7 days in a row',
      longestStreak([for (final r in history) r.createdAt]) >= 7,
    ),
    Milestone(
      'Major Arcana',
      'All 22 Major Arcana cards met',
      majors.every(metIds.contains),
    ),
    Milestone(
      'Whole deck',
      'All 78 cards met',
      deck.every((c) => metIds.contains(c.id)),
    ),
  ];
}
