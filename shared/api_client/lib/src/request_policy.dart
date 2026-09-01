enum ReadStrategy {
  cacheFirst,
  staleWhileRevalidate,
  networkFirst,
  networkOnly,
}

class RequestPolicy {
  const RequestPolicy({
    this.read = ReadStrategy.networkOnly,
    this.ttl = const Duration(minutes: 5),
    this.retryOnReconnect = false,
    this.idempotencyKey,
  });

  final ReadStrategy read;
  final Duration ttl;
  final bool retryOnReconnect;
  final String? idempotencyKey;

  bool get isWriteRetryable => retryOnReconnect && idempotencyKey != null;
}
