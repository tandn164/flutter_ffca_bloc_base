# Feed Data

Chopper API, DTO mapping, and `FeedRepositoryImpl` for `feed_domain`.

The app injects `FeedApi`, `DataGateway`, and an operation-ID factory. Mutation
requests use stable idempotency keys when offline retry is enabled, so the server
must deduplicate repeated keys.

```bash
dart run build_runner build --delete-conflicting-outputs
dart test features/feed/feed_data
```
