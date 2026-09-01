# Local Storage Family

Storage contracts and optional implementations are grouped here without forcing
every app to depend on every storage technology.

```text
local_storage/
  core/                       # package: local_storage (pure Dart)
  stores/
    shared_preferences/       # package: local_storage_shared_preferences
```

Apps and reusable capabilities depend on `local_storage/core`. An app selects
only the concrete store packages it needs in its composition root.

## Adding a store

Create a separate package under `stores/<technology>` that:

1. Depends on `../../core` and implements `KeyValueStore`.
2. Exposes no provider-specific type through `KeyValueStore`.
3. Includes unit tests and an English README with platform setup and limitations.
4. Is added to the root pub workspace only when a real app needs it.

Suggested package names include `local_storage_secure` and
`local_storage_drift`. Sensitive tokens should use a secure-storage adapter;
large or relational datasets should use a database rather than
SharedPreferences.
