import '../app/i18n.dart';
import 'moon.dart';

/// Thirty questions to sit with, one a day (the widget and Today). Gentle,
/// open, about the user's own life; never predictions.
const dailyQuestions = [
  'What am I ready to let go of?',
  'Where do I feel most like myself lately?',
  'What would make today ten percent lighter?',
  'What am I avoiding, and why?',
  'Who could I thank today?',
  'What does my body need right now?',
  'What small promise can I keep to myself today?',
  'What am I learning from something hard?',
  'Where am I being too hard on myself?',
  'What would I do today if I trusted myself fully?',
  'What is quietly going well?',
  'What story am I telling myself that may not be true?',
  'What do I want more of this week?',
  'What boundary would protect my energy?',
  'What did I enjoy as a child that I could return to?',
  'What feeling am I carrying that wants to be heard?',
  'What is one thing I can stop doing?',
  'Where am I waiting for permission I do not need?',
  'What would kindness to myself look like today?',
  'What am I curious about right now?',
  'What is worth being patient with?',
  'What would I tell a friend in my place?',
  'What gives me energy, and what drains it?',
  'What does a good enough day look like?',
  'What am I proud of that no one saw?',
  'What change am I resisting?',
  'Where could I ask for help?',
  'What matters most to me this month?',
  'What would make me feel at home in my life?',
  'What is the next small step, not the whole path?',
];

/// The question for [day], the same for everyone on that calendar day.
String questionOfTheDay(DateTime day) {
  final n = DateTime.utc(day.year, day.month, day.day)
      .difference(DateTime.utc(2026))
      .inDays;
  return tr(dailyQuestions[n % dailyQuestions.length]);
}

const _moonNames = [
  'New Moon',
  'Waxing Crescent',
  'First Quarter',
  'Waxing Gibbous',
  'Full Moon',
  'Waning Gibbous',
  'Last Quarter',
  'Waning Crescent',
];

/// The moon's phase on [day] at noon, 0 (new) to 7 (waning crescent).
int moonPhaseIndex(DateTime day) {
  final noon = DateTime(day.year, day.month, day.day, 12);
  final news = moonPhasesAfter(
    noon.subtract(const Duration(days: 32)),
    count: 6,
  ).where((p) => !p.full && !p.at.isAfter(noon.toUtc()));
  final age = noon.toUtc().difference(news.last.at).inMinutes / 1440;
  return ((age / 29.530588) * 8).round() % 8;
}

/// The phase's name in the app language.
String moonPhaseName(int index) => tr(_moonNames[index]);
