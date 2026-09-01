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

echo "==> gen-l10n $APP_DIR"
(cd "$APP_DIR" && "${FLUTTER_CMD[@]}" gen-l10n)

while IFS= read -r package; do
  echo "==> build_runner $package"
  (cd "$package" && "${DART_CMD[@]}" run build_runner build --delete-conflicting-outputs)
done < <(codegen_packages)
