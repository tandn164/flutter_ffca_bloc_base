# Auth Feature

Reusable credential authentication split into Feature-First Clean Architecture
packages:

- `auth_domain`: entities, repository contract, and use cases.
- `auth_data`: API, repository implementation, token vault, and session implementation.
- `auth_presentation`: configurable Flutter pages and BLoCs.

The app composition root chooses the concrete API client, persistence adapter,
routes, copy, callbacks, and whether authentication is optional or required.

See each package README for layer-specific setup. The integration example lives
in `apps/sample_app/lib/app/features/auth_feature.dart`.
