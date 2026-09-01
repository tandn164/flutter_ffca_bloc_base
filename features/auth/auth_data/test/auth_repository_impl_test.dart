import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';

class _LoginTransport implements ApiTransport {
  @override
  int get httpCount => 1;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    expect(request.path, AuthApi.loginPath);
    expect(request.method, 'POST');
    return const ApiResponse(
      statusCode: 200,
      body: '{"accessToken":"a","refreshToken":"r"}',
    );
  }
}

void main() {
  test('AuthRepositoryImpl login goes through AuthApi path once', () async {
    final client = ApiClient(transport: _LoginTransport());
    final chopper = ChopperClient(
      baseUrl: Uri.parse('http://local'),
      client: ApiHttpClient(client),
      converter: const JsonConverter(),
      errorConverter: const JsonConverter(),
      services: [AuthApi.create()],
    );
    try {
      final repo = AuthRepositoryImpl(chopper.getService<AuthApi>());
      final result = await repo.login(email: 'a@b.c', password: 'x');
      expect(result, isA<Ok<TokenPair>>());
      expect(result.valueOrNull?.accessToken, 'a');
    } finally {
      chopper.dispose();
    }
  });
}
