import 'package:app_connectivity/app_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_overlay/app_overlay.dart';

import '../generated/l10n/l10n.dart';
import 'di.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<GoRouter>();
    return MaterialApp.router(
      title: 'Flutter FFCA Base',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      builder: (context, child) {
        return OverlayHost(
          controller: sl(),
          offlineBlockBuilder: (context) => ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 44),
                      const SizedBox(height: 12),
                      const Text('This page requires a connection.'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            sl<MutableConnectivityHint>().setOffline(false),
                        child: const Text('Restore connection'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
