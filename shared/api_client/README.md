# API Client

Generic HTTP and data-access infrastructure. The package contains no business
endpoint and does not depend on feature packages.

## Main APIs

- `ApiClient` sends requests through a pluggable `ApiTransport` and interceptors.
- `DataGateway` applies read caching, safe decoding, invalidation, and offline writes.
- `RequestPolicy` selects a read strategy and explicitly opts a write into retry.
- `CacheStore` and `Outbox` are replaceable persistence boundaries.

`ConnectivityHint` is re-exported for compatibility, but its implementation now
lives in the standalone `app_connectivity` package.

## Safe decoding

```dart
final result = await gateway.read(
  request: const ApiRequest(method: 'GET', path: '/tasks'),
  decode: (json) => TaskDto.fromJson(json as Map<String, dynamic>),
);
```

Malformed JSON and mapping exceptions become `DecodeFailure`; they do not escape
into a BLoC or crash the UI. Repositories should map DTOs to domain entities after
the gateway succeeds.

## Read strategies

```dart
const RequestPolicy(read: ReadStrategy.cacheFirst, ttl: Duration(minutes: 5));
const RequestPolicy(read: ReadStrategy.networkFirst);
const RequestPolicy(read: ReadStrategy.staleWhileRevalidate);
const RequestPolicy(read: ReadStrategy.networkOnly);
```

`MemoryCacheStore` is suitable for tests and short-lived data. Provide a database
adapter when cached data must survive process restarts.

## Offline writes

```dart
ApiRequest(
  method: 'POST',
  path: '/tasks',
  body: {'title': 'Offline task'},
  policy: const RequestPolicy(
    retryOnReconnect: true,
    idempotencyKey: 'stable-operation-id',
  ),
);
```

Use `PersistentOutbox` from `offline_sync` in production composition. Delivery is
at least once: the server must deduplicate the idempotency key. Do not retry
irreversible operations unless their server contract is idempotent.

## Interceptors

Cross-cutting behavior is composed by the app:

- `interceptor` adds auth headers and refresh handling on 401.
- `app_logging` records redacted request/response metadata.
- Feature data packages own their endpoint declarations.

## Testing

```bash
dart test shared/api_client
```
