# App Navigation

Reusable session-route policy, deep-link payload parsing, and navigation logging.
Applications still own route strings, screen builders, and platform domains.

## Installation

```yaml
dependencies:
  app_navigation:
    path: ../../shared/navigation
```

## Session policy

```dart
const policy = SessionRoutePolicy(
  guestAllowed: true,
  splashLocation: '/splash',
  signInLocation: '/login',
  homeLocation: '/home',
  publicPrefixes: {'/login', '/signup'},
  protectedPrefixes: {'/checkout'},
  authOnlyPrefixes: {'/login', '/signup'},
);
```

Use the pure redirect function from a `go_router` redirect callback:

```dart
redirect: (context, state) => resolveSessionRedirect(
  status: session.state.status,
  path: state.uri.path,
  fullPath: state.uri.toString(),
  from: state.uri.queryParameters['from'],
  policy: policy,
),
```

The same function should protect normal navigation, universal links, and push
notification links.

## Universal links

The package validates and creates in-app locations. Each application must still
configure Android App Links, iOS Associated Domains, and the hosted association
files for its own domain and bundle identifiers.

## Push payload mapping

```dart
final location = locationFromPayload({
  'path': '/orders/42',
  'query': {'tab': 'payment'},
});
```

Only absolute app paths beginning with `/` are accepted.

## Navigation logs

Pass `LogNavObserver(logSink)` to the router. Route arguments are not serialized,
which avoids accidentally logging sensitive objects.

## Testing

```bash
flutter test shared/navigation
```
