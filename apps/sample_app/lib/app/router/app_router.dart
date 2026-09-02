import 'package:app_navigation/app_navigation.dart';
import 'package:app_logging/app_logging.dart';
import 'package:go_router/go_router.dart';

import '../di.dart';
import '../features/sample_features.dart';
import 'app_shell.dart';

GoRouter createRouter({LogSink? logSink}) {
  final sink = logSink ?? (sl.isRegistered<LogSink>() ? sl<LogSink>() : null);

  return GoRouter(
    initialLocation: '/home',
    observers: [
      if (sink != null) LogNavObserver(sink),
    ],
    routes: [
      ...createSamplePublicFeatureRoutes(sl),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: createSampleShellBranches(sl),
      ),
    ],
  );
}
