import 'package:flutter/foundation.dart';

import '../core/install_id.dart';
import '../core/reading_service.dart';
import '../core/subscription_service.dart';
import '../data/deck.dart';
import '../data/mock_data.dart';
import '../data/models.dart';

/// Phase A mock app state. Replaced by SQLite repositories (Phase F) and
/// RevenueCat entitlements (Phase E).
class AppState extends ChangeNotifier {
  AppState({
    required this.deck,
    this.onboarded = false,
    this.readingService = const UnconfiguredReadingService(),
    this.subscriptions = const UnconfiguredSubscriptionService(),
  }) : history = buildMockHistory(deck);

  final Deck deck;
  final ReadingService readingService;
  final SubscriptionService subscriptions;

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

  /// Starts the store SDK. A failure must not block the app: the user simply
  /// stays on the free tier until it works.
  Future<void> startSubscriptions() async {
    try {
      await subscriptions.start(await loadInstallId(), setPremium);
    } catch (e) {
      debugPrint('Subscriptions failed to start: $e');
    }
  }

  void completeOnboarding() {
    onboarded = true;
    notifyListeners();
  }

  void setPremium(bool value) {
    if (isPremium == value) return;
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
