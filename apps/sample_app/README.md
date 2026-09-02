# Sample App

This Flutter application demonstrates how a product composes reusable feature
and shared packages. It is intentionally a thin composition root, not a source
of reusable business or infrastructure code.

## What remains app-owned

- bootstrap, flavors, theme, and native projects;
- GetIt registrations and the build-time feature manifest;
- GoRouter route names and tab order;
- product copy and callbacks passed into feature presentation packages;
- the capability showcase UI that triggers reusable base behavior.

Reusable behavior must be added to `features/`, `shared/`, or a real
`integrations/` package first, then consumed here.

## Run

```bash
make run APP=sample_app FLAVOR=dev
```

The **Capabilities** tab triggers overlays, connectivity policies, skeletons,
validation, logs, deep links, and onboarding. The **Sample list** tab is the
exception: it is a complete feature-first clean architecture example with BLoC,
pagination, pull-to-refresh, and optimistic mutations. It uses a deterministic
local repository rather than pretending to be a backend.

## Feature selection

`lib/app/features/sample_features.dart` is the only manifest listing the app's
feature set. Per-feature adapters in the same directory own DI, routes, and
presentation callbacks. Real providers belong in app composition or an
`integrations/` adapter; the sample app does not silently replace them with
fake implementations.

## Firebase configuration

Per-flavor Android and iOS configuration folders are already prepared. See
[FIREBASE.md](FIREBASE.md) before adding Firebase SDKs or release credentials.

## Validate

```bash
make codegen APP=sample_app
make lint APP=sample_app
make test APP=sample_app
```
