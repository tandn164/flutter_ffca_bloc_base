import 'api_types.dart';

class OutboxItem {
  OutboxItem({required this.request, required this.enqueuedAt});

  final ApiRequest request;
  final DateTime enqueuedAt;
}

abstract class Outbox {
  Future<void> enqueue(ApiRequest request);
  Future<void> drain(Future<ApiResponse> Function(ApiRequest request) send);
  int get length;

  /// The earliest time at which draining may make progress again.
  ///
  /// In-memory outboxes have no delayed retry. Durable implementations can
  /// expose this value so an app-level coordinator can wake the queue while
  /// the device remains online.
  DateTime? get nextRetryAt => null;
}

class MemoryOutbox implements Outbox {
  final List<OutboxItem> _items = [];
  bool _draining = false;

  @override
  int get length => _items.length;

  @override
  DateTime? get nextRetryAt => null;

  @override
  Future<void> enqueue(ApiRequest request) async {
    _items.add(OutboxItem(request: request, enqueuedAt: DateTime.now()));
  }

  @override
  Future<void> drain(
      Future<ApiResponse> Function(ApiRequest request) send) async {
    if (_draining) return;
    _draining = true;
    try {
      while (_items.isNotEmpty) {
        final item = _items.first;
        try {
          final response = await send(item.request);
          if (response.isOk) {
            _items.removeAt(0);
            continue;
          }
          if (response.statusCode >= 400 &&
              response.statusCode < 500 &&
              response.statusCode != 408 &&
              response.statusCode != 429) {
            _items.removeAt(0);
            continue;
          }
          break;
        } catch (_) {
          break;
        }
      }
    } finally {
      _draining = false;
    }
  }
}
