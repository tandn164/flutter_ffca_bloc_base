import 'dart:convert';

import '../utils/widget_util.dart';
import 'error_code.dart';
import '../base/base_response.dart';

class ServerException implements Exception {
  final String message;
  final String? errorCode;

  const ServerException({required this.message, required this.errorCode});

  factory ServerException.fromObject(Object? object) {
    final meta = Meta.fromJson(jsonDecode(object as String)["meta"]);
    String msg = meta.msg ?? meta.message ?? l10n.unknownError;
    if (msg.length > 150) {
      msg = msg.substring(0, 150);
    }
    if (meta.errorCode != null) {
      final errorCode = ErrorCode.fromValue(meta.errorCode!);
      msg = errorCode.errorMessage;
    }
    return ServerException(
        message: msg,
        errorCode: meta.errorCode);
  }
}

class CacheException implements Exception {}
