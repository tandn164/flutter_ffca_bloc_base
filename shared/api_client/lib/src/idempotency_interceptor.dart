import 'api_types.dart';

class IdempotencyInterceptor implements ApiInterceptor {
  @override
  Future<ApiResponse> intercept(ApiRequest request, ApiHandler next) {
    final key = request.policy.idempotencyKey;
    if (key == null || key.isEmpty) return next(request);
    final headers = Map<String, String>.from(request.headers);
    headers.putIfAbsent('Idempotency-Key', () => key);
    return next(request.copyWith(headers: headers));
  }
}
