import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:app_session/app_session.dart';

/// Attaches [Session] authorization headers and coordinates single-flight refresh on 401.
class AuthInterceptor implements ApiInterceptor {
  AuthInterceptor({
    required this.session,
    required this.connectivity,
    this.handshakePaths = const {},
  });

  final Session session;
  final ConnectivityHint connectivity;
  final Set<String> handshakePaths;

  Future<bool>? _refreshing;

  @override
  Future<ApiResponse> intercept(ApiRequest request, ApiHandler next) async {
    if (handshakePaths.contains(request.path)) return next(request);

    final response = await next(_attach(request));
    if (response.statusCode != 401 || connectivity.isSureOffline) {
      return response;
    }

    try {
      _refreshing ??= session.refresh().whenComplete(() => _refreshing = null);
      final refreshed = await _refreshing!;
      if (!refreshed) return response;
      return next(_attach(request));
    } on AuthFailure {
      await session.signOut(kick: true);
      return response;
    }
  }

  ApiRequest _attach(ApiRequest request) {
    final authorization = session.authorizationHeaders;
    if (authorization.isEmpty) return request;
    return request.copyWith(
      headers: {...request.headers, ...authorization},
    );
  }
}
