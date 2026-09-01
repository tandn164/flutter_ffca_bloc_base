import 'package:app_result/app_result.dart';

import 'api_types.dart';
import 'request_policy.dart';
import 'safe_decode.dart';

class ApiClient {
  ApiClient({
    required this.transport,
    List<ApiInterceptor> interceptors = const [],
  }) : interceptors = List.unmodifiable(interceptors);

  final ApiTransport transport;
  final List<ApiInterceptor> interceptors;

  int get httpCount => transport.httpCount;

  Future<ApiResponse> send(ApiRequest request) {
    ApiHandler handler = transport.send;
    for (final interceptor in interceptors.reversed) {
      final next = handler;
      handler = (req) => interceptor.intercept(req, next);
    }
    return handler(request);
  }

  Future<Result<T>> sendDecoded<T>({
    required ApiRequest request,
    required T Function(Object json) decode,
  }) async {
    try {
      final response = await send(request);
      if (!response.isOk) {
        if (response.statusCode == 401) {
          return const Err(AuthFailure());
        }
        if (response.statusCode >= 500) {
          return const Err(ServerFailure());
        }
        return Err(ServerFailure('HTTP ${response.statusCode}'));
      }
      return safeDecode(response.body, decode);
    } on AuthFailure catch (e) {
      return Err(e);
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }
}

extension ApiClientGet on ApiClient {
  Future<Result<T>> getDecoded<T>({
    required String path,
    required T Function(Object json) decode,
    RequestPolicy policy = const RequestPolicy(),
  }) {
    return sendDecoded(
      request: ApiRequest(method: 'GET', path: path, policy: policy),
      decode: decode,
    );
  }
}
