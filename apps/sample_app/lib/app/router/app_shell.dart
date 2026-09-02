import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    const destinations = [
      AdaptiveDestination(
        icon: Icon(Icons.check_box_outlined),
        label: 'Capabilities',
      ),
      AdaptiveDestination(
        icon: Icon(Icons.view_list_outlined),
        label: 'Sample list',
      ),
    ];

    return AdaptiveNavigationShell(
      destinations: destinations,
      selectedIndex: navigationShell.currentIndex,
      onSelected: navigationShell.goBranch,
      body: navigationShell,
    );
  }
}
