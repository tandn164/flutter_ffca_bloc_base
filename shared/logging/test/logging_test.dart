import 'package:app_logging/app_logging.dart';
import 'package:test/test.dart';

void main() {
  test('queue drops oldest after max', () {
    final queue = LogQueue(max: 500);
    for (var i = 0; i < 1000; i++) {
      queue.enqueue(kind: 't', message: '$i');
    }
    expect(queue.entries.length, 500);
    expect(queue.entries.first.message, '500');
    expect(queue.entries.last.message, '999');
  });

  test('RecordingLogSink caps at 500', () {
    final sink = RecordingLogSink();
    for (var i = 0; i < 1000; i++) {
      sink.add(LogEvent(kind: 't', message: '$i'));
    }
    expect(sink.events.length, 500);
    expect(sink.events.first.message, '500');
    expect(sink.events.last.message, '999');
  });

  test('redact hides Authorization and password', () {
    final event = redactEvent(
      const LogEvent(
        kind: 'http.request',
        message: 'GET /x',
        fields: {
          'Authorization': 'Bearer secret',
          'password': 'hunter2',
          'Accept': 'application/json',
        },
      ),
    );
    expect(event.fields['Authorization'], '***');
    expect(event.fields['password'], '***');
    expect(event.fields['Accept'], 'application/json');
  });
}
