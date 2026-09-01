# App Logging

Structured, redacted application logs with bounded queues and serial background
delivery. Logging calls never await network I/O on the UI path.

## Installation

```yaml
dependencies:
  app_logging:
    path: ../../shared/logging
```

## Events

```dart
log.add(
  const LogEvent(
    kind: 'user.action',
    message: 'checkout.submit',
    fields: {'source': 'cart'},
  ),
);
```

The service adds a timestamp when the event has none. Known secret fields such
as authorization, password, token, refresh token, cookies, and idempotency keys
are redacted before storage or delivery.

## Background delivery

```dart
final logs = AsyncLogService(
  transport: MyLogApiTransport(),
  persistence: MyLogPersistence(),
  batchSize: 25,
);
await logs.initialize();
```

`LogSink.add` only appends to memory and schedules asynchronous work. Batches are
sent one at a time. Failed batches stay queued and retry later.

Use `CallbackLogPersistence` to adapt encrypted storage or a local database.
`MemoryLogPersistence` is intended for tests.

## API and navigation logs

Add `ApiLogInterceptor(logs)` to `ApiClient`. It records status, duration, and
failure type without serializing request/response bodies. Use `LogNavObserver`
from `app_navigation` for route events.

## Lifecycle and limitations

Call `flush()` when the app enters the background. Async Dart work does not block
the UI, but no Dart package can guarantee execution after the operating system
terminates the app. Native background scheduling is a separate integration.

## Testing

```bash
dart test shared/logging
```
