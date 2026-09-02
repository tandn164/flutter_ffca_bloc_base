import 'package:app_connectivity/app_connectivity.dart';
import 'package:app_logging/app_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../showcase/showcase_page.dart';

List<RouteBase> createShowcaseRoutes() {
  return [
    GoRoute(
      path: '/offline-block',
      builder: (_, __) => const OfflineBlockSamplePage(),
    ),
  ];
}

StatefulShellBranch createShowcaseBranch(GetIt sl) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, _) => ShowcasePage(
          connectivity: sl<MutableConnectivityHint>(),
          logSink: sl<LogSink>(),
          logReader: sl<LogReader>(),
          openLocation: context.go,
        ),
      ),
    ],
  );
}
