import 'dart:convert';

import 'package:api_client/api_client.dart';

Map<String, dynamic> requestBody(Object? body) {
  if (body is Map<String, dynamic>) return body;
  if (body is Map) return Map<String, dynamic>.from(body);
  if (body is String && body.isNotEmpty) {
    final decoded = jsonDecode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return {};
}

int intQuery(ApiRequest request, String key, int fallback) {
  return int.tryParse(request.query[key] ?? '') ?? fallback;
}

ApiResponse jsonResponse(int statusCode, Object data) {
  return ApiResponse(statusCode: statusCode, body: jsonEncode(data));
}
