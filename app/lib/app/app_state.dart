import 'dart:math';

import 'i18n.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/account_service.dart';
import '../core/analytics.dart';
import '../core/credit_service.dart';
import '../core/creator_service.dart';
import '../core/referral_service.dart';
import 'flags.dart';
import '../core/install_id.dart';
import '../core/reading_service.dart';
import '../core/reminder_service.dart';
import '../core/subscription_service.dart';
import '../core/user_key_store.dart';
import '../data/deck.dart';
import '../data/history_repository.dart';
import '../data/models.dart';

enum ReadMode { photo, digital }

/// A one-off question asked when the user closes a reading.
enum AfterReadingAsk { none, reminder, review }

/// Days in a row with at least one reading, counting back from today (or
/// from yesterday when today has none yet).
int readingStreak(List<DateTime> dates, DateTime now) {
  final days = {for (final d in dates) DateTime(d.year, d.month, d.day)};
  var day = DateTime(now.year, now.month, now.day);
  if (!days.contains(day)) day = day.subtract(const Duration(days: 1));
  var n = 0;
  while (days.contains(day)) {
    n++;
    day = day.subtract(const Duration(days: 1));
  }
  return n;
}

/// App-wide state: onboarding, premium, today's free reading, saved history
/// (on device only) and the daily reminder.
class AppState extends ChangeNotifier {
  AppState({
    required this.deck,
    this.onboarded = false,
    this.readingService = const UnconfiguredReadingService(),
    this.subscriptions = const UnconfiguredSubscriptionService(),
    HistoryRepository? historyRepository,
    this.reminders = const NoopReminderService(),
    UserKeyStore? userKeys,
    this.accountApi = const UnconfiguredAccountBackend(),
    this.referralApi = const UnconfiguredReferralBackend(),
    this.creditApi = const UnconfiguredCreditBackend(),
    this.creatorApi = const UnconfiguredCreatorBackend(),
    SignInProvider? signIn,
    List<AccountProvider>? accountProviders,
    DateTime Function()? clock,
  }) : userKeys = userKeys ?? MemoryUserKeyStore(),
       accountProviders = accountProviders ?? availableProviders(),
       _signIn = signIn ?? PlatformSignIn(),
       _repo = historyRepository ?? InMemoryHistoryRepository(),
       _clock = clock ?? DateTime.now;

  final Deck deck;
  final ReadingService readingService;
  final SubscriptionService subscriptions;
  final ReminderService reminders;

  /// The user's own AI key (Premium). Only the provider is kept in memory for
  /// the UI; the key is read from secure storage when a request is made.
  final UserKeyStore userKeys;

  /// Optional account (Google / Apple). Null = guest, which is fine.
  final AccountBackend accountApi;

  /// Refer and earn (behind `referralsEnabled`).
  final ReferralBackend referralApi;

  /// Reading credits (behind `creditsEnabled`); the server holds the balance.
  final CreditBackend creditApi;

  /// Creator program (behind `creatorEnabled`).
  final CreatorBackend creatorApi;
  int credits = 0;

  /// New credits that arrive every day for this user, as the server reports it.
  int dailyCredits = 0;

  /// New credits that arrive every month for Premium (0 for free users).
  int monthlyCredits = 0;

  /// Today's daily credits (once a day for everyone), then the balance.
  Future<void> claimDailyCredit() async {
    if (!creditsEnabled) return;
    try {
      await creditApi.claimDaily();
    } catch (_) {}
    await refreshCredits();
  }

  /// Whether the server answered the last balance check. If it did not (no
  /// signal, server down), the app lets the reading start and the server
  /// decides, instead of blocking free users on a stale zero.
  bool creditsKnown = false;

  Future<void> refreshCredits() async {
    if (!creditsEnabled) return;
    try {
      final status = await creditApi.status();
      creditsKnown = true;
      credits = status.balance;
      dailyCredits = status.dailyAmount;
      monthlyCredits = status.monthlyAmount;
      notifyListeners();
    } catch (_) {
      creditsKnown = false;
      notifyListeners();
    }
  }

  /// One credit pays for a reading or a follow-up. The server checks and
  /// spends it; with no answer yet, assume there may be credits.
  bool get hasCredits => creditsEnabled && (credits > 0 || !creditsKnown);

  /// The one-line status under the reading buttons.
  String get creditLine {
    if (!creditsEnabled) {
      if (isPremium) return tr('Premium: 50 readings a day');
      final left = freeReadingsPerDay - freeReadingsUsedToday;
      return canReadForFree
          ? tr(
              left == 1
                  ? '{0} free reading left today'
                  : '{0} free readings left today',
              [left],
            )
          : guestCouldSignIn
          ? tr('Free reading used. Sign in for 2 a day, or go Premium.')
          : tr('Free readings used. Come back tomorrow or go Premium.');
    }
    final perDay = dailyCredits > 0 ? dailyCredits : 2;
    final perMonth = monthlyCredits > 0 ? monthlyCredits : 90;
    final plan = isPremium
        ? tr('{0} new credits every month, and {1} a day', [perMonth, perDay])
        : perDay == 1
        ? tr('1 new credit every day')
        : tr('{0} new credits every day', [perDay]);
    if (!creditsKnown) return tr('Checking your credits...');
    if (credits > 0) {
      return tr('{0} credits · {1}, unused credits roll over', [credits, plan]);
    }
    if (perDay == 1) {
      return isPremium
          ? tr('No credits left. 1 new credit arrives tomorrow.')
          : tr(
              'No credits left. 1 new credit arrives tomorrow, or go Premium.',
            );
    }
    return isPremium
        ? tr('No credits left. {0} new credits arrive tomorrow.', [perDay])
        : tr(
            'No credits left. {0} new credits arrive tomorrow, or go Premium.',
            [perDay],
          );
  }

  /// The friend's offer unlocked by a code typed on this phone, if any.
  ReferralOffer? referralOffer;
  static const _kRefTag = 'referral_offer_tag';
  static const _kRefApple = 'referral_apple_code';

  /// Uses a friend's code. Unlocks only the paywall offer; nothing is given
  /// for entering it (Apple 3.2.2). Throws [ReferralException].
  Future<void> redeemReferral(String code, {required bool ios}) async {
    final offer = await referralApi.redeem(
      code.trim(),
      ios ? 'ios' : 'android',
    );
    referralOffer = offer;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (offer.playOfferTag != null) {
        await prefs.setString(_kRefTag, offer.playOfferTag!);
      }
      if (offer.appleOfferCode != null) {
        await prefs.setString(_kRefApple, offer.appleOfferCode!);
      }
    } catch (_) {}
  }

  final SignInProvider _signIn;
  Account? account;

  /// Sign-in buttons offered on this build and platform (may be empty).
  final List<AccountProvider> accountProviders;
  bool get accountsAvailable => accountProviders.isNotEmpty || account != null;

  /// Signs in. Returns false if the user cancelled. Throws [AccountException].
  Future<bool> signIn(AccountProvider provider) async {
    final token = await _signIn.idToken(provider);
    if (token == null) return false;
    final id = await accountApi.signIn(
      provider,
      token,
      authorizationCode: _signIn.authorizationCode,
    );
    account = Account(id, provider);
    await _saveAccount();
    await _switchSubscriptionUser();
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    try {
      await accountApi.signOut();
    } catch (_) {}
    await _signIn.signOut();
    account = null;
    await _saveAccount();
    await _switchSubscriptionUser();
    notifyListeners();
  }

  /// Deletes the account on our server (and its usage records), then signs
  /// out here. History on this phone is kept; "Delete all my data" removes it.
  Future<void> deleteAccount() async {
    await accountApi.deleteAccount();
    await _signIn.signOut();
    account = null;
    await _saveAccount();
    await _switchSubscriptionUser();
    setPremium(false);
    notifyListeners();
  }

  Future<void> _switchSubscriptionUser() async {
    try {
      await subscriptions.switchUser(account?.id ?? await loadInstallId());
    } catch (e) {
      debugPrint('Subscription user switch failed: $e');
    }
  }

  static const _kAccountId = 'account_id';
  static const _kAccountProvider = 'account_provider';

  Future<void> _saveAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final a = account;
      if (a == null) {
        await prefs.remove(_kAccountId);
        await prefs.remove(_kAccountProvider);
      } else {
        await prefs.setString(_kAccountId, a.id);
        await prefs.setString(_kAccountProvider, a.provider.wire);
      }
    } catch (_) {}
  }

  AiProvider? ownKeyProvider;

  /// Own-key mode applies only while Premium is active.
  bool get usesOwnKey => ownKeyEnabled && isPremium && ownKeyProvider != null;

  /// What the reading service sends: the key, only in own-key mode.
  Future<UserKey?> activeUserKey() async =>
      usesOwnKey ? await userKeys.read() : null;

  Future<void> setOwnKey(UserKey key) async {
    await userKeys.save(key);
    ownKeyProvider = key.provider;
    notifyListeners();
  }

  Future<void> removeOwnKey() async {
    await userKeys.clear();
    ownKeyProvider = null;
    notifyListeners();
  }

  final HistoryRepository _repo;
  final DateTime Function() _clock;

  bool onboarded;

  /// Spread chosen on the Read tab / Library; shared by photo and digital readings.
  SpreadType selectedSpread = SpreadType.single;

  /// The question typed on the Ask screen for the reading in progress.
  String draftQuestion = '';

  /// Whether the one-time free reading of a longer spread has been used.
  bool trialUsed = false;

  /// The Read tab's main button: scan a physical deck or draw digitally.
  ReadMode readMode = ReadMode.photo;
  bool isPremium = false;

  /// Free AI readings a day: 2 when signed in, 1 for guests once sign-in is
  /// offered on this phone (matches the server's rule).
  static const signedInReadingsPerDay = 2;
  static const guestReadingsPerDay = 1;
  int get freeReadingsPerDay => account != null || accountProviders.isEmpty
      ? signedInReadingsPerDay
      : guestReadingsPerDay;

  /// A guest who could get more free readings by signing in.
  bool get guestCouldSignIn =>
      !isPremium && account == null && accountProviders.isNotEmpty;
  final List<Reading> history = [];

  /// Whether digital draws and the Card of the Day may come up reversed.
  bool readReversed = true;

  /// Whether to ask what you notice in the cards before the AI reading.
  /// Off in the constructor so tests stay simple; loadPersisted defaults it on.
  bool lookFirst = false;

  // Card of the Day: one free card per local day, drawn on the phone.
  String _dailyDate = '';
  String? _dailyId;
  bool _dailyReversed = false;

  bool reminderEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);

  /// The card planned for each coming day ('y-m-d' to card id), so the daily
  /// reminder can name the card that will turn up when it is drawn.
  final Map<String, String> _dailyPlan = {};

  /// One quiet evening nudge when a 3+ day streak would end (needs the daily
  /// reminder, which holds the notification permission).
  bool streakNudgeOn = true;

  /// The heads-up before an introductory price ends.
  bool billingReminders = true;

  /// Consent to messages about offers and news. Off unless the user turns it
  /// on (App Review Guideline 4.5.4); nothing promotional is sent without it.
  bool offersOptIn = false;

  /// Whether the daily reminder was offered after a reading.
  bool reminderAsked = false;

  /// Reading count when the App Store rating prompt was last requested.
  int reviewAskedAt = 0;

  /// Whether anonymous usage events are sent (Settings > Privacy).
  bool shareUsage = true;

  // Local mirror of today's free-reading count. The backend enforces the real
  // limit; this only drives the UI.
  String _usedDay = '';
  int _usedCount = 0;

  static const _kOnboarded = 'onboarded';
  static const _kLanguage = 'language';
  static const _kUsedDay = 'free_used_day';
  static const _kUsedCount = 'free_used_count';
  static const _kTrial = 'trial_used';
  static const _kReversed = 'read_reversed';
  static const _kLookFirst = 'look_first';
  static const _kDailyDate = 'daily_date';
  static const _kDailyId = 'daily_id';
  static const _kDailyRev = 'daily_reversed';
  static const _kReminderOn = 'reminder_on';
  static const _kReminderMin = 'reminder_minutes';
  static const _kDailyPlan = 'daily_plan';
  static const _kStreakNudge = 'streak_nudge';
  static const _kBillingReminders = 'billing_reminders';
  static const _kOffers = 'offers_opt_in';
  static const _kReminderAsked = 'reminder_asked';
  static const _kReviewAsked = 'review_asked_at';
  static const _kShareUsage = 'share_usage';

  String get _today => _dayKey(_clock());

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  int get freeReadingsUsedToday => _usedDay == _today ? _usedCount : 0;

  bool get canReadForFree => freeReadingsUsedToday < freeReadingsPerDay;

  /// Premium users get a daily allowance by plan (30 to 50); free users get two readings a day plus credits.
  bool canStart(SpreadType spread) {
    if (isPremium) return true;
    if (creditsEnabled) {
      return (credits > 0 || !creditsKnown) && (spread.isFree || !trialUsed);
    }
    if (!canReadForFree) return hasCredits;
    return spread.isFree || !trialUsed;
  }

  /// True when this spread would use the one-time free trial reading.
  bool usesTrial(SpreadType spread) =>
      !isPremium && !spread.isFree && !trialUsed;

  /// A button that spends a credit says so: "Get my reading · 1 credit". The
  /// free try of a longer spread costs nothing, so it keeps its plain label.
  String spendLabel(String label, {SpreadType? spread}) =>
      creditsEnabled && !(spread != null && usesTrial(spread))
      ? tr('{0} · 1 credit', [label])
      : label;

  /// Language chosen in Settings, or null to follow the phone.
  String? languageChoice;

  /// Loads the app language: the Settings choice, else the phone's language.
  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      languageChoice = prefs.getString(_kLanguage);
    } catch (_) {}
    await I18n.load(
      languageChoice ??
          I18n.codeForDevice(WidgetsBinding.instance.platformDispatcher.locale),
    );
  }

  /// [code] null = follow the phone.
  Future<void> setLanguage(String? code) async {
    languageChoice = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (code == null) {
        await prefs.remove(_kLanguage);
      } else {
        await prefs.setString(_kLanguage, code);
      }
    } catch (_) {}
    await I18n.load(
      code ??
          I18n.codeForDevice(WidgetsBinding.instance.platformDispatcher.locale),
    );
    notifyListeners();
  }

  /// Loads saved history and settings. Failures leave the app usable.
  Future<void> loadPersisted() async {
    ownKeyProvider = (await userKeys.read())?.provider;
    try {
      final prefs = await SharedPreferences.getInstance();
      onboarded = prefs.getBool(_kOnboarded) ?? onboarded;
      _usedDay = prefs.getString(_kUsedDay) ?? '';
      _usedCount = prefs.getInt(_kUsedCount) ?? 0;
      trialUsed = prefs.getBool(_kTrial) ?? false;
      readReversed = prefs.getBool(_kReversed) ?? true;
      _upgradeShown = prefs.getInt(_kUpgradeShown) ?? 0;
      autoReveal = prefs.getBool(_kAutoReveal) ?? false;
      final refTag = prefs.getString(_kRefTag);
      final refApple = prefs.getString(_kRefApple);
      if (refTag != null || refApple != null) {
        referralOffer = ReferralOffer(
          playOfferTag: refTag,
          appleOfferCode: refApple,
        );
      }
      if (testerMode && (prefs.getBool(_kTesterPremium) ?? false)) {
        isPremium = true;
      }
      final accId = prefs.getString(_kAccountId);
      final accProvider = AccountProvider.values
          .where((p) => p.wire == prefs.getString(_kAccountProvider))
          .firstOrNull;
      account = accId != null && accProvider != null
          ? Account(accId, accProvider)
          : null;
      lookFirst = prefs.getBool(_kLookFirst) ?? true;
      _dailyDate = prefs.getString(_kDailyDate) ?? '';
      _dailyId = prefs.getString(_kDailyId);
      _dailyReversed = prefs.getBool(_kDailyRev) ?? false;
      reminderEnabled = prefs.getBool(_kReminderOn) ?? false;
      final m = prefs.getInt(_kReminderMin);
      if (m != null) reminderTime = TimeOfDay(hour: m ~/ 60, minute: m % 60);
      _dailyPlan
        ..clear()
        ..addEntries([
          for (final e in prefs.getStringList(_kDailyPlan) ?? const <String>[])
            if (e.split('=') case [final day, final id]) MapEntry(day, id),
        ]);
      streakNudgeOn = prefs.getBool(_kStreakNudge) ?? true;
      billingReminders = prefs.getBool(_kBillingReminders) ?? true;
      offersOptIn = prefs.getBool(_kOffers) ?? false;
      reminderAsked = prefs.getBool(_kReminderAsked) ?? false;
      reviewAskedAt = prefs.getInt(_kReviewAsked) ?? 0;
      shareUsage = prefs.getBool(_kShareUsage) ?? true;
      Analytics.instance.enabled = shareUsage;
    } catch (e) {
      debugPrint('Could not load settings: $e');
    }
    try {
      history
        ..clear()
        ..addAll(await _repo.load(deck));
    } catch (e) {
      debugPrint('Could not load history: $e');
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboarded, onboarded);
      await prefs.setString(_kUsedDay, _usedDay);
      await prefs.setInt(_kUsedCount, _usedCount);
      await prefs.setBool(_kTrial, trialUsed);
      await prefs.setBool(_kReversed, readReversed);
      await prefs.setBool(_kLookFirst, lookFirst);
      await prefs.setString(_kDailyDate, _dailyDate);
      if (_dailyId != null) await prefs.setString(_kDailyId, _dailyId!);
      await prefs.setBool(_kDailyRev, _dailyReversed);
      await prefs.setBool(_kReminderOn, reminderEnabled);
      await prefs.setInt(
        _kReminderMin,
        reminderTime.hour * 60 + reminderTime.minute,
      );
      await prefs.setStringList(_kDailyPlan, [
        for (final e in _dailyPlan.entries) '${e.key}=${e.value}',
      ]);
      await prefs.setBool(_kStreakNudge, streakNudgeOn);
      await prefs.setBool(_kBillingReminders, billingReminders);
      await prefs.setBool(_kOffers, offersOptIn);
      await prefs.setBool(_kReminderAsked, reminderAsked);
      await prefs.setInt(_kReviewAsked, reviewAskedAt);
      await prefs.setBool(_kShareUsage, shareUsage);
    } catch (e) {
      debugPrint('Could not save settings: $e');
    }
  }

  /// Starts the store SDK. A failure must not block the app: the user simply
  /// stays on the free tier until it works.
  Future<void> startSubscriptions() async {
    try {
      await subscriptions.start(
        account?.id ?? await loadInstallId(),
        setPremium,
      );
    } catch (e) {
      debugPrint('Subscriptions failed to start: $e');
    }
  }

  void setDraftQuestion(String q) {
    draftQuestion = q.trim();
  }

  void selectSpread(SpreadType s) {
    selectedSpread = s;
    notifyListeners();
  }

  void setReadMode(ReadMode m) {
    readMode = m;
    notifyListeners();
  }

  /// Digital draws: turn each card face up as soon as it lands.
  bool autoReveal = false;
  static const _kAutoReveal = 'auto_reveal';

  Future<void> setAutoReveal(bool value) async {
    autoReveal = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kAutoReveal, value);
    } catch (_) {}
  }

  void setLookFirst(bool value) {
    lookFirst = value;
    _savePrefs();
    notifyListeners();
  }

  void setReadReversed(bool value) {
    readReversed = value;
    _savePrefs();
    notifyListeners();
  }

  /// Today's card if one has been drawn, else null.
  DrawnCard? get dailyCardIfDrawn {
    final id = _dailyId;
    if (id == null || _dailyDate != _today) return null;
    final card = deck.byId(id);
    return card == null
        ? null
        : DrawnCard(card: card, reversed: _dailyReversed);
  }

  /// Draws today's card once; later calls on the same day return the same card.
  /// No network and no AI: the text shown is the stored card knowledge.
  /// [notify] false is for calls made while a widget is building.
  DrawnCard drawDailyCard([Random? random, bool notify = true]) {
    final existing = dailyCardIfDrawn;
    if (existing != null) return existing;
    final r = random ?? Random.secure();
    // The card the reminder promised, if one was planned for today.
    final card =
        deck.byId(_dailyPlan[_today] ?? '') ??
        deck.cards[r.nextInt(deck.cards.length)];
    _dailyDate = _today;
    _dailyId = card.id;
    _dailyReversed = readReversed && r.nextDouble() < 0.25;
    _savePrefs();
    // Today's card is drawn: no reminder today.
    if (reminderEnabled) _guard(() => _scheduleDaily(skipToday: true));
    if (notify) notifyListeners();
    return DrawnCard(card: card, reversed: _dailyReversed);
  }

  /// On app start: roll the two-week reminder window forward.
  Future<void> refreshReminders() async {
    if (!reminderEnabled) return;
    await _guard(() => _scheduleDaily(skipToday: dailyCardIfDrawn != null));
    await _refreshStreakNudge();
  }

  Future<bool> _scheduleDaily({required bool skipToday}) async {
    final today = _clock();
    final from = DateTime(today.year, today.month, today.day);
    _dailyPlan.removeWhere((day, _) {
      final [y, m, d] = [for (final p in day.split('-')) int.tryParse(p) ?? 0];
      return DateTime(y, m, d).isBefore(from);
    });
    final ok = await reminders.enable(
      reminderTime,
      skipToday: skipToday,
      copy: reminderCopy,
    );
    await _savePrefs();
    return ok;
  }

  /// The card that will turn up as the Card of the Day on [day], chosen ahead
  /// so the reminder can name it.
  TarotCard plannedCard(DateTime day, [Random? random]) {
    final key = _dayKey(day);
    final planned = deck.byId(_dailyPlan[key] ?? '');
    if (planned != null) return planned;
    final r = random ?? Random.secure();
    final card = deck.cards[r.nextInt(deck.cards.length)];
    _dailyPlan[key] = card.id;
    return card;
  }

  /// The daily reminder's text for [day]: names the card waiting that day
  /// and what it is about, in one of five rotating wordings.
  ReminderCopy reminderCopy(DateTime day) {
    final card = plannedCard(day);
    final word = card.keywords.isEmpty ? card.name : card.keywords.first;
    final theme = I18n.code == 'en' ? word.toLowerCase() : word;
    final n = day.difference(DateTime(day.year)).inDays % 5;
    return switch (n) {
      0 => (
        title: tr('{0} is waiting for you', [card.name]),
        body: tr('A card about {0}. Take a quiet moment with it.', [theme]),
      ),
      1 => (
        title: tr('Today\'s card: {0}', [card.name]),
        body: tr('It speaks of {0}. What does it stir in you?', [theme]),
      ),
      2 => (
        title: tr('Your card of the day'),
        body: tr('{0} has turned up: a card about {1}.', [card.name, theme]),
      ),
      3 => (
        title: tr('A quiet moment'),
        body: tr('{0} is face down, waiting. A card about {1}.', [
          card.name,
          theme,
        ]),
      ),
      _ => (
        title: tr('Draw your card'),
        body: tr('Today brings {0}, a card about {1}.', [card.name, theme]),
      ),
    };
  }

  /// Days in a row with a reading.
  int get streak =>
      readingStreak([for (final r in history) r.createdAt], _clock());

  bool get readToday => history.any((r) => _dayKey(r.createdAt) == _today);

  /// Schedules tonight's streak nudge, or cancels it: only with the daily
  /// reminder on, a 3+ day streak and no reading yet today.
  Future<void> _refreshStreakNudge() => _guard(() async {
    await reminders.cancelStreakNudge();
    if (!reminderEnabled || !streakNudgeOn || readToday) return;
    final days = streak;
    if (days < 3) return;
    final hour = max(20, reminderTime.hour + 2);
    if (hour > 22) return;
    final now = _clock();
    await reminders.scheduleStreakNudge(
      DateTime(now.year, now.month, now.day, hour),
      (
        title: tr('Your {0}-day streak', [days]),
        body: tr('A short reading today keeps it going.'),
      ),
    );
  });

  Future<void> setStreakNudge(bool on) async {
    streakNudgeOn = on;
    await _savePrefs();
    notifyListeners();
    await _refreshStreakNudge();
  }

  /// Turns the "before an intro price ends" reminder on or off.
  Future<void> setBillingReminders(bool on) async {
    billingReminders = on;
    await _savePrefs();
    notifyListeners();
    if (on) {
      if (isPremium) await remindBeforeIntroEnds();
    } else {
      await _guard(reminders.cancelIntroEnding);
    }
  }

  /// Consent to offers and news. Turning it on asks for notification
  /// permission; returns false if that was refused (the setting stays off).
  Future<bool> setOffersOptIn(bool on) async {
    if (on) {
      var allowed = false;
      await _guard(() async => allowed = await reminders.requestPermission());
      if (!allowed) return false;
    }
    offersOptIn = on;
    logEvent('offers_opt_in', {'on': on});
    await _savePrefs();
    notifyListeners();
    return true;
  }

  /// What to ask, if anything, when the user closes a reading: offer the
  /// daily reminder after the first one, and the App Store rating after the
  /// 3rd and 10th (Apple shows it at most 3 times a year).
  AfterReadingAsk get afterReadingAsk {
    if (history.isEmpty) return AfterReadingAsk.none;
    if (!reminderAsked && !reminderEnabled) return AfterReadingAsk.reminder;
    final n = history.length;
    if ((n >= 3 && reviewAskedAt < 3) || (n >= 10 && reviewAskedAt < 10)) {
      return AfterReadingAsk.review;
    }
    return AfterReadingAsk.none;
  }

  Future<void> setShareUsage(bool on) async {
    shareUsage = on;
    Analytics.instance.enabled = on;
    if (!on) Analytics.instance.clear();
    await _savePrefs();
    notifyListeners();
  }

  void markReminderAsked() {
    reminderAsked = true;
    _savePrefs();
  }

  void markReviewAsked() {
    reviewAskedAt = history.length;
    _savePrefs();
  }

  /// Re-notifies listeners (used after a draw made during a widget build).
  void notifyChanged() => notifyListeners();

  static const _kUpgradeShown = 'annual_upgrade_shown';
  int _upgradeShown = 0;

  /// Monthly subscribers: offer annual once after 2 renewals (3 months paid)
  /// and one reminder after 6 months. Null when there is nothing to show.
  Future<int?> annualUpgradeMonths() async {
    if (!isPremium || !subscriptions.isConfigured) return null;
    final months = await subscriptions.monthlyMonthsPaid();
    if (months == null) return null;
    if (_upgradeShown == 0 && months >= 3) return months;
    if (_upgradeShown == 1 && months >= 6) return months;
    return null;
  }

  Future<void> dismissAnnualUpgrade() async {
    _upgradeShown++;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kUpgradeShown, _upgradeShown);
    } catch (_) {}
  }

  static const _kTesterPremium = 'tester_premium';

  /// Tester builds only (see `testerMode`): pretend Premium, remembered.
  Future<void> setTesterPremium(bool on) async {
    if (!testerMode) return;
    setPremium(on);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kTesterPremium, on);
    } catch (_) {}
  }

  void completeOnboarding() {
    onboarded = true;
    _savePrefs();
    notifyListeners();
  }

  /// With reminders on: a heads-up 2 days before an introductory price ends.
  Future<void> scheduleIntroReminder() async {
    if (!isPremium || !reminderEnabled || !billingReminders) return;
    try {
      final end = await subscriptions.introEndsAt();
      if (end != null) {
        await reminders.scheduleIntroEnding(
          end.subtract(const Duration(days: 2)),
        );
      }
    } catch (e) {
      debugPrint('Intro reminder failed: $e');
    }
  }

  /// Asked for after a purchase: a heads-up 2 days before a free trial or
  /// intro price ends, even with the daily reminder off. Returns the reminder
  /// time, or null if there is no intro period or notifications are refused.
  Future<DateTime?> remindBeforeIntroEnds() async {
    try {
      final end = await subscriptions.introEndsAt();
      if (end == null) return null;
      final at = end.subtract(const Duration(days: 2));
      if (!at.isAfter(DateTime.now())) return null;
      if (!await reminders.requestPermission()) return null;
      await reminders.scheduleIntroEnding(at);
      return at;
    } catch (e) {
      debugPrint('Intro reminder failed: $e');
      return null;
    }
  }

  void setPremium(bool value) {
    if (isPremium == value) return;
    isPremium = value;
    if (value) scheduleIntroReminder();
    notifyListeners();
  }

  void addReading(Reading reading) {
    history.insert(0, reading);
    logEvent('reading_done', {
      'spread': reading.spread.name,
      'n': history.length,
      'premium': isPremium,
      'trial': !isPremium && !reading.spread.isFree && !trialUsed,
      'question': reading.question != null,
    });
    if (!isPremium) {
      if (!reading.spread.isFree) trialUsed = true;
      _usedCount = freeReadingsUsedToday + 1;
      _usedDay = _today;
      _savePrefs();
    }
    _guard(() => _repo.add(reading));
    _scheduleLookBack(reading);
    _refreshStreakNudge();
    notifyListeners();
  }

  /// Journal note (Premium feature; the UI gates it).
  void setNote(String id, String? note) {
    final i = history.indexWhere((r) => r.id == id);
    if (i < 0) return;
    history[i] = history[i].withNote(note);
    _guard(() => _repo.setNote(id, note));
    notifyListeners();
  }

  /// Premium with the daily reminder on: a one-off nudge 7 days later at the
  /// reminder time, so the look back is not forgotten.
  void _scheduleLookBack(Reading r) {
    if (!isPremium || !reminderEnabled) return;
    final d = r.createdAt.add(const Duration(days: 7));
    final at = DateTime(
      d.year,
      d.month,
      d.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    _guard(() => reminders.scheduleLookBack(r.id, at));
  }

  /// Look back about a week later (Premium): saves what the user writes, or
  /// '' to dismiss the prompt for this reading.
  void setRevisit(String id, String text) {
    final i = history.indexWhere((r) => r.id == id);
    if (i < 0) return;
    history[i] = history[i].withRevisit(text);
    _guard(() => _repo.setRevisit(id, text));
    _guard(() => reminders.cancelLookBack(id));
    notifyListeners();
  }

  /// Whether [r] is old enough (7+ days) and recent enough (under 60) to ask
  /// "how did this turn out?", and has not been answered or dismissed.
  bool revisitDue(Reading r, {DateTime? now}) {
    if (!isPremium || r.revisit != null) return false;
    final age = (now ?? DateTime.now()).difference(r.createdAt);
    return age.inDays >= 7 && age.inDays < 60;
  }

  /// The newest reading waiting for a look-back, if any.
  Reading? get dueRevisit => history.where(revisitDue).firstOrNull;

  void deleteReading(String id) {
    history.removeWhere((r) => r.id == id);
    _guard(() => reminders.cancelLookBack(id));
    _guard(() => _repo.delete(id));
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    history.clear();
    await removeOwnKey();
    notifyListeners();
    await _guard(_repo.clear);
  }

  /// Turns the daily reminder on or off. Returns false if the user denied the
  /// notification permission (the setting then stays off).
  Future<bool> setReminder(bool on, {TimeOfDay? time}) async {
    if (time != null) reminderTime = time;
    if (on) {
      reminderEnabled = await _scheduleDaily(
        skipToday: dailyCardIfDrawn != null,
      );
    } else {
      await reminders.disable();
      reminderEnabled = false;
    }
    await _savePrefs();
    notifyListeners();
    await _refreshStreakNudge();
    if (reminderEnabled) {
      logEvent('reminder_set', {'hour': reminderTime.hour});
    }
    return reminderEnabled == on;
  }

  Future<void> _guard(Future<void> Function() op) async {
    try {
      await op();
    } catch (e) {
      debugPrint('History storage error: $e');
    }
  }
}
