# Tooling

Workspace automation for environment bootstrap, validation, code generation,
localization, builds, and releases.

## Commands

```bash
make doctor
make init APP=sample_app
make codegen APP=sample_app
make lint APP=sample_app
make test APP=sample_app
make l10n APP=sample_app
make release APP=sample_app
```

`tool/toolchain.env`, `.fvmrc`, and `.ruby-version` are the version contract.
FVM isolates Flutter, while rbenv selects the pinned Ruby only inside this
repository. Bundler installs Fastlane, CocoaPods, and plugins into the ignored
`vendor/bundle` directory. Scripts do not silently switch Xcode, signing
identities, or upload destinations.

## Package discovery

Analyze, test, and code generation scripts discover packages below `shared/` and
`features/`. Adding a package does not require a hard-coded CI list.

See [release](release/README.md), [localization](l10n/README.md),
[scaffolding](scaffold/README.md), and [adopt project](adopt_project.sh).

## Adopt into a product repo

When cloning this base for a real product, rename the canonical slug
`flutter_ffca_base` to your workspace package name:

```bash
CONFIRM=1 make adopt-project PACKAGE=acme_merchant TITLE="Acme Merchant"
```
