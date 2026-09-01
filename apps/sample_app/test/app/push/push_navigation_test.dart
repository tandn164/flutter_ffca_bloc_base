import 'package:app_navigation/app_navigation.dart';
import 'package:app_session/app_session.dart';
import 'package:sample_app/app/push/demo_push_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('payload path and query become a GoRouter location', () {
    expect(locationFromPayload({'path': '/orders/1'}), '/orders/1');
    expect(
      locationFromPayload({
        'path': '/orders/1',
        'query': {'tab': 'pay'},
      }),
      '/orders/1?tab=pay',
    );
    expect(locationFromPayload({}), isNull);
  });

  test('openDemoPush navigates; silent does not', () {
    String? opened;
    openDemoPush((loc) => opened = loc, {'path': '/home'});
    expect(opened, '/home');

    opened = 'keep';
    openDemoPush((loc) => opened = loc, {
      'path': '/x',
      'silent': true,
    });
    expect(opened, 'keep');
  });

  test('unauth + payload /checkout → login?from= (same policy as deep link)',
      () {
    final location = locationFromPayload({'path': '/checkout'})!;
    expect(
      resolveSessionRedirect(
        status: SessionStatus.unauthenticated,
        path: Uri.parse(location).path,
        fullPath: location,
        from: null,
        policy: const SessionRoutePolicy(
          guestAllowed: true,
          splashLocation: '/splash',
          signInLocation: '/login',
          homeLocation: '/home',
          publicPrefixes: {'/login'},
          protectedPrefixes: {'/checkout'},
          authOnlyPrefixes: {'/login'},
        ),
      ),
      '/login?from=%2Fcheckout',
    );
  });
}
