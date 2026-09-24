import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/navigation/app_bottom_nav.dart';

/// Scaffold for the authenticated+onboarded StatefulShellRoute — one
/// persistent bottom nav bar (Home/Search/Progress/Profile), each tab
/// keeping its own navigation stack via [StatefulNavigationShell].
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static const _items = [
    AppBottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    AppBottomNavItem(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Search'),
    AppBottomNavItem(
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up,
      label: 'Progress',
    ),
    AppBottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        items: _items,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping the already-active tab pops it back to that branch's
          // own root instead of leaving it on a pushed sub-screen — the
          // standard StatefulShellRoute pattern.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
