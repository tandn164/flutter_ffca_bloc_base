# Scaffolding

Generate a new feature package set or clone an app skeleton.

## New feature

Creates `features/<name>/{domain,data,presentation}`, registers workspace
packages, and wires a stub adapter into `apps/<app>/lib/app/features/`.

```bash
make new-feature NAME=orders
make new-feature NAME=orders APP=sample_app
make new-feature NAME=catalog ROUTE_KIND=tab
WIRE=0 make new-feature NAME=reports   # packages only
```

Defaults:

- `APP=sample_app`
- `ROUTE_KIND=public` (`public` adds a GoRoute; `tab` adds a shell branch)
- `WIRE=1` (set `WIRE=0` to skip app pubspec + manifest wiring)

After scaffolding:

```bash
make get
make lint APP=sample_app
make test APP=sample_app
```

## Delete feature

Removes `features/<name>`, unregisters workspace packages, and unwires the app
adapter/manifest. Built-in demo features (`auth`, `feed`, `profile`,
`onboarding`) are protected.

```bash
CONFIRM=1 make delete-feature NAME=orders
CONFIRM=1 make delete-feature NAME=orders APP=sample_app
CONFIRM=1 WIRE=0 make delete-feature NAME=reports   # packages only
```

Defaults:

- `APP=sample_app`
- `WIRE=1` (set `WIRE=0` to delete packages only and keep app wiring)

## New app

Clones `apps/sample_app` (or `SOURCE=`) into a new workspace app.

```bash
make new-app NAME=merchant_app
make new-app NAME=merchant_app SOURCE=sample_app
```

`make new-app` also registers an Android Studio / IntelliJ run configuration for the
new app. If the run dropdown still shows only `sample_app`, restart the IDE or run:

```bash
bash tool/scaffold/register_ide_app.sh merchant_app
```

Then trim the feature manifest and update native bundle identifiers.

## Delete app

Removes `apps/<name>`, unregisters the Dart workspace entry, and cleans IDE run
configuration / module entries. `sample_app` is protected.

```bash
CONFIRM=1 make delete-app NAME=merchant_app
```

## Adopt base slug for a product repo

Renames the canonical workspace slug `flutter_ffca_base` to your product package
name across workspace metadata, native bundle IDs, env defaults, and docs:

```bash
CONFIRM=1 make adopt-project PACKAGE=acme_merchant TITLE="Acme Merchant"
```
