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
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
