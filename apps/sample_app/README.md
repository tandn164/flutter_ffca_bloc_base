# Sample App

This Flutter application demonstrates how a product composes reusable feature
and shared packages. It is intentionally a thin composition root, not a source
of reusable business or infrastructure code.

## What remains app-owned

- bootstrap, environment, flavors, theme, splash, and native projects;
- GetIt registrations and the build-time feature manifest;
- GoRouter route names, tab order, and session policy;
- product copy and callbacks passed into feature presentation packages;
- concrete provider selection and the in-process fake API.

Reusable behavior must be added to `features/`, `shared/`, or a real
`integrations/` package first, then consumed here.

## Run

```bash
make run APP=sample_app FLAVOR=dev
```

When `API_BASE_URL` is empty or a placeholder, the app uses its in-process demo
backend.

```text
Email:    demo@example.com
Password: password
```

## Feature selection

`lib/app/features/sample_features.dart` is the only manifest listing the app's
feature set. Per-feature adapters in the same directory own DI, routes, API
services, presentation callbacks, and fake handlers.

## Validate

```bash
make codegen APP=sample_app
make lint APP=sample_app
make test APP=sample_app
```
