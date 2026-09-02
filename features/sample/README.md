# Sample Feature

This is the reference feature for generated models, JSON, state, DI and typed
routes. See [Code generation](../../tool/CODE_GENERATION.md). The app explicitly
selects this feature's Injectable initializer; generation does not auto-enable it.

A reusable paginated task list split into `sample_domain`, `sample_data`, and
`sample_presentation`. It exists to demonstrate Feature-First Clean Architecture,
BLoC, skeleton loading, pull-to-refresh, load-more, and optimistic mutations.

The sample app binds the repository to `LocalSampleRepository`, so running the
showcase never depends on a fake server. `SampleRepositoryImpl` remains the
network-backed reference for cache policies, safe decoding, and idempotent
offline writes.

See each package README and
`apps/sample_app/lib/app/features/sample_feature.dart` for composition.
