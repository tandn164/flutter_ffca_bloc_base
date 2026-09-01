# Interactive Release

`make release` prompts for platform, flavor, build name, build number, artifact,
signing mode, and destination.

## Android

Local APK/App Bundle export works with Flutter. Firebase App Distribution needs
the Firebase CLI and `FIREBASE_APP_ID_ANDROID`; optional groups use
`FIREBASE_GROUPS`.

## iOS

Local export uses `flutter build ipa`. TestFlight and App Store destinations use
the app's Fastlane configuration. Automatic signing uses the current Xcode
configuration. `match` signing requires app-specific Match credentials and
repository configuration.

## Safety

The wizard prints choices and only uploads after the user selected an upload
destination. Store API keys, certificates, and service credentials in CI secrets
or the local keychain, never in this repository.
