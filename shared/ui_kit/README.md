# UI Kit

Reusable Flutter primitives for forms, validation, skeleton loading, lists,
responsive layouts, and adaptive navigation. Product branding remains in each
application theme.

## Installation

```yaml
dependencies:
  ui_kit:
    path: ../../shared/ui_kit
```

## Responsive layout

Use constraints and breakpoints rather than scaling every pixel from a design
device. `AdaptiveValue` selects explicit compact, medium, and expanded values.
Use `clampScale` when a value may scale but must preserve accessible minimum and
maximum sizes.

## Adaptive navigation

`AdaptiveNavigationShell` uses `NavigationBar` on compact screens and
`NavigationRail` on larger devices. The application supplies destinations,
labels, selection state, and the body.

## Validation

```dart
final validator = localizedValidator(
  rules: const [RequiredRule(), EmailRule()],
  messageFor: (error) => translations.validation(error.code),
);
```

Typed rules stay independent from localization. Legacy string-returning
validators remain available for compatibility.

## Skeleton loading

Compose `SkeletonBox`, `SkeletonLine`, `SkeletonCircle`, `SkeletonTile`, and
`SkeletonList` to match a feature's real layout. Skeletons represent local page
loading; use `app_overlay` for blocking app-wide progress.

## Testing

```bash
flutter test shared/ui_kit
```
