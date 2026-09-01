# Flutter FFCA Base

A multi-app Flutter workspace built with Feature-First Clean Architecture, BLoC,
and app-owned composition. Reusable business capabilities live in `features/`;
reusable technical capabilities live in `shared/`; `sample_app` only selects and
wires them.

The package boundaries follow the VGV-style dependency direction:

```text
Presentation ─────▶ Domain ◀───── Data
 Flutter/BLoC       pure Dart      API/DTO/storage

                    ▲
                    │ composed by
                 apps/<app>
```

## Goals

- Select a different feature set for each app at build time.
- Customize routes, branding, copy, SDKs, and UX without forking domain logic.
- Keep business logic independent from Flutter, HTTP, routing, and service locators.
- Make offline, auth, overlays, logging, responsive UI, and tooling reusable.
- Avoid generic `core` packages and empty layers created only to fill a diagram.

## Workspace

```text
apps/
  sample_app/                  # bootstrap, DI, router, theme, native projects, fake API

features/
  auth/                      # credentials and authenticated session
  feed/                      # paginated task/feed example
  onboarding/                # persisted onboarding flow
  profile/                   # profile load/update/sign-out

shared/
  api_client/                # transport, policies, cache gateway, safe decoding
  app_overlay/               # global loading/toast/offline/tutorial host
  app_result/                # typed Result and Failure
  connectivity/              # conservative connectivity signal
  local_storage/
    core/                    # pure Dart key/value contract
    stores/
      shared_preferences/    # optional SharedPreferences adapter
  logging/                   # background serial log queue and API interceptor
  navigation/                # session redirects, deep links, nav logging
  offline_sync/              # durable idempotent write outbox
  push/                      # provider-neutral push contract and presentation options
  session/                   # provider-neutral session contract
  interceptor/               # ApiClient interceptors (auth, …)
  tutorial_engine/           # persisted function tutorial and spotlight layer
  ui_kit/                    # responsive shell, skeletons, typed validation, UI primitives

integrations/                # convention for real third-party SDK adapters
tool/                        # bootstrap, release, l10n, quality, analyze/test/codegen
```

Every reusable package has an English README describing its public API,
composition, safety rules, and tests. Start with the package README rather than
copying code out of `sample_app`.

## Ownership rules

- Domain is pure Dart and owns entities, repository contracts, and use cases.
- Data implements Domain and owns DTO/API/persistence details.
- Presentation depends on Domain, never Data or GetIt.
- Shared packages never import business features.
- Apps own GetIt, GoRouter, flavors, theme, native configuration, and concrete wiring.
- A feature package does not know which route, tab, overlay, or app uses it.
- A third-party provider SDK is hidden behind a domain/shared contract and selected by the app.

Boundary tests in `sample_app` enforce these rules and verify that every workspace
package includes a README.

## Feature composition

`apps/sample_app/lib/app/features/sample_features.dart` is the single feature
manifest. Each app-owned adapter composes one feature's dependencies, API
service, routes or shell branch, and demo backend handler.

To add a feature to an app:

```bash
make new-feature NAME=orders APP=sample_app
```

Or manually:

1. Add the required Domain/Data/Presentation packages to the app `pubspec.yaml`.
2. Create an app adapter under `lib/app/features/`.
3. Register that adapter in the app feature manifest.
4. Run `make get`, `make codegen`, `make lint`, and `make test`.

To scaffold a new app:

```bash
make new-app NAME=merchant_app
```

To remove a scaffolded app (protects `sample_app`):

```bash
CONFIRM=1 make delete-app NAME=merchant_app
```

To remove a scaffolded feature (protects `auth`, `feed`, `profile`, `onboarding`):

```bash
CONFIRM=1 make delete-feature NAME=orders APP=sample_app
```

See [tool/scaffold/README.md](tool/scaffold/README.md) for options such as
`ROUTE_KIND=tab`, `WIRE=0`, and `delete-feature`.

## Adopt into a product repo

This repository ships with a **canonical workspace slug**: `flutter_ffca_base`.
That slug appears in workspace metadata, native bundle IDs, env defaults, and
display names so the base stays identifiable while you evaluate it.

When you clone or fork the base for a **real product**, run the adopt script
**once** at the start of the product repo. It renames `flutter_ffca_base` to
your product package name everywhere the slug is used.

```bash
# Preview (prints the confirmation command, changes nothing)
make adopt-project PACKAGE=acme_merchant

# Apply
CONFIRM=1 make adopt-project PACKAGE=acme_merchant TITLE="Acme Merchant"
```

| Variable | Required | Description |
| --- | --- | --- |
| `PACKAGE` | yes | Product slug in `snake_case` (e.g. `acme_merchant`) |
| `TITLE` | no | Human-readable app title; defaults from `PACKAGE` |
| `CONFIRM=1` | yes to apply | Without it, the script only prints instructions |

**Example mapping** (`PACKAGE=acme_merchant`, `TITLE="Acme Merchant"`):

| Before (base) | After (product) |
| --- | --- |
| `flutter_ffca_base_workspace` | `acme_merchant_workspace` |
| `flutter_ffca_base` (iOS display name, env slug, …) | `acme_merchant` |
| `Flutter FFCA Base` | `Acme Merchant` |
| `com.company.flutter_ffca_base` (Android `applicationId`) | `com.company.acme_merchant` |
| `com.company.flutter_ffca_base` (Android namespace / Kotlin) | `com.company.acme_merchant` |
| `com.company.flutterFfcaBase` (iOS bundle ID) | `com.company.acmeMerchant` |

The script also moves the Kotlin `MainActivity` package folder, renames the
root `.iml` module when present, and runs `dart pub get`.

**After adopt:**

1. Review `git diff` — the rename touches many files.
2. Update Android/iOS **signing** and store listings if bundle IDs changed.
3. Restart Android Studio so run configurations refresh.
4. Continue with `make init APP=sample_app` (or your app folder under `apps/`).

**Low-level entry point** (custom slug renames only):

```bash
CONFIRM=1 bash tool/rename_project_slug.sh \
  FROM_SLUG=flutter_ffca_base \
  TO_SLUG=acme_merchant \
  FROM_TITLE="Flutter FFCA Base" \
  TO_TITLE="Acme Merchant"
```

Implementation: [`tool/adopt_project.sh`](tool/adopt_project.sh),
[`tool/rename_project_slug.sh`](tool/rename_project_slug.sh).

**Note:** `make adopt-project` renames the **workspace/product slug**, not an
individual app folder under `apps/`. Use `make new-app` to add product apps and
keep `sample_app` as the reference composition or trim it later.

## Reusable UX capabilities

### Offline-first data

`api_client` supports cache-first, network-first, stale-while-revalidate, and
network-only reads. Decode errors become typed failures. `offline_sync` persists
explicitly retryable writes, drains them serially, applies exponential backoff,
and moves permanent failures to a dead-letter queue.

Automatic write delivery is at least once. Every queued mutation requires a
stable idempotency key and matching server-side deduplication. SharedPreferences
is intended for modest queues; use a database adapter for larger sync workloads.
OS execution while the app is suspended still needs a platform background-task
adapter.

### App-wide overlays

`app_overlay` hosts loading, toast, no-internet, and tutorial layers above the
router, so overlays survive screen disposal and can cover navigation and bottom
bars. Loading uses idempotent handles, toast delivery is queued, deduplicated,
and shown one at a time in a fixed slot. The center loading content is
replaceable. `PageConfig` can inherit the app
offline policy or override it per screen.

### Auth and navigation

`SessionRoutePolicy` supports guest-only, guest-optional, and auth-required apps.
`AuthInterceptor` performs a single shared refresh for concurrent 401s,
retries the request, and only kicks the session after a confirmed auth failure.
GoRouter owns app routes and universal/deep-link parsing; features receive
navigation callbacks.

### UI foundations

`ui_kit` uses breakpoints, clamped values, and minimum interactive sizes instead
of scaling every dimension from a design canvas. It includes adaptive
NavigationBar/NavigationRail, reusable skeleton primitives, and typed validation
rules whose messages are localized by the app.

### Logs and push

`app_logging` queues user actions and redacted API metadata, delivers batches
serially in the background, and never awaits network logging on the UI action.
`app_push` is provider-neutral and exposes foreground presentation, permission,
badge, and payload contracts; an app adds Firebase/APNs/another provider adapter
only when required.

## Sample app

`sample_app` demonstrates composition, not a second framework layer. It retains
only app-specific concerns: bootstrap, feature manifest, router, theme, splash,
flavors, provider selection, native projects, and an in-process fake backend.

When `API_BASE_URL` is empty or a placeholder, the app uses the fake backend.

```text
Email:    demo@example.com
Password: password
```

Run it with:

```bash
make run
make run APP=sample_app FLAVOR=stg
```

Supported flavors are `dev`, `stg`, and `prod`.

## Environment setup

The toolchain contract lives in `tool/toolchain.env` and `.fvmrc`.

```bash
make doctor   # report missing or mismatched tools
make init     # offer to install prerequisites, select Flutter, get, generate, validate
```

Bootstrap asks before installing host tools. Xcode installation or switching is
never silent because it affects the whole macOS machine.

## Build and release

```bash
make release
```

The interactive release script asks for platform, flavor, build name, build
number, artifact type, signing mode, and destination. Supported destinations:

- Android APK or App Bundle: local export or Firebase App Distribution.
- iOS IPA: local export, TestFlight internal/external, or App Store upload.
- iOS automatic signing or Fastlane Match-based certificate signing.

The script does not publish an App Store release automatically. Credentials,
bundle IDs, Firebase app IDs, and Match configuration remain app/environment
owned. See `tool/release/README.md`.

## Localization

```bash
GOOGLE_SHEET_ID=<id> make l10n
```

The script downloads a Google Sheets CSV, validates and converts it to ARB, then
runs Flutter localization generation. See `tool/l10n/README.md` for the expected
columns and optional sheet GID.

## Quality gates

```bash
make get
make codegen
make lint
make test
make setup-hooks   # optional local pre-commit and commit-message validation
```

Workspace scripts discover apps and packages rather than maintaining a hardcoded
Auth/Feed/Profile list. CI calls the same analyze, test, and codegen entry points.
Git hooks are opt-in and documented in `tool/quality/README.md`.

## Third-party services

When a real Map, Payment, Analytics, or Support SDK is needed, follow
`integrations/README.md`: define a provider-neutral contract, isolate the SDK in
a small adapter package, keep secrets/native settings app-owned, and supply a
fake for tests. The base deliberately does not ship unused provider packages.
