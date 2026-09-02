#!/bin/sh

set -eu

case "${CONFIGURATION:-}" in
  *-dev) firebase_flavor=dev ;;
  *-stg) firebase_flavor=stg ;;
  *-prod|Release|Profile|Debug) firebase_flavor=prod ;;
  *)
    echo "error: Cannot resolve Firebase flavor from CONFIGURATION=${CONFIGURATION:-unset}." >&2
    exit 1
    ;;
esac

source_file="${PROJECT_DIR}/Runner/Firebase/${firebase_flavor}/GoogleService-Info.plist"
destination="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/GoogleService-Info.plist"

if [ ! -f "$source_file" ]; then
  if grep -Eq '^[[:space:]]+firebase_core:' "${PROJECT_DIR}/../pubspec.yaml"; then
    echo "error: firebase_core is enabled but ${source_file} is missing." >&2
    exit 1
  fi
  echo "Firebase is not configured for ${firebase_flavor}; skipping plist copy."
  exit 0
fi

mkdir -p "$(dirname "$destination")"
cp "$source_file" "$destination"
echo "Installed Firebase config for ${firebase_flavor}."
