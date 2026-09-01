#!/usr/bin/env bash
# Adopt this FFCA base into a real product workspace by renaming flutter_ffca_base.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/tool/scaffold/common.sh"

PACKAGE="${PACKAGE:-${NAME:-}}"
TITLE="${TITLE:-}"
CONFIRM="${CONFIRM:-0}"
BASE_SLUG="${BASE_SLUG:-flutter_ffca_base}"
BASE_TITLE="${BASE_TITLE:-Flutter FFCA Base}"

require_name "PACKAGE" "$PACKAGE"

if [[ "$PACKAGE" == "$BASE_SLUG" ]]; then
  echo "error: PACKAGE must differ from base slug ${BASE_SLUG}" >&2
  exit 1
fi

FROM_SLUG="$BASE_SLUG" \
TO_SLUG="$PACKAGE" \
FROM_TITLE="$BASE_TITLE" \
TO_TITLE="$TITLE" \
CONFIRM="$CONFIRM" \
bash "$ROOT/tool/rename_project_slug.sh"
