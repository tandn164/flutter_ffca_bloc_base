import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../generated/l10n/l10n.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final destinations = [
      AdaptiveDestination(
        icon: const Icon(Icons.check_box_outlined),
        label: s.home,
      ),
      AdaptiveDestination(
        icon: const Icon(Icons.person_outline),
        label: s.profile,
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
