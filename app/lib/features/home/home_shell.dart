import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../today/today_screen.dart';

/// Five tabs: Today, Draw, Scan (middle), Learn, You. Scan is not a page: it
/// starts a reading with your own cards, shown as a gold card with a lens.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  /// Bar position of the Scan button; the four pages sit around it.
  static const scanIndex = 2;

  int get _barIndex => shell.currentIndex >= scanIndex
      ? shell.currentIndex + 1
      : shell.currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _barIndex,
        onDestinationSelected: (i) {
          if (i == scanIndex) {
            startPhotoReading(context);
            return;
          }
          final branch = i > scanIndex ? i - 1 : i;
          shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny),
            label: tr('Today'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: tr('Draw'),
          ),
          NavigationDestination(
            icon: const LensCardIcon(),
            label: tr('Scan'),
            tooltip: tr('Scan your cards'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: tr('Learn'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: tr('You'),
          ),
        ],
      ),
    );
  }
}

/// A small gold tarot card with a camera lens on its face: the Scan button.
class LensCardIcon extends StatelessWidget {
  const LensCardIcon({super.key});

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -0.08,
    child: Container(
      width: 30,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3DFA2), AppColors.gold, Color(0xFFB8913F)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.45),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppColors.onGold.withValues(alpha: 0.5)),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.camera, size: 20, color: AppColors.onGold),
      ),
    ),
  );
}
