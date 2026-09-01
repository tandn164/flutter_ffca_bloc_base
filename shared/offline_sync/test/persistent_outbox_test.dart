import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:local_storage/local_storage.dart';
import 'package:offline_sync/offline_sync.dart';
import 'package:test/test.dart';

const request = ApiRequest(
  method: 'POST',
  path: '/tasks',
  body: {'title': 'offline'},
  policy: RequestPolicy(
    retryOnReconnect: true,
    idempotencyKey: 'operation-1',
  ),
);

void main() {
  test('rehydrates and sends a durable operation', () async {
    final store = MemoryKeyValueStore();
    final first = PersistentOutbox(store: store);
    await first.enqueue(request);

    final restored = PersistentOutbox(store: store);
    await restored.initialize();
    expect(restored.length, 1);

    ApiRequest? sent;
    await restored.drain((value) async {
      sent = value;
      return const ApiResponse(statusCode: 200, body: '{}');
    });

    expect(sent?.policy.idempotencyKey, 'operation-1');
    expect(restored.length, 0);
  });

  test('does not queue a write without an idempotency key', () async {
    final outbox = PersistentOutbox(store: MemoryKeyValueStore());

    await expectLater(
      outbox.enqueue(
        const ApiRequest(
          method: 'POST',
          path: '/payment',
          policy: RequestPolicy(retryOnReconnect: true),
        ),
      ),
      throwsArgumentError,
    );
  });

  test('moves permanent 4xx failures to dead letters', () async {
    final outbox = PersistentOutbox(store: MemoryKeyValueStore());
    await outbox.enqueue(request);

    await outbox.drain(
      (_) async => const ApiResponse(statusCode: 422, body: '{}'),
    );

    expect(outbox.length, 0);
    expect(outbox.deadLetterCount, 1);
  });

  test('coordinator retries after backoff while connectivity stays online',
      () async {
    final connectivity = FakeConnectivity();
    final sent = Completer<void>();
    final outbox = PersistentOutbox(
      store: MemoryKeyValueStore(),
      baseDelay: const Duration(milliseconds: 5),
      onEvent: (event) {
        if (event.type == SyncEventType.sent) sent.complete();
      },
    );
    await outbox.enqueue(request);
    var attempts = 0;
    final coordinator = SyncCoordinator(
      connectivity: connectivity,
      outbox: outbox,
      send: (_) async {
        attempts++;
        return ApiResponse(
          statusCode: attempts == 1 ? 503 : 200,
          body: '{}',
        );
      },
    );

    await coordinator.start();
    await sent.future.timeout(const Duration(seconds: 1));

    expect(attempts, 2);
    expect(outbox.length, 0);
    coordinator.dispose();
  });
}
