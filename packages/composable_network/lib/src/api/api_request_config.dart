import 'package:meta/meta.dart';

/// Per-request metadata for retry, cache, and idempotency policies.
@immutable
class ApiRequestConfig {
  const ApiRequestConfig({
    this.retryOnReconnect = false,
    this.cacheable = false,
    this.cacheTtl = Duration.zero,
    this.idempotent = false,
  });

  final bool retryOnReconnect;
  final bool cacheable;
  final Duration cacheTtl;
  final bool idempotent;

  static const ApiRequestConfig defaults = ApiRequestConfig();
}
