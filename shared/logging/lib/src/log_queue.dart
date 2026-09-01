class QueuedLog {
  const QueuedLog({
    required this.kind,
    required this.message,
    this.fields = const {},
    this.timestamp,
  });

  final String kind;
  final String message;
  final Map<String, String> fields;
  final DateTime? timestamp;
}

class LogQueue {
  LogQueue({this.max = 500});

  final int max;
  final List<QueuedLog> entries = [];

  void enqueue({
    required String kind,
    required String message,
    Map<String, String> fields = const {},
    DateTime? timestamp,
  }) {
    if (entries.length >= max) entries.removeAt(0);
    entries.add(
      QueuedLog(
        kind: kind,
        message: message,
        fields: fields,
        timestamp: timestamp,
      ),
    );
  }
}
