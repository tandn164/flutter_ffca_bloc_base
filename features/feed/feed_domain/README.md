# Feed Domain

Pure Dart feed entities, repository contract, and use cases.

```dart
final firstPage = await GetFeed(repository).execute(page: 1);
final created = await CreateFeedItem(repository).execute(title: 'Ship release');
```

The repository contract returns `Result` values. It does not expose DTOs,
Chopper, cache implementations, BLoC, or Flutter types.

```bash
dart test features/feed/feed_domain
```
