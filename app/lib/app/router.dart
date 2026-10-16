import 'package:go_router/go_router.dart';

import '../features/cards/card_detail_screen.dart';
import '../features/cards/cards_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/reading/reading_screen.dart';
import '../features/scan/camera_scan_screen.dart';
import '../features/scan/card_picker_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/settings/legal_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_state.dart';

GoRouter buildRouter(AppState state) {
  return GoRouter(
    initialLocation: '/scan',
    refreshListenable: state,
    redirect: (context, routerState) {
      final onOnboarding = routerState.uri.path == '/onboarding';
      if (!state.onboarded && !onOnboarding) return '/onboarding';
      if (state.onboarded && onOnboarding) return '/scan';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/cards', builder: (_, _) => const CardsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/history', builder: (_, _) => const HistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/settings', builder: (_, _) => const SettingsScreen()),
          ]),
        ],
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
