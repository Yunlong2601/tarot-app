import '../../data/models.dart';

enum HistoryPeriod { any, week, month, year }

extension HistoryPeriodLabel on HistoryPeriod {
  String get label => switch (this) {
    HistoryPeriod.any => 'Any time',
    HistoryPeriod.week => 'Past 7 days',
    HistoryPeriod.month => 'Past 30 days',
    HistoryPeriod.year => 'Past year',
  };
}

/// Search matches card names, the question and the journal note. Filters by
/// spread category and how recent the reading is.
List<Reading> filterHistory(
  List<Reading> all, {
  String query = '',
  SpreadCategory? category,
  HistoryPeriod period = HistoryPeriod.any,
  DateTime? now,
}) {
  final q = query.trim().toLowerCase();
  final today = now ?? DateTime.now();
  final since = switch (period) {
    HistoryPeriod.any => null,
    HistoryPeriod.week => today.subtract(const Duration(days: 7)),
    HistoryPeriod.month => today.subtract(const Duration(days: 30)),
    HistoryPeriod.year => today.subtract(const Duration(days: 365)),
  };
  return [
    for (final r in all)
      if ((category == null || r.spread.category == category) &&
          (since == null || r.createdAt.isAfter(since)) &&
          (q.isEmpty ||
              r.cards.any((c) => c.card.name.toLowerCase().contains(q)) ||
              (r.question ?? '').toLowerCase().contains(q) ||
              (r.note ?? '').toLowerCase().contains(q) ||
              r.spread.label.toLowerCase().contains(q)))
        r,
  ];
}
