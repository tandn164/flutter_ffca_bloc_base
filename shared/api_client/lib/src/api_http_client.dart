import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_types.dart';

/// Chopper/http → existing [ApiClient] (interceptors stay on ApiClient).
class ApiHttpClient extends http.BaseClient {
  ApiHttpClient(this._api);

  final ApiClient _api;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final raw = utf8.decode(await request.finalize().toBytes());
    Object? body;
    if (raw.isNotEmpty) {
      try {
        body = jsonDecode(raw);
      } catch (_) {
        body = raw;
      }
    }
    final uri = request.url;
    final response = await _api.send(
      ApiRequest(
        method: request.method,
        path: uri.path.isEmpty ? '/' : uri.path,
        query: uri.queryParameters,
        headers: Map<String, String>.from(request.headers),
        body: body,
      ),
    );
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(response.body)),
      response.statusCode,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        ...response.headers,
      },
    );
  }
}
