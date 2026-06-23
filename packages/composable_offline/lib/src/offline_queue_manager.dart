import 'package:meta/meta.dart';

@immutable
class OfflineRequest {
  OfflineRequest({
    required this.id,
    required this.method,
    required this.path,
    this.headers = const {},
    this.body,
    this.idempotent = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String method;
  final String path;
  final Map<String, String> headers;
  final Object? body;
  final bool idempotent;
  final DateTime createdAt;
}

typedef OfflineRequestExecutor = Future<void> Function(OfflineRequest request);

/// Persists failed requests and flushes when connectivity returns.
class OfflineQueueManager {
  OfflineQueueManager({
    required OfflineRequestExecutor executor,
    this.maxQueueSize = 100,
  }) : _executor = executor;

  final OfflineRequestExecutor _executor;
  final int maxQueueSize;
  final List<OfflineRequest> _queue = [];

  List<OfflineRequest> get pending => List.unmodifiable(_queue);

  int get length => _queue.length;

  bool enqueue(OfflineRequest request) {
    if (_queue.length >= maxQueueSize) return false;
    _queue.removeWhere((item) => item.id == request.id);
    _queue.add(request);
    return true;
  }

  Future<void> flush() async {
    if (_queue.isEmpty) return;

    final snapshot = List<OfflineRequest>.from(_queue);
    for (final request in snapshot) {
      await _executor(request);
      _queue.removeWhere((item) => item.id == request.id);
    }
  }

  void clear() => _queue.clear();
}
