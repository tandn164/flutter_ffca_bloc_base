# Offline Sync

A durable outbox for JSON API writes that are safe to retry. It handles writes
queued before a request and writes interrupted by a transport failure.

## Safety model

Delivery is **at least once**. A server-side idempotency contract is required to
avoid duplicate mutations. The package refuses to queue requests without both
`retryOnReconnect: true` and an `idempotencyKey`.

Never enable automatic retry for payments or irreversible operations unless the
server guarantees idempotency for the supplied key.

## Installation

```yaml
dependencies:
  offline_sync:
    path: ../../shared/offline_sync
  local_storage:
    path: ../../shared/local_storage/core
```

## App composition

```dart
final outbox = PersistentOutbox(
  store: SharedPreferencesKeyValueStore(preferences),
  onEvent: logSyncEvent,
);
await outbox.initialize();

final sync = SyncCoordinator(
  connectivity: connectivity,
  outbox: outbox,
  send: apiClient.send,
);
await sync.start();
```

Inject the same outbox into `DataGateway`.

## Queue an API write

```dart
final request = ApiRequest(
  method: 'POST',
  path: '/tasks',
  body: {'title': title},
  policy: RequestPolicy(
    retryOnReconnect: true,
    idempotencyKey: operationId,
  ),
);

await gateway.write(request: request, decode: TaskDto.fromJson);
```

If the device is already offline or the connection drops during the request,
`DataGateway` persists it before returning `NetworkFailure`.

## Retry behavior

- Successful 2xx responses remove the operation.
- 408, 429, 5xx, and transport failures use exponential backoff.
- `SyncCoordinator` wakes the queue when backoff expires, even if connectivity
  stays online throughout the retry window.
- Other 4xx responses move the operation to the dead-letter queue.
- Calls are drained serially to preserve ordering.
- Concurrent drains are coalesced.

Use `retryDeadLetters()` only after user action or a known server-side fix.

## Read caching

Read strategies remain in `api_client` through `DataGateway`: cache-first,
network-first, stale-while-revalidate, and network-only. A database-backed cache
adapter should be used for large datasets; `MemoryCacheStore` is for demos and
tests.

## Limitations

The bundled SharedPreferences adapter is intended for modest queues. Use a
database-backed `KeyValueStore` for high-volume synchronization. OS background
execution after an app is suspended requires a platform scheduler and is not
guaranteed by this package.

## Testing

```bash
dart test shared/offline_sync
```
