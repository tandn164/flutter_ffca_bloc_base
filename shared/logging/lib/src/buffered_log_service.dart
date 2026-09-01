import 'log_event.dart';
import 'log_queue.dart';

class BufferedLogService implements LogSink, LogReader {
  BufferedLogService(
    this._queue, {
    this.alsoPrint = true,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final LogQueue _queue;
  final bool alsoPrint;
  final DateTime Function() now;

  @override
  void add(LogEvent event) {
    final safe = redactEvent(event.withTimestamp(now()));
    _queue.enqueue(
      kind: safe.kind,
      message: safe.message,
      fields: safe.fields,
      timestamp: safe.timestamp,
    );
    if (alsoPrint) {
      // ignore: avoid_print
      print('[${safe.kind}] ${safe.message} ${safe.fields}');
    }
  }

  @override
  List<LogEvent> get recent => [
        for (final e in _queue.entries)
          LogEvent(
            kind: e.kind,
            message: e.message,
            fields: e.fields,
            timestamp: e.timestamp,
          ),
      ];
}
