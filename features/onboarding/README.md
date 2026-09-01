# Onboarding Feature

Reusable onboarding completion and presentation organized with Feature-First
Clean Architecture.

## Packages

- `onboarding_domain`: pure contracts and use cases.
- `onboarding_data`: local completion-state implementation.
- `onboarding_presentation`: configurable Flutter flow.

## App composition

The app chooses a flow ID, localized steps, illustrations, route, and the action
after completion. Function-level spotlight education belongs to
`shared/tutorial_engine`, not this feature.

## Testing

```bash
dart test features/onboarding/onboarding_domain
flutter test features/onboarding/onboarding_data
flutter test features/onboarding/onboarding_presentation
```
