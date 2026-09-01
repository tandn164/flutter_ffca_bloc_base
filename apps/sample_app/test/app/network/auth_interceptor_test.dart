import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:app_session/app_session.dart';
import 'package:auth_data/auth_data.dart';
import 'package:interceptor/interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

class _Session implements Session {
  SessionStatus status = SessionStatus.authenticated;
  String? accessToken = 'a';
  String? refreshToken = 'r';
  int refreshCalls = 0;
  int signOutCalls = 0;
  bool lastKick = false;
  DebugRefreshMode mode = DebugRefreshMode.ok;

  @override
  SessionState get state => SessionState(status: status);

  @override
  Map<String, String> get authorizationHeaders {
    final token = accessToken;
    if (token == null || token.isEmpty) return const {};
    return {'Authorization': 'Bearer $token'};
  }

  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}

  @override
  Stream<SessionState> watch() => const Stream.empty();

  @override
  Future<void> restore() async {}

  @override
  Future<void> signIn(
      {required String accessToken, required String refreshToken}) async {}

  @override
  Future<void> signOut({bool kick = false}) async {
    signOutCalls++;
    lastKick = kick;
    status = SessionStatus.unauthenticated;
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<bool> refresh() async {
    refreshCalls++;
    switch (mode) {
      case DebugRefreshMode.ok:
        accessToken = 'access-refreshed';
        return true;
      case DebugRefreshMode.network:
        return false;
      case DebugRefreshMode.revoke:
        throw const AuthFailure('revoked');
    }
  }
}

enum DebugRefreshMode { ok, network, revoke }

class _SequenceTransport implements ApiTransport {
  _SequenceTransport(this._responses);
  final List<ApiResponse> _responses;
  int _i = 0;
  final authHeaders = <String?>[];

  @override
  int get httpCount => _i;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    authHeaders.add(request.headers['Authorization']);
    final index = _i.clamp(0, _responses.length - 1);
    _i++;
    return _responses[index];
  }
}

void main() {
  test('handshake paths skip auth attach', () async {
    final session = _Session();
    final transport = _SequenceTransport([
      const ApiResponse(statusCode: 200, body: '{}'),
    ]);
    final client = ApiClient(
      transport: transport,
      interceptors: [
        AuthInterceptor(
          session: session,
          connectivity: FakeConnectivity(),
          handshakePaths: {AuthApi.refreshPath},
        ),
      ],
    );
    final response = await client.send(
      const ApiRequest(method: 'POST', path: AuthApi.refreshPath),
    );
    expect(response.statusCode, 200);
    expect(transport.authHeaders.single, isNull);
  });

  test('401 + successful refresh retries once', () async {
    final session = _Session();
    final transport = _SequenceTransport([
      const ApiResponse(statusCode: 401, body: '{}'),
      const ApiResponse(statusCode: 200, body: '{}'),
    ]);
    final client = ApiClient(
      transport: transport,
      interceptors: [
        AuthInterceptor(
          session: session,
          connectivity: FakeConnectivity(),
        ),
      ],
    );
    final response =
        await client.send(const ApiRequest(method: 'GET', path: '/x'));
    expect(response.statusCode, 200);
    expect(session.refreshCalls, 1);
    expect(transport.authHeaders.length, 2);
    expect(transport.authHeaders.last, 'Bearer access-refreshed');
  });

  test('401 + revoked refresh kicks session', () async {
    final session = _Session()..mode = DebugRefreshMode.revoke;
    final client = ApiClient(
      transport: _SequenceTransport([
        const ApiResponse(statusCode: 401, body: '{}'),
      ]),
      interceptors: [
        AuthInterceptor(
          session: session,
          connectivity: FakeConnectivity(),
        ),
      ],
    );
    final response =
        await client.send(const ApiRequest(method: 'GET', path: '/x'));
    expect(response.statusCode, 401);
    expect(session.signOutCalls, 1);
    expect(session.lastKick, isTrue);
  });
}
