#!/usr/bin/env bash
# Analyze the demo app and every active package. Fail on the first error.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
# shellcheck disable=SC1091
source "$root/tool/package_utils.sh"

# APP = folder name under apps/ (default sample_app). Override: make lint APP=sample_app
APP_NAME="${APP:-sample_app}"
case "$APP_NAME" in
  */*|apps)
    echo "error: APP=${APP_NAME} must be an apps/ child name (e.g. sample_app)" >&2
    exit 1
    ;;
esac
APP="apps/${APP_NAME}"

analyze() {
  local dir="$1"
  echo "==> analyze $dir"
  (cd "$dir" && "${DART_CMD[@]}" analyze)
}

analyze "$APP"
while IFS= read -r package; do
  analyze "$package"
done < <(workspace_library_packages)
