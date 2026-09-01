import 'package:app_session/app_session.dart';

enum RouteAuth { public, guestAllowed, authRequired }

class SessionRoutePolicy {
  const SessionRoutePolicy({
    required this.guestAllowed,
    required this.splashLocation,
    required this.signInLocation,
    required this.homeLocation,
    this.publicPrefixes = const {},
    this.protectedPrefixes = const {},
    this.authOnlyPrefixes = const {},
  });

  final bool guestAllowed;
  final String splashLocation;
  final String signInLocation;
  final String homeLocation;
  final Set<String> publicPrefixes;
  final Set<String> protectedPrefixes;
  final Set<String> authOnlyPrefixes;

  RouteAuth authFor(String path) {
    if (path == splashLocation || _matches(path, publicPrefixes)) {
      return RouteAuth.public;
    }
    if (_matches(path, protectedPrefixes)) return RouteAuth.authRequired;
    return guestAllowed ? RouteAuth.guestAllowed : RouteAuth.authRequired;
  }

  bool isAuthOnly(String path) => _matches(path, authOnlyPrefixes);
  bool needsAuth(String path) => authFor(path) == RouteAuth.authRequired;

  String signInFrom(String location) =>
      '$signInLocation?from=${Uri.encodeComponent(location)}';
  String splashFrom(String location) =>
      '$splashLocation?from=${Uri.encodeComponent(location)}';

  static bool _matches(String path, Set<String> prefixes) {
    for (final prefix in prefixes) {
      if (path == prefix || path.startsWith('$prefix/')) return true;
    }
    return false;
  }
}

String? resolveSessionRedirect({
  required SessionStatus status,
  required String path,
  required String fullPath,
  required String? from,
  required SessionRoutePolicy policy,
}) {
  if (status == SessionStatus.unknown) {
    return path == policy.splashLocation ? null : policy.splashFrom(fullPath);
  }

  if (path == policy.splashLocation) {
    final intended =
        from != null && from.isNotEmpty ? from : policy.homeLocation;
    final uri = Uri.parse(intended);
    if (uri.path == policy.splashLocation) return policy.homeLocation;
    final nested = resolveSessionRedirect(
      status: status,
      path: uri.path,
      fullPath: intended,
      from: uri.queryParameters['from'],
      policy: policy,
    );
    return nested ?? intended;
  }

  if (status == SessionStatus.authenticated && policy.isAuthOnly(path)) {
    return from != null && from.isNotEmpty ? from : policy.homeLocation;
  }

  if (policy.needsAuth(path) && status != SessionStatus.authenticated) {
    return policy.signInFrom(fullPath);
  }

  return null;
}
