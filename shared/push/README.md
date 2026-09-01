# App Push

Provider-independent push notification contracts, permission policy, foreground
presentation preferences, and message parsing. Provider SDKs live in optional
integration packages.

## Installation

```yaml
dependencies:
  app_push:
    path: ../../shared/push
```

## App composition

```dart
await push.initialize(
  foregroundPresentation: const PushPresentationOptions(
    alert: true,
    badge: true,
    sound: false,
  ),
);

final permission = await push.requestPermission();
push.setMessageHandler(handlePushMessage);
```

The provider adapter must apply foreground presentation options and register its
background entry point according to Android/iOS platform requirements.

## Message handling

`PushMessage` normalizes title, body, data, and the provider-independent
`silent` flag. Apps own payload-to-route mapping; use `locationFromPayload` from
`app_navigation` when the payload follows the base `path`/`query` convention.

## Badge and banner policy

`PushPresentationOptions` controls requested alert, badge, and sound behavior.
The operating system and user notification settings remain authoritative. Call
`clearBadge()` when the product policy requires it.

## Provider adapters

Implement `PushService` in a separate integration package such as
`integrations/firebase_push`. Keep Firebase/APNs imports, native setup, and
credentials out of business features and this contract package.

## Background limitations

No provider can guarantee that arbitrary Dart code runs for every background or
terminated notification. Follow provider rules for notification versus data
messages, initialize background handlers at top level, and test on real devices.

## Testing

Use `StubPushService.deliver()` for foreground behavior and navigation tests.

```bash
dart test shared/push
```
