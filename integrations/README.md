# Third-Party Integrations

Use this directory for reusable adapters around external SDKs such as maps,
payments, analytics, or customer support. Do not add a package until a real app
needs the integration.

## Recommended shape

```text
integrations/<provider_name>/
  lib/
    <provider_name>.dart       # small public API
    src/
      <provider>_adapter.dart  # SDK-specific implementation
  test/
  README.md
  pubspec.yaml
```

Define the product-facing contract in a feature domain package when the concept
is business-specific (for example `PaymentGateway`). Put only the provider SDK
adapter here. The app composition root selects and configures the adapter.

## Rules

- Never expose SDK objects through feature domain APIs.
- Keep keys and environment configuration app-owned.
- Map provider errors to app/domain failures at the boundary.
- Wrap initialization and disposal; avoid hidden global singletons.
- Add a fake implementation for unit and widget tests.
- Document native Android/iOS setup and required permissions in the package README.

This repository intentionally includes the convention, not unused Map or Payment
packages. Empty provider wrappers would increase maintenance without providing
reuse.
