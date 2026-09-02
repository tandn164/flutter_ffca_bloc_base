# Firebase configuration

This app keeps client configuration next to the native target that consumes it
and separates every environment.

## Android

Download one config for each Firebase Android app and place it at:

```text
android/app/src/dev/google-services.json
android/app/src/stg/google-services.json
android/app/src/prod/google-services.json
```

The application IDs must match the configured flavors:

```text
dev   com.company.flutter_ffca_base.dev
stg   com.company.flutter_ffca_base.stg
prod  com.company.flutter_ffca_base
```

The Google Services Gradle plugin is only applied when a client config exists,
so a newly cloned base still builds before Firebase is selected. Once
`firebase_core` is added, a missing config fails the build instead of silently
producing a misconfigured app.

## iOS

Download one config for each Firebase Apple app and place it at:

```text
ios/Runner/Firebase/dev/GoogleService-Info.plist
ios/Runner/Firebase/stg/GoogleService-Info.plist
ios/Runner/Firebase/prod/GoogleService-Info.plist
```

The `Configure Firebase` Xcode build phase resolves the flavor from the active
build configuration and copies the matching file into the built application.
It skips before Firebase is enabled and fails when `firebase_core` is enabled
but the selected flavor file is missing.

## Release credentials

The release wizard reads the Firebase App ID from the selected flavor's client
config automatically. `FIREBASE_APP_ID_IOS_DEV` and similar overrides are
optional. Client config alone does **not** authenticate uploads.

Before the first upload, open Firebase Console → **App Distribution**, select
the correct project and platform app, and click **Get started** to complete
onboarding. Downloading the client config or logging into the CLI does not
replace this step. Missing onboarding can cause a 404 even after login succeeds;
see [preflight troubleshooting](../../tool/release/README.md#troubleshooting-login-succeeds-but-preflight-fails).

For local uploads, install the [Firebase CLI](https://firebase.google.com/docs/cli),
run `firebase login`, then `make release APP=sample_app` and choose Firebase.
Alternatively, provide the service account below; no CLI login is needed for
that method. See [First-time Firebase setup](../../tool/release/README.md#first-time-firebase-setup)
for complete local and CI commands, permissions, and troubleshooting.

Client config files contain identifiers rather than service-account private
keys, but this reusable base ignores them because they belong to a concrete
product. Never commit release credentials. A local service account can live at:

```text
.secrets/firebase-service-account.json
```

Pass its absolute path as `FIREBASE_SERVICE_CREDENTIALS_FILE`. CI should create
the file temporarily from its protected secret store.

`make new-app NAME=<name>` creates all of these empty flavor directories and
never copies Firebase configs or credentials from the source app.
