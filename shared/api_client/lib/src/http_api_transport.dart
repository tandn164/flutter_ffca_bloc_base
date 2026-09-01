import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_types.dart';

/// Real HTTP adapter. Bootstrap picks this when [AppConfig.apiBaseUrl] is set.
class HttpApiTransport implements ApiTransport {
  HttpApiTransport({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  int _httpCount = 0;

  @override
  int get httpCount => _httpCount;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    _httpCount++;
    final uri = Uri.parse('$baseUrl${request.path}').replace(
      queryParameters: request.query.isEmpty ? null : request.query,
    );
    final headers = Map<String, String>.from(request.headers);
    String? body;
    if (request.body != null) {
      body = request.body is String
          ? request.body as String
          : jsonEncode(request.body);
      headers.putIfAbsent('content-type', () => 'application/json');
    }
    final req = http.Request(request.method, uri)..headers.addAll(headers);
    if (body != null) req.body = body;
    final response = await _client.send(req);
    final responseBody = await response.stream.bytesToString();
    return ApiResponse(
      statusCode: response.statusCode,
      body: responseBody,
      headers: response.headers,
    );
  }
}
