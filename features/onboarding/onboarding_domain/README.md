# Onboarding Domain

Pure Dart completion contracts and use cases for reusable onboarding flows.

## Usage

```dart
final shouldShow = ShouldShowOnboarding(repository);
if (await shouldShow('main-v1')) {
  navigation.go('/onboarding');
}
```

Flow IDs should change when a product introduces a materially new onboarding
experience. The domain does not depend on Flutter, storage, or navigation.
