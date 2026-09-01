# Feed Presentation

Flutter feed page and BLoC. The app injects domain use cases and handles notices,
loading, navigation, and brand-specific presentation through callbacks.

```dart
FeedPage(
  createBloc: () => FeedBloc(
    getFeed: getIt(),
    createItem: getIt(),
    updateItem: getIt(),
    deleteItem: getIt(),
  ),
  onNotice: showFeedNotice,
)
```

This package depends on `feed_domain`, never `feed_data` or an app service
locator.

```bash
flutter test features/feed/feed_presentation
```
