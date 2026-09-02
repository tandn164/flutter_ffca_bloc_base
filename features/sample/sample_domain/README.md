# Sample Domain

Pure Dart sample entities, repository contract, and use cases.

`SampleItem` uses Freezed for immutable values, equality and `copyWith`. Run
`make codegen` from the workspace after changing fields and commit the generated
file. Domain has no JSON or DI annotations.

```dart
final firstPage = await GetSample(repository).execute(page: 1);
final created = await CreateSampleItem(repository).execute(title: 'Ship release');
```

The repository contract returns `Result` values. It does not expose DTOs,
Chopper, cache implementations, BLoC, or Flutter types.

```bash
dart test features/sample/sample_domain
```
