import 'package:api_client/api_client.dart';

import 'log_event.dart';

class ApiLogInterceptor implements ApiInterceptor {
  ApiLogInterceptor(this.sink, {Stopwatch Function()? stopwatch})
      : stopwatch = stopwatch ?? Stopwatch.new;

  final LogSink sink;
  final Stopwatch Function() stopwatch;

  @override
  Future<ApiResponse> intercept(ApiRequest request, ApiHandler next) async {
    final timer = stopwatch()..start();
    sink.add(
      LogEvent(
        kind: 'api.request',
        message: '${request.method} ${request.path}',
        fields: {
          ...redactFields(request.headers),
          if (request.policy.idempotencyKey != null) 'idempotent': 'true',
        },
      ),
    );
    try {
      final response = await next(request);
      timer.stop();
      sink.add(
        LogEvent(
          kind: 'api.response',
          message: '${response.statusCode} ${request.path}',
          fields: {'durationMs': '${timer.elapsedMilliseconds}'},
        ),
      );
      return response;
    } catch (error) {
      timer.stop();
      sink.add(
        LogEvent(
          kind: 'api.failure',
          message: request.path,
          fields: {
            'durationMs': '${timer.elapsedMilliseconds}',
            'errorType': error.runtimeType.toString(),
          },
        ),
      );
      rethrow;
    }
  }
}
