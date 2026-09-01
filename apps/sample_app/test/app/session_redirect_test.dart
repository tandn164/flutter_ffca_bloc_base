import 'package:app_navigation/app_navigation.dart';
import 'package:app_session/app_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const guestApp = SessionRoutePolicy(
    guestAllowed: true,
    splashLocation: '/splash',
    signInLocation: '/login',
    homeLocation: '/home',
    publicPrefixes: {'/login', '/signup', '/forgot'},
    protectedPrefixes: {'/checkout'},
    authOnlyPrefixes: {'/login', '/signup', '/forgot'},
  );
  const authApp = SessionRoutePolicy(
    guestAllowed: false,
    splashLocation: '/splash',
    signInLocation: '/login',
    homeLocation: '/home',
    publicPrefixes: {'/login', '/signup', '/forgot'},
    protectedPrefixes: {'/checkout'},
    authOnlyPrefixes: {'/login', '/signup', '/forgot'},
  );

  String? redirect({
    required SessionStatus status,
    required String path,
    String? from,
    SessionRoutePolicy policy = guestApp,
    String? fullPath,
  }) {
    return resolveSessionRedirect(
      status: status,
      path: path,
      fullPath: fullPath ?? path,
      from: from,
      policy: policy,
    );
  }

  test('unknown always goes to splash', () {
    expect(redirect(status: SessionStatus.unknown, path: '/home'),
        startsWith('/splash'));
    expect(redirect(status: SessionStatus.unknown, path: '/splash'), isNull);
  });

  test('restore guest → home; restore auth + from checkout → checkout', () {
    expect(
      redirect(status: SessionStatus.guest, path: '/splash'),
      '/home',
    );
    expect(
      redirect(
          status: SessionStatus.authenticated,
          path: '/splash',
          from: '/checkout'),
      '/checkout',
    );
  });

  test('guest cannot open authRequired checkout', () {
    expect(
      redirect(status: SessionStatus.guest, path: '/checkout'),
      guestApp.signInFrom('/checkout'),
    );
  });

  test('authenticated leaves login to home or from', () {
    expect(
      redirect(status: SessionStatus.authenticated, path: '/login'),
      '/home',
    );
    expect(
      redirect(
          status: SessionStatus.authenticated,
          path: '/login',
          from: '/checkout'),
      '/checkout',
    );
  });

  test('authRequired app keeps guest off home', () {
    expect(
      redirect(status: SessionStatus.guest, path: '/home', policy: authApp),
      authApp.signInFrom('/home'),
    );
  });
}
