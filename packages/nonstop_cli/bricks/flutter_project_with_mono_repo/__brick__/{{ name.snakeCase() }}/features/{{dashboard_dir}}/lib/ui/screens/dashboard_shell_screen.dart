import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

/// Hosts the bottom navigation bar and keeps each tab's navigation stack alive.
///
/// Add a tab by adding a [StatefulShellBranch] in `DashboardRouter` and a
/// matching destination here - the two lists are positional.
class DashboardShellScreen extends StatefulWidget {
  const DashboardShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<DashboardShellScreen> createState() => _DashboardShellScreenState();
}

class _DashboardShellScreenState extends State<DashboardShellScreen> {
  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(NavigationIcons.home),
            selectedIcon: const Icon(NavigationIcons.homeSelected),
            label: strings.nav.home,
          ),
          const NavigationDestination(
            icon: Icon(NavigationIcons.explore),
            selectedIcon: Icon(NavigationIcons.exploreSelected),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: const Icon(NavigationIcons.profile),
            selectedIcon: const Icon(NavigationIcons.profileSelected),
            label: strings.nav.profile,
          ),
        ],
      ),
    );
  }
}
