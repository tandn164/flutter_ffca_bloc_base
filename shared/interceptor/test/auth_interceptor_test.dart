import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:app_session/app_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interceptor/interceptor.dart';

class _Session extends ChangeNotifier implements Session {
  int refreshCount = 0;
  int kickCount = 0;
  bool refreshResult = true;
  bool revoked = false;

  @override
  Map<String, String> get authorizationHeaders => {'authorization': 'Bearer t'};
  @override
  SessionState get state =>
      const SessionState(status: SessionStatus.authenticated);
  @override
  Future<bool> refresh() async {
    refreshCount++;
    if (revoked) throw const AuthFailure();
    return refreshResult;
  }

  @override
  Future<void> signOut({bool kick = false}) async {
    if (kick) kickCount++;
  }

  @override
  Future<void> restore() async {}
  @override
  Future<void> signIn(
      {required String accessToken, required String refreshToken}) async {}
  @override
  Stream<SessionState> watch() => const Stream.empty();
}

void main() {
  test('401 refreshes and retries once', () async {
    final session = _Session();
    var calls = 0;
    final interceptor = AuthInterceptor(
      session: session,
      connectivity: FakeConnectivity(),
    );

    final response = await interceptor.intercept(
      const ApiRequest(method: 'GET', path: '/me'),
      (request) async => ApiResponse(
        statusCode: calls++ == 0 ? 401 : 200,
        body: '{}',
      ),
    );

    expect(response.statusCode, 200);
    expect(session.refreshCount, 1);
    expect(calls, 2);
  });

  test('revoked refresh token kicks the session', () async {
    final session = _Session()..revoked = true;
    final interceptor = AuthInterceptor(
      session: session,
      connectivity: FakeConnectivity(),
    );

    await interceptor.intercept(
      const ApiRequest(method: 'GET', path: '/me'),
      (_) async => const ApiResponse(statusCode: 401, body: '{}'),
    );

    expect(session.kickCount, 1);
  });
}
