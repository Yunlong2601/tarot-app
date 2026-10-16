import 'package:flutter/foundation.dart';

import '../data/deck.dart';
import '../data/mock_data.dart';
import '../data/models.dart';

/// Phase A mock app state. Replaced by SQLite repositories (Phase F) and
/// RevenueCat entitlements (Phase E).
class AppState extends ChangeNotifier {
  AppState({required this.deck, this.onboarded = false})
      : history = buildMockHistory(deck);

  final Deck deck;

  bool onboarded;
  bool isPremium = false;
  int freeReadingsUsedToday = 0;
  static const freeReadingsPerDay = 1;
  final List<Reading> history;

  bool get canReadForFree => freeReadingsUsedToday < freeReadingsPerDay;

  /// Premium users are unlimited; free users get one single-card reading a day.
  bool canStart(SpreadType spread) {
    if (isPremium) return true;
    return !spread.isPremium && canReadForFree;
  }

  void completeOnboarding() {
    onboarded = true;
    notifyListeners();
  }

  void setPremium(bool value) {
    isPremium = value;
    notifyListeners();
  }

  void addReading(Reading reading) {
    history.insert(0, reading);
    if (!isPremium) freeReadingsUsedToday++;
    notifyListeners();
  }

  void deleteAllData() {
    history.clear();
    notifyListeners();
  }
}
