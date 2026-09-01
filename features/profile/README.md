# Profile Feature

Reusable profile loading, editing, and sign-out UI split into
`profile_domain`, `profile_data`, and `profile_presentation`.

The app owns route placement, session wiring, overlays, and any product-specific
profile actions. See `apps/sample_app/lib/app/features/profile_feature.dart`.
