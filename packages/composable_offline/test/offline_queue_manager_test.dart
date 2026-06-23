import 'package:composable_offline/composable_offline.dart';
import 'package:test/test.dart';

void main() {
  group('OfflineQueueManager', () {
    test('enqueue respects max size', () {
      final manager = OfflineQueueManager(
        executor: (_) async {},
        maxQueueSize: 2,
      );

      expect(
        manager.enqueue(
          OfflineRequest(id: '1', method: 'POST', path: '/a'),
        ),
        isTrue,
      );
      expect(
        manager.enqueue(
          OfflineRequest(id: '2', method: 'POST', path: '/b'),
        ),
        isTrue,
      );
      expect(
        manager.enqueue(
          OfflineRequest(id: '3', method: 'POST', path: '/c'),
        ),
        isFalse,
      );
      expect(manager.length, 2);
    });

    test('flush executes queued requests in order', () async {
      final executed = <String>[];
      final manager = OfflineQueueManager(
        executor: (request) async {
          executed.add(request.id);
        },
      );

      manager.enqueue(
        OfflineRequest(id: 'a', method: 'POST', path: '/a'),
      );
      manager.enqueue(
        OfflineRequest(id: 'b', method: 'POST', path: '/b'),
      );

      await manager.flush();

      expect(executed, ['a', 'b']);
      expect(manager.length, 0);
    });
  });
}
