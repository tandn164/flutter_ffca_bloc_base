abstract class LogSink {
  /// Must not await I/O. Drop if the queue is full.
  void add(LogEvent event);
}

abstract class LogReader {
  List<LogEvent> get recent;
}

class LogEvent {
  const LogEvent({
    required this.kind,
    required this.message,
    this.fields = const {},
    this.timestamp,
  });

  final String kind;
  final String message;
  final Map<String, String> fields;
  final DateTime? timestamp;

  LogEvent withTimestamp(DateTime value) => LogEvent(
        kind: kind,
        message: message,
        fields: fields,
        timestamp: timestamp ?? value,
      );

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'message': message,
        'fields': fields,
        'timestamp': timestamp?.toUtc().toIso8601String(),
      };

  factory LogEvent.fromJson(Map<String, dynamic> json) {
    return LogEvent(
      kind: json['kind'] as String,
      message: json['message'] as String,
      fields: Map<String, String>.from(json['fields'] as Map? ?? const {}),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );
  }
}

const kLogRedactKeys = {
  'authorization',
  'password',
  'token',
  'refresh',
  'cookie',
  'set-cookie',
  'idempotency-key',
};

String redactIfNeeded(String key, String value) {
  return kLogRedactKeys.contains(key.toLowerCase()) ? '***' : value;
}

Map<String, String> redactFields(Map<String, String> fields) {
  return {
    for (final e in fields.entries) e.key: redactIfNeeded(e.key, e.value),
  };
}

LogEvent redactEvent(LogEvent event) {
  return LogEvent(
    kind: event.kind,
    message: event.message,
    fields: redactFields(event.fields),
    timestamp: event.timestamp,
  );
}

class PrintLogSink implements LogSink {
  @override
  void add(LogEvent event) {
    final safe = redactEvent(event);
    // ignore: avoid_print
    print('[${safe.kind}] ${safe.message} ${safe.fields}');
  }
}

class RecordingLogSink implements LogSink {
  final List<LogEvent> events = [];
  static const max = 500;

  @override
  void add(LogEvent event) {
    if (events.length >= max) events.removeAt(0);
    events.add(event);
  }
}
