import 'package:app_session/app_session.dart';
import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:flutter_test/flutter_test.dart';

class _Refresher implements TokenRefresher {
  _Refresher(this._refresh);
  final Future<TokenPair?> Function(String token) _refresh;
  @override
  Future<TokenPair?> refresh(String refreshToken) => _refresh(refreshToken);
}

void main() {
  test('restore from vault → authenticated; empty vault + guestAllowed → guest', () async {
    final vault = MemoryTokenVault();
    final session = AuthSession(
      guestAllowed: true,
      vault: vault,
      restoreDelay: Duration.zero,
      refresher: _Refresher((_) async => null),
    );
    await session.restore();
    expect(session.state.status, SessionStatus.guest);

    await session.signIn(accessToken: 'a', refreshToken: 'r');
    final again = AuthSession(
      guestAllowed: true,
      vault: vault,
      restoreDelay: Duration.zero,
      refresher: _Refresher((_) async => null),
    );
    await again.restore();
    expect(again.state.status, SessionStatus.authenticated);
    expect(again.debugAccessToken, 'a');
  });

  test('refresh ok persists new access; throw kicks via throw', () async {
    final vault = MemoryTokenVault();
    var revoke = false;
    final session = AuthSession(
      guestAllowed: false,
      vault: vault,
      restoreDelay: Duration.zero,
      refresher: _Refresher((token) async {
        expect(token, 'r');
        if (revoke) throw Exception('revoked');
        return const TokenPair(accessToken: 'new', refreshToken: 'r');
      }),
    );
    await session.signIn(accessToken: 'old', refreshToken: 'r');
    expect(await session.refresh(), isTrue);
    expect(session.debugAccessToken, 'new');
    expect((await vault.read())?.accessToken, 'new');

    revoke = true;
    expect(session.refresh(), throwsA(isA<Exception>()));
  });

  test('MemoryTokenVault round-trips and clears', () async {
    final vault = MemoryTokenVault();
    expect(await vault.read(), isNull);
    await vault.write(accessToken: 'a', refreshToken: 'r');
    final stored = await vault.read();
    expect(stored?.accessToken, 'a');
    expect(stored?.refreshToken, 'r');
    await vault.clear();
    expect(await vault.read(), isNull);
  });
}
