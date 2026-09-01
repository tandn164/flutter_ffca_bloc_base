# Auth Domain

Pure Dart authentication business contracts.

## Usage

```dart
final login = LoginUseCase(authRepository);
final result = await login.execute(email: email, password: password);
```

Implement `AuthRepository` in a data package. Keep HTTP, token persistence,
Flutter widgets, routing, and service locators outside this package.

## Testing

```bash
dart test features/auth/auth_domain
```
