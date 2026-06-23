import 'dart:convert';

import 'api_failure.dart';
import 'api_result.dart';

typedef JsonDecoder<T> = T Function(Map<String, dynamic> json);

/// Parses API JSON bodies without crashing on malformed payloads.
class SafeResponseParser {
  const SafeResponseParser();

  ApiResult<T> parseObject<T>(
    Object? body, {
    required JsonDecoder<T> decode,
  }) {
    try {
      final map = _asMap(body);
      if (map == null) {
        return ApiError(
          ApiFailure.decodeError(
            message: 'Expected JSON object, got ${body.runtimeType}',
            rawBody: body,
          ),
        );
      }
      return ApiSuccess(decode(map));
    } on ApiFailure catch (failure) {
      return ApiError(failure);
    } catch (error, stackTrace) {
      return ApiError(
        ApiFailure.decodeError(
          message: error.toString(),
          rawBody: body,
          cause: stackTrace,
        ),
      );
    }
  }

  ApiResult<T> parseEnvelope<T>(
    Object? body, {
    required JsonDecoder<T> decodeData,
    String dataKey = 'data',
  }) {
    return parseObject(body, decode: (json) {
      final data = json[dataKey];
      if (data is! Map<String, dynamic>) {
        throw ApiFailure.decodeError(
          message: 'Missing or invalid "$dataKey" field',
          rawBody: body,
        );
      }
      return decodeData(data);
    });
  }

  Map<String, dynamic>? _asMap(Object? body) {
    if (body == null) return null;
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is String) {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return null;
  }
}
