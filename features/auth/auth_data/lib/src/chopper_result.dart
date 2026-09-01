import 'dart:convert';

import 'package:app_result/app_result.dart';
import 'package:chopper/chopper.dart';
import 'package:api_client/api_client.dart';

Result<T> resultFromChopper<T>(
  Response<dynamic> response,
  T Function(Object json) decode,
) {
  if (response.statusCode == 401) {
    return Err(AuthFailure(_message(response) ?? 'Authentication failed'));
  }
  if (!response.isSuccessful) {
    final message = _message(response) ?? 'HTTP ${response.statusCode}';
    if (response.statusCode >= 500) return Err(ServerFailure(message));
    return Err(ServerFailure(message));
  }
  return safeDecode(response.bodyString, decode);
}

String? _message(Response<dynamic> response) {
  try {
    final decoded = jsonDecode(response.bodyString);
    if (decoded is Map && decoded['error'] is String) {
      return decoded['error'] as String;
    }
  } catch (_) {}
  return null;
}
