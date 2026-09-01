# Onboarding Data

Persists onboarding completion through the provider-independent `KeyValueStore`.

```dart
final repository = StoredOnboardingRepository(store);
await repository.complete('main-v1');
```

Use secure or database-backed storage only when the product's onboarding state
requires it. Completion state is normally not sensitive.
