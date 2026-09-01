# Auth Presentation

Flutter pages and BLoCs for login, signup, and forgotten-password flows.

## Usage

The app creates the BLoC and passes app-owned behavior into the page:

```dart
LoginPage(
  createBloc: () => LoginBloc(
    login: getIt(),
    onAuthenticated: saveSession,
  ),
  onSignup: openSignup,
  onForgotPassword: openForgotPassword,
  onNotice: showAuthNotice,
)
```

The package does not use GetIt, import `auth_data`, own route strings, or own
brand copy. Keep navigation and overlay decisions in the app adapter.

## Testing

```bash
flutter test features/auth/auth_presentation
```
