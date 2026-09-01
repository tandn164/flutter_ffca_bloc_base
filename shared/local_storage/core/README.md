# Local Storage

Small asynchronous storage contracts for reusable capabilities. The API keeps
offline queues and feature packages independent from a concrete Flutter plugin.

## Installation

```yaml
dependencies:
  local_storage:
    path: ../../shared/local_storage/core
```

## Quick start

```dart
await store.writeString('session.user', jsonEncode(user));
final raw = await store.readString('session.user');
```

Use `MemoryKeyValueStore` in unit tests. Flutter apps can add the optional
`local_storage_shared_preferences` adapter from
`shared/local_storage/stores/shared_preferences`.

## What belongs here

This package stores opaque strings. Serialization, migrations, encryption, and
domain keys belong to the capability that owns the data. Sensitive tokens should
use a secure-storage adapter rather than `SharedPreferences`.

## Limitations

`SharedPreferences` is appropriate for settings and modest queues, not large or
relational datasets. Add a database-backed `KeyValueStore` adapter when an app
needs high-volume cache or synchronization data.

## Testing

```bash
dart test shared/local_storage/core
```
