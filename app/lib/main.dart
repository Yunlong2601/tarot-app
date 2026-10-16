import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/app_scope.dart';
import 'app/app_state.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/api_reading_service.dart';
import 'core/reading_service.dart';
import 'data/deck.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deck = await Deck.load();
  // Set at build time: flutter run --dart-define=API_BASE_URL=https://...
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  runApp(VeilscanApp(
    initialState: AppState(
      deck: deck,
      readingService: apiBaseUrl.isEmpty
          ? const UnconfiguredReadingService()
          : ApiReadingService(apiBaseUrl),
    ),
  ));
}

class VeilscanApp extends StatefulWidget {
  const VeilscanApp({super.key, required this.initialState});

  final AppState initialState;

  @override
  State<VeilscanApp> createState() => _VeilscanAppState();
}

class _VeilscanAppState extends State<VeilscanApp> {
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
        title: 'Veilscan',
        theme: buildTheme(),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
