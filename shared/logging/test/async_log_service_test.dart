import 'package:app_logging/app_logging.dart';
import 'package:test/test.dart';

class _Transport implements LogTransport {
  final List<List<LogEvent>> batches = [];

  @override
  Future<void> send(List<LogEvent> events) async => batches.add(events);
}

void main() {
  test('adds timestamp, redacts fields, and drains serial batches', () async {
    final transport = _Transport();
    final service = AsyncLogService(
      transport: transport,
      batchSize: 2,
      now: () => DateTime.utc(2026),
    );

    service
      ..add(
        const LogEvent(
          kind: 'tap',
          message: 'save',
          fields: {'token': 'secret'},
        ),
      )
      ..add(const LogEvent(kind: 'navigation', message: 'push'))
      ..add(const LogEvent(kind: 'navigation', message: 'pop'));
    await service.flush();

    expect(transport.batches.map((batch) => batch.length), [2, 1]);
    expect(transport.batches.first.first.fields['token'], '***');
    expect(transport.batches.first.first.timestamp, DateTime.utc(2026));
  });
}
