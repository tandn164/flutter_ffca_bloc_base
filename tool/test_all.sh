#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# shellcheck disable=SC1091
source "$ROOT/tool/package_utils.sh"

APP_NAME="${APP:-sample_app}"
APP_DIR="apps/${APP_NAME}"
[[ -f "$APP_DIR/pubspec.yaml" ]] || {
  echo "error: ${APP_DIR} missing pubspec.yaml" >&2
  exit 1
}

echo "==> test $APP_DIR"
(cd "$APP_DIR" && "${FLUTTER_CMD[@]}" test)

while IFS= read -r package; do
  has_tests "$package" || continue
  echo "==> test $package"
  if is_flutter_package "$package"; then
    (cd "$package" && "${FLUTTER_CMD[@]}" test)
  else
    (cd "$package" && "${DART_CMD[@]}" test)
  fi
done < <(workspace_library_packages)
