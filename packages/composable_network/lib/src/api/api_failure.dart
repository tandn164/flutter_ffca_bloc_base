import 'package:meta/meta.dart';

enum ApiFailureKind {
  decodeError,
  networkError,
  serverError,
  offline,
  unknown,
}

@immutable
class ApiFailure implements Exception {
  const ApiFailure({
    required this.kind,
    this.message,
    this.statusCode,
    this.rawBody,
    this.cause,
  });

  factory ApiFailure.decodeError({
    String? message,
    Object? rawBody,
    Object? cause,
  }) {
    return ApiFailure(
      kind: ApiFailureKind.decodeError,
      message: message ?? 'Failed to decode response body',
      rawBody: rawBody,
      cause: cause,
    );
  }

  factory ApiFailure.networkError({
    String? message,
    Object? cause,
  }) {
    return ApiFailure(
      kind: ApiFailureKind.networkError,
      message: message ?? 'Network request failed',
      cause: cause,
    );
  }

  factory ApiFailure.offline({String? message}) {
    return ApiFailure(
      kind: ApiFailureKind.offline,
      message: message ?? 'No internet connection',
    );
  }

  final ApiFailureKind kind;
  final String? message;
  final int? statusCode;
  final Object? rawBody;
  final Object? cause;

  @override
  String toString() => 'ApiFailure($kind: $message)';
}
