# Sample Presentation

`SampleState` is a Freezed union retaining the public `SampleLoading`,
`SampleData` and `SampleError` constructors. `copyWith(notice: null)` clears a
notice; omitting it preserves the notice. BLoC transitions explicitly clear old
notices when needed. Regenerate with `make codegen` after editing state fields.

Flutter sample page and BLoC. The app injects domain use cases and handles notices,
loading, navigation, and brand-specific presentation through callbacks.

```dart
SamplePage(
  createBloc: () => SampleBloc(
    getSample: getIt(),
    createItem: getIt(),
    updateItem: getIt(),
    deleteItem: getIt(),
  ),
  onNotice: showSampleNotice,
)
```

This package depends on `sample_domain`, never `sample_data` or an app service
locator.

```bash
flutter test features/sample/sample_presentation
```
