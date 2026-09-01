import 'request_policy.dart';

class ApiRequest {
  const ApiRequest({
    required this.method,
    required this.path,
    this.query = const {},
    this.headers = const {},
    this.body,
    this.policy = const RequestPolicy(),
  });

  final String method;
  final String path;
  final Map<String, String> query;
  final Map<String, String> headers;
  final Object? body;
  final RequestPolicy policy;

  bool get isGet => method.toUpperCase() == 'GET';

  ApiRequest copyWith({
    String? method,
    String? path,
    Map<String, String>? query,
    Map<String, String>? headers,
    Object? body,
    RequestPolicy? policy,
  }) {
    return ApiRequest(
      method: method ?? this.method,
      path: path ?? this.path,
      query: query ?? this.query,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      policy: policy ?? this.policy,
    );
  }
}

class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;

  bool get isOk => statusCode >= 200 && statusCode < 300;
}

typedef ApiHandler = Future<ApiResponse> Function(ApiRequest request);

abstract class ApiInterceptor {
  Future<ApiResponse> intercept(ApiRequest request, ApiHandler next);
}

abstract class ApiTransport {
  Future<ApiResponse> send(ApiRequest request);
  int get httpCount => 0;
}
