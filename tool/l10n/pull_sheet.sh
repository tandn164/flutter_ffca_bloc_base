#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP_NAME="${APP:-sample_app}"
SHEET_ID="${GOOGLE_SHEET_ID:-}"
SHEET_GID="${GOOGLE_SHEET_GID:-0}"
CSV="$ROOT/tool/l10n/translations.csv"

[[ -n "$SHEET_ID" ]] || {
  echo "Set GOOGLE_SHEET_ID to a readable Google Sheet." >&2
  exit 1
}

URL="https://docs.google.com/spreadsheets/d/${SHEET_ID}/export?format=csv&gid=${SHEET_GID}"
curl --fail --location --silent --show-error "$URL" --output "$CSV"
(cd "$ROOT/apps/$APP_NAME" && dart run "$ROOT/tool/l10n/sheet_to_arb.dart" "$CSV")
(cd "$ROOT/apps/$APP_NAME" && flutter gen-l10n)

echo "Pulled Google Sheet and regenerated ARB/localizations for $APP_NAME."
