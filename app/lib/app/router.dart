import 'package:go_router/go_router.dart';

import '../features/today/today_screen.dart';

import '../features/you/own_key_screen.dart';
import '../features/cards/card_detail_screen.dart';
import '../features/draw/draw_screen.dart';
import '../features/creator/creator_screen.dart';
import '../features/invite/invite_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/settings_screens.dart';
import '../features/you/account_screen.dart';
import '../features/history/history_screen.dart';
import '../features/library/library_screen.dart';
import '../features/read/ask_screen.dart';
import '../features/read/daily_card_screen.dart';
import '../features/read/spread_picker_screen.dart';
import '../features/read/read_home_screen.dart';
import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/paywall/welcome_premium_screen.dart';
import '../features/reading/reading_screen.dart';
import '../features/scan/camera_scan_screen.dart';
import '../features/scan/card_picker_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/settings/legal_screen.dart';
import '../features/collection/collection_screen.dart';
import '../features/paywall/out_of_credits.dart';
import '../features/you/you_screen.dart';
import 'app_state.dart';
import 'motion.dart';

GoRouter buildRouter(AppState state) {
  return GoRouter(
    initialLocation: '/today',
    refreshListenable: state,
    redirect: (context, routerState) {
      final onOnboarding = routerState.uri.path == '/onboarding';
      if (!state.onboarded && !onOnboarding) return '/onboarding';
      if (state.onboarded && onOnboarding) return '/today';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/read', builder: (_, _) => const ReadHomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/learn', builder: (_, _) => const LibraryScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/you', builder: (_, _) => const YouScreen()),
            ],
          ),
        ],
      ),
      GoRoute(path: '/guide', redirect: (_, _) => '/learn'),
      GoRoute(path: '/library', redirect: (_, _) => '/learn'),
      GoRoute(
        path: '/ask',
        builder: (_, s) => AskScreen(skipPicker: s.extra == true),
      ),
      GoRoute(path: '/spreads', builder: (_, _) => const SpreadPickerScreen()),
      GoRoute(path: '/own-key', builder: (_, _) => const OwnKeyScreen()),
      GoRoute(path: '/photo', builder: (_, _) => const ScanScreen()),
      GoRoute(path: '/digital', builder: (_, _) => const DrawScreen()),
      GoRoute(
        path: '/daily',
        pageBuilder: (_, s) => modalPage(s, const DailyCardScreen()),
      ),
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
      GoRoute(path: '/collection', builder: (_, _) => const CollectionScreen()),
      GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
      GoRoute(path: '/invite', builder: (_, _) => const InviteScreen()),
      GoRoute(path: '/creator', builder: (_, _) => const CreatorScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: '/settings/reminders',
        builder: (_, _) => const ReminderSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/reading',
        builder: (_, _) => const ReadingSettingsScreen(),
      ),
      GoRoute(
        path: '/card/:id',
        builder: (_, s) => CardDetailScreen(cardId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/scan-camera',
        builder: (_, s) => CameraScanScreen(count: s.extra! as int),
      ),
      GoRoute(path: '/pick', builder: (_, _) => const CardPickerScreen()),
      GoRoute(
        path: '/reading/:id',
        builder: (_, s) => ReadingScreen(readingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/paywall',
        pageBuilder: (_, s) => modalPage(
          s,
          PaywallScreen(
            reason: s.extra is PaywallReason
                ? s.extra! as PaywallReason
                : PaywallReason.general,
          ),
        ),
      ),
      GoRoute(
        path: '/welcome-premium',
        pageBuilder: (_, s) {
          final e = s.extra as ({String? plan, bool restored})?;
          return modalPage(
            s,
            WelcomePremiumScreen(plan: e?.plan, restored: e?.restored ?? false),
          );
        },
      ),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, s) => LegalScreen(doc: s.pathParameters['doc']!),
      ),
    ],
  );
}
