# App Overlay

App-lifetime loading, toast, offline, and tutorial presentation for Flutter.
The host is designed to wrap the navigator so transient UI survives route and
tab changes.

## Installation

```yaml
dependencies:
  app_overlay:
    path: ../../shared/app_overlay
```

## App composition

Create one controller and place `OverlayHost` in `MaterialApp.builder`:

```dart
final overlay = OverlayController(
  connectivity: connectivity,
  defaultPageConfig: const PageConfig(
    noInternet: NoInternetMode.banner,
  ),
);

MaterialApp.router(
  routerConfig: router,
  builder: (context, child) {
    return OverlayHost(
      controller: overlay,
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

Because the host wraps the router output, blocking loading covers route content,
bottom navigation, and nested navigators.

## Loading

Use a handle so cleanup is idempotent:

```dart
final loading = overlay.showLoading();
try {
  await repository.save();
} finally {
  loading.close();
}
```

Customize a single operation:

```dart
overlay.showLoading(
  contentBuilder: (_) => const MyGiftAnimation(),
);
```

## Toasts

```dart
overlay.showToast(
  type: ToastType.success,
  message: 'Profile saved',
  duration: const Duration(seconds: 2),
  dedupeKey: 'profile-saved',
);
```

Toasts are deduplicated, bounded, shown one at a time in a fixed slot, and owned
by the app host rather than a route. Pass `toastBuilder` to apply product styling
and localization.

## Per-page offline policy

```dart
AppPage(
  pageConfig: const PageConfig(noInternet: NoInternetMode.block),
  child: CheckoutPage(),
);
```

`NoInternetMode.inherit` uses the app default. `AppScaffold` is a convenience
wrapper that applies the same policy without requiring screen inheritance.

## Tutorial integration

The host renders the `TutorialController` owned by the overlay controller. Pass
`tutorialContentBuilder` for localized, product-specific tutorial content.

## Limitations

Connectivity is a hint. The overlay must not be used as proof that a request can
reach the server. Networking code must still handle transport failures.

## Testing

```bash
flutter test shared/app_overlay
```
