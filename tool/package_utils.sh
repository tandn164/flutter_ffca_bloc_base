#!/usr/bin/env bash

set -euo pipefail

if [[ "${USE_SYSTEM_SDK:-0}" == "1" ]]; then
  DART_CMD=(dart)
  FLUTTER_CMD=(flutter)
else
  DART_CMD=(fvm dart)
  FLUTTER_CMD=(fvm flutter)
fi

workspace_library_packages() {
  find shared features \
    -type f \
    -name pubspec.yaml \
    -not -path '*/build/*' \
    -not -path '*/.dart_tool/*' \
    -print \
    | sed 's#/pubspec.yaml$##' \
    | LC_ALL=C sort
}

codegen_packages() {
  find shared features "apps/${APP:-sample_app}" \
    -type f \
    -name pubspec.yaml \
    -not -path '*/build/*' \
    -not -path '*/.dart_tool/*' \
    -print \
    | LC_ALL=C sort \
    | while IFS= read -r pubspec; do
        if grep -q '^  build_runner:' "$pubspec"; then
          dirname "$pubspec"
        fi
      done
}

is_flutter_package() {
  grep -q 'sdk:[[:space:]]*flutter' "$1/pubspec.yaml"
}

has_tests() {
  [[ -d "$1/test" ]] && find "$1/test" -type f -name '*_test.dart' -print -quit | grep -q .
}
