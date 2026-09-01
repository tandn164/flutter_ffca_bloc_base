import 'package:app_result/app_result.dart';
import 'package:app_session/app_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restore without token + guestAllowed → guest', () async {
    final session =
        StubSession(guestAllowed: true, restoreDelay: Duration.zero);
    expect(session.state.status, SessionStatus.unknown);
    await session.restore();
    expect(session.state.status, SessionStatus.guest);
  });

  test('restore without token + authRequired → unauthenticated', () async {
    final session =
        StubSession(guestAllowed: false, restoreDelay: Duration.zero);
    await session.restore();
    expect(session.state.status, SessionStatus.unauthenticated);
  });

  test('restore with persisted tokens → authenticated', () async {
    final session = StubSession(
      guestAllowed: true,
      restoreDelay: Duration.zero,
      persistedAccessToken: 'a',
      persistedRefreshToken: 'r',
    );
    await session.restore();
    expect(session.state.status, SessionStatus.authenticated);
    expect(session.debugAccessToken, 'a');
  });

  test('signOut without kick stays guest when guestAllowed', () async {
    final session =
        StubSession(guestAllowed: true, restoreDelay: Duration.zero);
    await session.signIn(accessToken: 'a', refreshToken: 'r');
    await session.signOut();
    expect(session.state.status, SessionStatus.guest);
  });

  test('signOut kick → unauthenticated even if guestAllowed', () async {
    final session =
        StubSession(guestAllowed: true, restoreDelay: Duration.zero);
    await session.signIn(accessToken: 'a', refreshToken: 'r');
    await session.signOut(kick: true);
    expect(session.state.status, SessionStatus.unauthenticated);
  });

  test('watch emits current then updates', () async {
    final session = StubSession(restoreDelay: Duration.zero);
    final events = <SessionStatus>[];
    final sub = session.watch().listen((s) => events.add(s.status));
    await pumpEventQueue();
    await session.restore();
    await pumpEventQueue();
    expect(events, [SessionStatus.unknown, SessionStatus.guest]);
    await sub.cancel();
  });

  test('refresh revoke throws AuthFailure; network returns false', () async {
    final session = StubSession(restoreDelay: Duration.zero);
    await session.signIn(accessToken: 'a', refreshToken: 'r');
    session.debugRefresh = DebugRefresh.network;
    expect(await session.refresh(), isFalse);
    session.debugRefresh = DebugRefresh.revoke;
    expect(session.refresh(), throwsA(isA<AuthFailure>()));
  });
}
