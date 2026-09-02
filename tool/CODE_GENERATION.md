# Code generation

The `sample` feature demonstrates these conventions. Existing auth/profile
features are not migrated automatically. Domain stays pure Dart: Freezed
annotations are allowed, but JSON, GetIt and Injectable stay outside domain.

## Commands

```bash
make codegen APP=sample_app
make codegen-watch PACKAGE=features/sample/sample_data
make codegen-check APP=sample_app
make new-feature NAME=orders APP=sample_app
```

Codegen discovers library packages and the selected app with a direct
`build_runner` dependency. `build.yaml` is optional customization, not a discovery
requirement. Watch runs one package at a time.

Commit `.freezed.dart`, `.g.dart`, `.config.dart` and `.chopper.dart` outputs;
never edit them manually. CI regenerates and rejects stale or untracked outputs.
`codegen-check` compares against HEAD, so valid new output not yet committed also
fails the check. Pre-commit does not regenerate the entire workspace.

## Freezed and JSON

Use Freezed for immutable entities, DTOs and multi-field states; do not also
implement Equatable on these classes. Omitting a nullable `copyWith` parameter
preserves it; passing `null` clears it. Replace state lists rather than mutating
their unmodifiable views.

DTOs use json_serializable for `fromJson`/`toJson`; keep `toEntity()` explicit.
Retain `safeDecode`: generated mapping still throws for malformed server fields.
See the sample entity, DTO and BLoC state under `features/sample`.

## Opt-in DI

Each app feature adapter calls an Injectable initializer scoped to that feature's
composition folder. Module methods bind interfaces and construct use cases;
domain classes need no DI annotations. See
`apps/sample_app/lib/app/features/sample/sample_di.dart`.

Initializers receive a GetIt container, allowing isolated tests. The app manifest
explicitly selects initializers: disabling a feature's registration does not
initialize it implicitly. Shared bootstrap registrations remain explicit;
async initialization and disposal need deliberate lifecycle configuration.

## Typed routing

`SampleRoute().go(context)` and `.location` come from `@TypedGoRoute`. Declarations
stay in separate feature adapter libraries, keeping generated route lists local.
The sample's shell adapter uses the generated location as its static path and
retains caller-supplied DI. The generated route's default builder uses app DI.
Do not mount both the adapter and its generated route list simultaneously.

For parameterized routes, mount the generated route tree instead of using a
concrete location as a path pattern. Typed routing does not implement universal
link platform setup or auth guards.

## New feature scaffold

`make new-feature` creates entity, DTO, repository, use case, Freezed state, BLoC,
injected page, tests, English README, and (when wired) feature-local DI/typed route.
It resolves dependencies and runs codegen. `WIRE=0` skips app wiring;
`ROUTE_KIND=tab` adds a shell branch. Replace the empty repository implementation
with your data source; test doubles are confined to tests.

## Compatible versions

The lockfile uses Freezed 3.0.6, json_serializable 6.9.5, go_router_builder 2.8.2
with go_router 14.x. This uses source_gen 2, build_runner 2.5 and Chopper generator
8.2. Upgrade generators as a compatible set, then regenerate/analyze/test the
workspace; do not blindly install each latest version.
