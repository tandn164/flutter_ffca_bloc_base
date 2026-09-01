# Interceptor

Reusable `ApiClient` interceptors. Add new cross-cutting HTTP hooks here instead of
duplicating them in each app.

## Included interceptors

### `AuthInterceptor`

Connects `Session` to authenticated HTTP:

- attaches `Session.authorizationHeaders`
- on 401, runs one shared `session.refresh()` for concurrent requests
- retries once after a successful refresh
- kicks the session only after a confirmed `AuthFailure`
- skips refresh when offline or for configured handshake paths (login/refresh)

```dart
dependencies:
  interceptor:
    path: ../../shared/interceptor

final client = ApiClient(
  transport: transport,
  interceptors: [
    AuthInterceptor(
      session: session,
      connectivity: connectivity,
      handshakePaths: {AuthApi.loginPath, AuthApi.refreshPath},
    ),
  ],
);
```

Token storage and refresh API calls stay in `auth_data`. Route policy stays in
`app_navigation`. This package only owns HTTP interception policy.

## Testing

```bash
flutter test shared/interceptor
```
