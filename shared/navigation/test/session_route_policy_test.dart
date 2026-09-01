import 'package:app_navigation/app_navigation.dart';
import 'package:app_session/app_session.dart';
import 'package:flutter_test/flutter_test.dart';

const policy = SessionRoutePolicy(
  guestAllowed: true,
  splashLocation: '/splash',
  signInLocation: '/login',
  homeLocation: '/home',
  publicPrefixes: {'/login'},
  protectedPrefixes: {'/checkout'},
  authOnlyPrefixes: {'/login'},
);

void main() {
  test('unknown session redirects through splash', () {
    expect(
      resolveSessionRedirect(
        status: SessionStatus.unknown,
        path: '/checkout',
        fullPath: '/checkout',
        from: null,
        policy: policy,
      ),
      '/splash?from=%2Fcheckout',
    );
  });

  test('guest is redirected from protected route to sign in', () {
    expect(
      resolveSessionRedirect(
        status: SessionStatus.guest,
        path: '/checkout',
        fullPath: '/checkout',
        from: null,
        policy: policy,
      ),
      '/login?from=%2Fcheckout',
    );
  });

  test('payload mapper encodes query values', () {
    expect(
      locationFromPayload({
        'path': '/orders/1',
        'query': {'tab': 'pay now'},
      }),
      '/orders/1?tab=pay+now',
    );
  });
}
