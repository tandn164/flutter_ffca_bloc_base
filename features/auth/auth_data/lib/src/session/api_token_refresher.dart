import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:auth_domain/auth_domain.dart';

import '../api/auth_api.dart';
import 'token_refresher.dart';

class ApiTokenRefresher implements TokenRefresher {
  ApiTokenRefresher(this._transport);

  final ApiTransport _transport;

  @override
  Future<TokenPair?> refresh(String refreshToken) {
    final client = ApiClient(transport: _transport);
    return client.sendDecoded(
      request: ApiRequest(
        method: 'POST',
        path: AuthApi.refreshPath,
        body: {'refreshToken': refreshToken},
      ),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return TokenPair(
          accessToken: map['accessToken'] as String,
          refreshToken: map['refreshToken'] as String? ?? refreshToken,
        );
      },
    ).then((result) {
      return result.fold(
        ok: (pair) => pair,
        err: (failure) {
          if (failure is AuthFailure) throw failure;
          return null;
        },
      );
    });
  }
}
