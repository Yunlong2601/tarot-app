import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/app_scope.dart';
import 'app/app_state.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/api_reading_service.dart';
import 'core/reading_service.dart';
import 'core/reminder_service.dart';
import 'core/subscription_service.dart';
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
  final state = AppState(
    deck: deck,
    readingService: apiBaseUrl.isEmpty
        ? const UnconfiguredReadingService()
        : ApiReadingService(apiBaseUrl),
    historyRepository: SqliteHistoryRepository(),
    reminders: LocalNotificationReminderService(),
    subscriptions: storeKey.isEmpty
        ? const UnconfiguredSubscriptionService()
        : RevenueCatSubscriptionService(storeKey),
  );
  await state.loadPersisted();
  unawaited(state.startSubscriptions());
  runApp(ShenScanApp(initialState: state));
}

class ShenScanApp extends StatefulWidget {
  const ShenScanApp({super.key, required this.initialState});

  final AppState initialState;

  @override
  State<ShenScanApp> createState() => _ShenScanAppState();
}

class _ShenScanAppState extends State<ShenScanApp> {
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
      child: MaterialApp.router(
        title: 'ShenScan',
        theme: buildTheme(),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
