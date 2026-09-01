# App Session

Pure runtime session contracts for routing and app lifecycle decisions. The
package intentionally does not know how authentication, token storage, or token
refresh is implemented.

## Usage

```dart
final session = StubSession(
  guestAllowed: true,
  restoreDelay: Duration.zero,
);
await session.restore();

session.addListener(onSessionChanged);
if (session.state.isAuthenticated) {
  // Allow protected navigation.
}
```

An app that includes Auth should bind `Session` to `AuthSession` from
`auth_data`. An app without Auth can bind `StubSession` or its own implementation.
This keeps navigation reusable for guest-only, guest-optional, and auth-required
products.

## Ownership

- This package owns session state and lifecycle contracts.
- `auth_data` owns tokens, refresh, sign-in, and sign-out mechanics.
- `interceptor` (`AuthInterceptor`) owns HTTP interception and single-flight refresh behavior.

## Testing

```bash
dart test shared/session
```
