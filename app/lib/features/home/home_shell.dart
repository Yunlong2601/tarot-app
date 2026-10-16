import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.center_focus_strong_outlined),
            selectedIcon: Icon(Icons.center_focus_strong),
            label: 'Read',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Guide',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'You',
          ),
        ],
      ),
    );
  }
}
