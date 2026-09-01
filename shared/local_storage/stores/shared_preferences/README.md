# Local Storage SharedPreferences

Flutter adapter from the pure `KeyValueStore` contract to SharedPreferences.

## Installation

```yaml
dependencies:
  local_storage:
    path: ../../shared/local_storage/core
  local_storage_shared_preferences:
    path: ../../shared/local_storage/stores/shared_preferences
```

```dart
final preferences = await SharedPreferences.getInstance();
final store = SharedPreferencesKeyValueStore(preferences);
```

Use it for settings and modest queues. Tokens require secure storage; large
datasets and high-volume synchronization require a database adapter.
