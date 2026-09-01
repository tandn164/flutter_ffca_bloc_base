# Google Sheet Localization

The expected sheet columns are `key,en,ja,...`. The sheet must be readable by the
machine running the script (public export or authenticated network proxy).

```bash
export GOOGLE_SHEET_ID=your_sheet_id
export GOOGLE_SHEET_GID=0
make l10n APP=sample_app
```

The workflow downloads CSV, merges translated values into ARB files, validates
missing keys, and runs Flutter localization generation. ARB metadata already in
the app is preserved.

Do not place service-account credentials in Dart source or commit them to the
repository.
