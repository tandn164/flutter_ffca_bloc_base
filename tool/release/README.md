# Release workflow

`make release APP=sample_app` starts a thin interactive wizard. It resolves the
release inputs, validates them, prints a summary, and delegates the actual build,
signing, and upload to the app's Fastlane lane.

## Destinations

Android supports:

- `export-apk`: build and retain a release APK locally;
- `export-aab`: build and retain a release App Bundle locally;
- `firebase`: build an APK by default and upload it to App Distribution. Set
  `ARTIFACT=appbundle` only after Firebase is linked to Google Play.

iOS supports:

- `export-ipa`: build and retain an app-store signed IPA locally;
- `firebase`: build an ad-hoc IPA and upload it to App Distribution;
- `testflight-internal`: upload without waiting for processing;
- `testflight-external`: upload to `TESTFLIGHT_GROUPS` with release notes;
- `app-store`: upload to App Store Connect without submission or automatic release.

## Interactive usage

```bash
make release APP=sample_app
```

The wizard asks for platform, flavor, version, build number, destination, and
iOS signing mode. It prints the complete selection before doing any work.

## CI and non-interactive usage

Every answer can be supplied as an environment variable:

```bash
APP=sample_app \
PLATFORM=android \
FLAVOR=stg \
DESTINATION=firebase \
BUILD_NAME=1.4.0 \
BUILD_NUMBER=120 \
FIREBASE_APP_ID_ANDROID_STG=1:123:android:abc \
FIREBASE_GROUPS=qa-team \
CONFIRM=1 \
make release
```

```bash
APP=sample_app \
PLATFORM=ios \
FLAVOR=prod \
DESTINATION=testflight-internal \
SIGNING=match \
BUILD_NAME=1.4.0 \
BUILD_NUMBER=120 \
CONFIRM=1 \
make release
```

Use `DRY_RUN=1` to resolve and validate the selection without checking tools,
building, signing, or uploading:

```bash
PLATFORM=ios FLAVOR=dev DESTINATION=export-ipa DRY_RUN=1 make release
```

## First-time Firebase setup

Firebase client configuration answers **which app receives the build**.
Authentication answers **who is allowed to upload**. You need both; a
`GoogleService-Info.plist` or `google-services.json` is not an upload credential.

1. Register the app in Firebase Console using the bundle/package ID for the
   flavor you intend to build. Open **App Distribution**, select the correct
   project and platform app, and click **Get started** to complete onboarding.
   Registering the Firebase app or downloading its Google Service config alone
   does not complete this step. Check onboarding for each app you distribute
   (for example, the separate iOS dev and prod apps).
2. Download the client config and place it in the selected app:
   - iOS: `apps/<app>/ios/Runner/Firebase/<flavor>/GoogleService-Info.plist`.
   - Android: `apps/<app>/android/app/src/<flavor>/google-services.json`.
3. Choose **one** authentication method below.
4. Run `make release APP=sample_app`, choose the platform/flavor and `firebase`.
   The script resolves the App ID, displays the target, and performs a read-only
   authentication/app-access check **before** confirmation and building. An app
   with no previous releases is valid. A failure stops the release with setup
   instructions; it does not start a build or upload.

### Local machine: Firebase CLI login

Install the [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
using the installation option for your OS. If Node.js/npm is installed, the npm
installation option is:

```bash
npm install -g firebase-tools
firebase --version
firebase login
make release APP=sample_app
```

Sign in using a Google account with access to the destination Firebase project
and permission to distribute builds. Fastlane reads the cached CLI login; you
normally only sign in once. For an expired session or wrong account, run
`firebase login --reauth`. On an interactive preflight failure, the wizard can
offer to open login if the CLI is installed; it asks permission first. It does
not install the CLI or open a browser automatically. CI never opens login.

### CI / build machine: service account (no CLI login needed)

Create a service account with the **Firebase App Distribution Admin** role on
the destination project, following the
[Firebase service-account guide](https://firebase.google.com/docs/app-distribution/authenticate-service-account).
Store its JSON key locally in the app's ignored `.secrets/` directory, or inject
it from your CI secret store. Never commit the key.

```bash
FIREBASE_SERVICE_CREDENTIALS_FILE="$PWD/apps/sample_app/.secrets/firebase-service-account.json" \
APP=sample_app PLATFORM=ios FLAVOR=dev DESTINATION=firebase SIGNING=automatic \
BUILD_NAME=1.0.0 BUILD_NUMBER=1 FIREBASE_GROUPS=qa-team CONFIRM=1 make release
```

Relative credential paths are resolved from the directory where you invoke the
script, before Fastlane changes directories. Explicit service credentials take
precedence over cached CLI login. The pinned plugin also supports ADC and the
legacy `FIREBASE_TOKEN`; avoid mixing credential methods unintentionally.

The preflight verifies authentication and release-list access, not every upload
permission, signing prerequisite, or tester-group setting. Upload may still
fail if those are misconfigured. Network failures also stop preflight. Dry runs
resolve the target locally but do not check authentication or contact Firebase.

### Troubleshooting: login succeeds but preflight fails

If you see `Success! Logged in` followed by `Firebase preflight failed`, signing
in again is not necessarily the solution. Authentication and App Distribution
onboarding are separate steps.

For an underlying **404 / App Distribution could not find your app** error:

1. Open [App Distribution](https://console.firebase.google.com/project/_/appdistribution)
   in Firebase Console and select the intended project and platform app.
2. Click **Get started** if shown and complete onboarding for that app.
3. Compare the Firebase ID printed in the release summary with **Project
   settings → General → Your apps → App ID**. Check that the selected flavor's
   config belongs to this app and that no environment override points elsewhere.
4. Run `make release APP=sample_app` again. You do not need to upload a first
   build manually; an onboarded app with no previous releases passes preflight.

The current script's generic preflight error does not by itself prove a 404.
If onboarding and the App ID are correct, check the account's project access,
App Distribution permissions, and network connectivity before retrying login.

## Firebase App ID resolution

Normally **no App ID environment variable is needed**. Resolution order is:

1. Platform/flavor override, for example `FIREBASE_APP_ID_IOS_DEV`.
2. Platform-wide override, for example `FIREBASE_APP_ID_IOS`.
3. Selected flavor's config: `GOOGLE_APP_ID` on iOS, or `mobilesdk_app_id`
   for the matching Android package in `google-services.json`.

Android uses the scaffold's literal Kotlin `applicationId` and flavor suffix.
For custom/dynamic Gradle configuration, set `ANDROID_APPLICATION_ID` to the
final package name, or explicitly override the Firebase App ID. Ambiguous or
missing client matches fail rather than selecting the first JSON client.

Overrides are useful for CI or apps distributing through Firebase without a
Firebase SDK integration. App IDs look like `1:123456789:ios:abc123`; they are
not a project ID, bundle ID, or API key. Find them in Firebase Console → Project
settings → General → Your apps → App ID.

Available optional overrides:

```text
FIREBASE_APP_ID_ANDROID_DEV
FIREBASE_APP_ID_ANDROID_STG
FIREBASE_APP_ID_ANDROID_PROD
FIREBASE_APP_ID_IOS_DEV
FIREBASE_APP_ID_IOS_STG
FIREBASE_APP_ID_IOS_PROD
```

`FIREBASE_APP_ID_ANDROID` and `FIREBASE_APP_ID_IOS` are supported as fallback
values. Optional inputs are:

```text
FIREBASE_GROUPS
FIREBASE_SERVICE_CREDENTIALS_FILE
RELEASE_NOTES
```

For local use, the Firebase Fastlane plugin can use the current Firebase CLI
login. CI should set `FIREBASE_SERVICE_CREDENTIALS_FILE` to a protected service
account JSON file. Never commit that file.

## Signing

`SIGNING=automatic` uses the current Xcode project signing configuration.
It explicitly selects automatic signing and passes `-allowProvisioningUpdates`
to both archive and export, allowing Xcode to create/update signing assets on
Apple Developer when necessary. It does not automatically register tester
devices. This requires a valid account in **Xcode → Settings → Accounts** with
access to the selected team and appropriate provisioning permissions.
By default the team comes from the project's build configuration; optionally
set `IOS_TEAM_ID` to override it for both archive and export. The script does
not choose a different Apple account or team for you.

If archive succeeds but export reports **No profiles ... were found**, check
that the bundle ID and team are correct and that a distribution profile can be
created for the registered tester devices. A development profile sufficient
for archiving is not necessarily suitable for distributing the IPA. If Xcode
also reports **missing Xcode-Token / Invalid credentials in keychain**, repair
the relevant Apple account login in Xcode Settings; Firebase login is unrelated.

The pinned Fastlane 2.231.1 only accepts the legacy `ad-hoc` / `app-store`
export-method names. Xcode maps these to `release-testing` / `app-store-connect`
and may print deprecation warnings. These warnings do not cause a missing-profile
failure; changing the names requires a compatible Fastlane upgrade first.

`SIGNING=match` reads the required ad-hoc or app-store assets through Fastlane
Match. Firebase iOS distribution uses ad-hoc signing and therefore requires the
tester devices to be present in the provisioning profile.

Android release builds must use an app-owned release keystore. The sample app
still warns when its placeholder Gradle configuration uses the debug key.

## Setup

The repository pins Ruby in `.ruby-version` and Bundler in
`tool/toolchain.env`. The supported setup entry point installs/selects both and
then restores the project-local gems:

```bash
make init APP=sample_app
```

The root `Gemfile` includes Fastlane, CocoaPods, and the Firebase App
Distribution Fastlane plugin. `make init` remains responsible for the Flutter,
Ruby, Xcode, and Android toolchain prerequisites.
