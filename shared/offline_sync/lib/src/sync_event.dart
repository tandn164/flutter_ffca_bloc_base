enum SyncEventType { queued, sent, retryScheduled, permanentlyFailed }

class SyncEvent {
  const SyncEvent({
    required this.type,
    required this.operationId,
    required this.path,
    this.attempt = 0,
    this.message,
  });

  final SyncEventType type;
  final String operationId;
  final String path;
  final int attempt;
  final String? message;
}
