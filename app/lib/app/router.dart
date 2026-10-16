import 'package:go_router/go_router.dart';

import '../features/you/own_key_screen.dart';
import '../features/cards/card_detail_screen.dart';
import '../features/draw/draw_screen.dart';
import '../features/invite/invite_screen.dart';
import '../features/settings/settings_screens.dart';
import '../features/you/account_screen.dart';
import '../features/guide/guide_screen.dart';
import '../features/history/history_screen.dart';
import '../features/library/library_screen.dart';
import '../features/read/ask_screen.dart';
import '../features/read/daily_card_screen.dart';
import '../features/read/spread_picker_screen.dart';
import '../features/read/read_home_screen.dart';
import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/reading/reading_screen.dart';
import '../features/scan/camera_scan_screen.dart';
import '../features/scan/card_picker_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/settings/legal_screen.dart';
import '../features/you/you_screen.dart';
import 'app_state.dart';

GoRouter buildRouter(AppState state) {
  return GoRouter(
    initialLocation: '/read',
    refreshListenable: state,
    redirect: (context, routerState) {
      final onOnboarding = routerState.uri.path == '/onboarding';
      if (!state.onboarded && !onOnboarding) return '/onboarding';
      if (state.onboarded && onOnboarding) return '/read';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/read', builder: (_, _) => const ReadHomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/guide', builder: (_, _) => const GuideScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (_, _) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/you', builder: (_, _) => const YouScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/ask',
        builder: (_, s) => AskScreen(skipPicker: s.extra == true),
      ),
      GoRoute(path: '/spreads', builder: (_, _) => const SpreadPickerScreen()),
      GoRoute(path: '/own-key', builder: (_, _) => const OwnKeyScreen()),
      GoRoute(path: '/photo', builder: (_, _) => const ScanScreen()),
      GoRoute(path: '/digital', builder: (_, _) => const DrawScreen()),
      GoRoute(path: '/daily', builder: (_, _) => const DailyCardScreen()),
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
      GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
      GoRoute(path: '/invite', builder: (_, _) => const InviteScreen()),
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
      GoRoute(path: '/paywall', builder: (_, _) => const PaywallScreen()),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, s) => LegalScreen(doc: s.pathParameters['doc']!),
      ),
    ],
  );
}
