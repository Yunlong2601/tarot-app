import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'core/analytics.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'app/app_scope.dart';
import 'app/app_state.dart';
import 'app/i18n.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/account_service.dart';
import 'core/credit_service.dart';
import 'core/creator_service.dart';
import 'core/referral_service.dart';
import 'core/api_reading_service.dart';
import 'core/reading_service.dart';
import 'core/reminder_service.dart';
import 'core/subscription_service.dart';
import 'core/user_key_store.dart';
import 'data/deck.dart';
import 'data/history_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deck = await Deck.load();
  // Set at build time: flutter run --dart-define=API_BASE_URL=https://...
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  // RevenueCat public SDK keys (one per platform), also via --dart-define.
  const iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
  const androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  final storeKey = Platform.isIOS ? iosKey : androidKey;
  late final AppState state;
  final reminders = LocalNotificationReminderService();
  final api = apiBaseUrl.isEmpty
      ? null
      : ApiReadingService(
          apiBaseUrl,
          userKey: () => state.activeUserKey(),
          focus: () => state.focusPayload,
        );
  state = AppState(
    deck: deck,
    userKeys: SecureUserKeyStore(),
    accountApi: api ?? const UnconfiguredAccountBackend(),
    referralApi: api ?? const UnconfiguredReferralBackend(),
    creditApi: api ?? const UnconfiguredCreditBackend(),
    creatorApi: api ?? const UnconfiguredCreatorBackend(),
    readingService: api ?? const UnconfiguredReadingService(),
    historyRepository: SqliteHistoryRepository(),
    reminders: reminders,
    subscriptions: storeKey.isEmpty
        ? const UnconfiguredSubscriptionService()
        : RevenueCatSubscriptionService(storeKey),
  );
  await state.loadLanguage();
  await state.loadPersisted();
  Analytics.instance.sink = api;
  unawaited(reminders.listenForOpens());
  unawaited(state.refreshReminders());
  unawaited(state.claimDailyCredit());
  unawaited(state.startSubscriptions());
  runApp(ShenTarotApp(initialState: state));
}

class ShenTarotApp extends StatefulWidget {
  const ShenTarotApp({super.key, required this.initialState});

  final AppState initialState;

  @override
  State<ShenTarotApp> createState() => _ShenTarotAppState();
}

class _ShenTarotAppState extends State<ShenTarotApp> {
  late final AppState _state = widget.initialState;
  late final GoRouter _router = buildRouter(_state);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: ValueListenableBuilder<String>(
        valueListenable: I18n.current,
        builder: (context, code, _) => MaterialApp.router(
          key: ValueKey(code),
          title: 'ShenTarot',
          locale: I18n.locale,
          supportedLocales: I18n.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: buildTheme(),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
