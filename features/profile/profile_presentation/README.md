# Profile Presentation

Flutter profile page and BLoC. Supply domain use cases and app-owned callbacks
for notices, sign-out, and optional demo content.

```dart
ProfilePage(
  createBloc: () => ProfileBloc(
    getProfile: getIt(),
    updateProfile: getIt(),
    onSignOut: session.signOut,
  ),
  onNotice: showProfileNotice,
)
```

The package has no dependency on `profile_data`, GetIt, or GoRouter.

```bash
flutter test features/profile/profile_presentation
```
