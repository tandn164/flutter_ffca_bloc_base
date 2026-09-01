import 'package:api_client/api_client.dart';

import 'fake_api_handler.dart';

export 'demo_api.dart';

/// In-process demo backend. Bootstrap uses this when the API base URL is empty.
class FakeApiTransport implements ApiTransport {
  FakeApiTransport({
    required this.connectivity,
    required List<FakeApiHandler> handlers,
    this.latency = Duration.zero,
  }) : _handlers = List.unmodifiable(handlers);

  final ConnectivityHint connectivity;
  final Duration latency;
  final List<FakeApiHandler> _handlers;
  int _httpCount = 0;

  @override
  int get httpCount => _httpCount;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    if (connectivity.isSureOffline && request.method.toUpperCase() != 'GET') {
      throw const _Offline();
    }

    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }

    _httpCount++;
    for (final handler in _handlers) {
      final response = handler.handle(request);
      if (response != null) return response;
    }

    return const ApiResponse(
      statusCode: 404,
      body: '{"error":"not found"}',
    );
  }
}

class _Offline implements Exception {
  const _Offline();
}
