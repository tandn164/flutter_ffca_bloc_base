# Profile Domain

Pure Dart profile entity, repository contract, and use cases.

```dart
final result = await GetProfile(repository).execute();
final updated = await UpdateProfile(repository).execute(name: 'Taylor');
```

Keep API payloads, local storage, widgets, and routing outside this package.

```bash
dart test features/profile/profile_domain
```
