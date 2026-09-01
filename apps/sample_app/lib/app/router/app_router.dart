import 'package:app_navigation/app_navigation.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_session/app_session.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../di.dart';
import '../features/sample_features.dart';
import '../splash/splash_page.dart';
import 'app_shell.dart';

GoRouter createRouter({
  Session? session,
  SessionRoutePolicy? policy,
  LogSink? logSink,
}) {
  final auth = session ?? sl<Session>();
  final routes = policy ??
      SessionRoutePolicy(
        guestAllowed: sl<AppConfig>().guestAllowed,
        splashLocation: '/splash',
        signInLocation: '/login',
        homeLocation: '/home',
        publicPrefixes: const {
          '/login',
          '/signup',
          '/forgot',
          '/onboarding',
        },
        protectedPrefixes: const {'/checkout'},
        authOnlyPrefixes: const {'/login', '/signup', '/forgot'},
      );
  final sink = logSink ?? (sl.isRegistered<LogSink>() ? sl<LogSink>() : null);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    observers: [
      if (sink != null) LogNavObserver(sink),
    ],
    redirect: (context, state) {
      final fullPath = state.uri.hasQuery
          ? '${state.uri.path}?${state.uri.query}'
          : state.uri.path;
      return resolveSessionRedirect(
        status: auth.state.status,
        path: state.uri.path,
        fullPath: fullPath,
        from: state.uri.queryParameters['from'],
        policy: routes,
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) =>
            SplashPage(onRestore: () => sl<Session>().restore()),
      ),
      ...createDemoPublicFeatureRoutes(sl),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: createDemoShellBranches(sl),
      ),
    ],
  );
}
