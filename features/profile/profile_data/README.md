# Profile Data

Chopper API, DTO mapping, and repository implementation for `profile_domain`.
The app creates the generated API service and injects its shared `DataGateway`.

```bash
dart run build_runner build --delete-conflicting-outputs
dart test features/profile/profile_data
```

Change endpoint paths in this package when they are part of the reusable profile
contract; keep demo-only backend behavior in the demo app.
