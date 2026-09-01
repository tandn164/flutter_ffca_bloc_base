import 'dart:async';

import 'log_event.dart';

abstract class LogTransport {
  Future<void> send(List<LogEvent> events);
}

abstract class LogPersistence {
  Future<List<LogEvent>> load();
  Future<void> save(List<LogEvent> events);
}

class MemoryLogPersistence implements LogPersistence {
  List<LogEvent> events = [];

  @override
  Future<List<LogEvent>> load() async => List.of(events);

  @override
  Future<void> save(List<LogEvent> events) async {
    this.events = List.of(events);
  }
}

class CallbackLogPersistence implements LogPersistence {
  const CallbackLogPersistence(
      {required this.loadLogs, required this.saveLogs});

  final Future<List<LogEvent>> Function() loadLogs;
  final Future<void> Function(List<LogEvent> events) saveLogs;

  @override
  Future<List<LogEvent>> load() => loadLogs();

  @override
  Future<void> save(List<LogEvent> events) => saveLogs(events);
}

/// Non-blocking sink with one serial asynchronous sender.
class AsyncLogService implements LogSink, LogReader {
  AsyncLogService({
    required this.transport,
    this.persistence,
    this.maxQueue = 1000,
    this.batchSize = 25,
    this.retryDelay = const Duration(seconds: 10),
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final LogTransport transport;
  final LogPersistence? persistence;
  final int maxQueue;
  final int batchSize;
  final Duration retryDelay;
  final DateTime Function() now;

  final List<LogEvent> _queue = [];
  bool _sending = false;
  bool _disposed = false;
  Timer? _retryTimer;
  Future<void> _persisting = Future.value();

  Future<void> initialize() async {
    final stored = await persistence?.load();
    if (stored != null) _queue.addAll(stored.take(maxQueue));
    _scheduleDrain();
  }

  @override
  void add(LogEvent event) {
    if (_disposed) return;
    final safe = redactEvent(event.withTimestamp(now()));
    if (_queue.length >= maxQueue) _queue.removeAt(0);
    _queue.add(safe);
    _persist();
    _scheduleDrain();
  }

  @override
  List<LogEvent> get recent => List.unmodifiable(_queue);

  Future<void> flush() async {
    if (_disposed || _sending || _queue.isEmpty) return;
    _sending = true;
    try {
      while (_queue.isNotEmpty) {
        final batch = List<LogEvent>.of(_queue.take(batchSize));
        await transport.send(batch);
        _queue.removeRange(0, batch.length);
        await _persist();
      }
    } catch (_) {
      _retryTimer ??= Timer(retryDelay, () {
        _retryTimer = null;
        _scheduleDrain();
      });
    } finally {
      _sending = false;
    }
  }

  void _scheduleDrain() {
    if (_disposed || _sending || _queue.isEmpty) return;
    scheduleMicrotask(flush);
  }

  Future<void> _persist() {
    final target = persistence;
    if (target == null) return Future.value();
    final snapshot = List<LogEvent>.of(_queue);
    _persisting = _persisting.then((_) => target.save(snapshot));
    return _persisting;
  }

  Future<void> dispose() async {
    _disposed = true;
    _retryTimer?.cancel();
    await _persisting;
  }
}
