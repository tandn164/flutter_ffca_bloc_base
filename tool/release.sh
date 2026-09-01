#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="${APP:-sample_app}"
APP_DIR="$ROOT/apps/$APP_NAME"

[[ -f "$APP_DIR/pubspec.yaml" ]] || { echo "Unknown app: $APP_NAME" >&2; exit 1; }

choose() {
  local prompt="$1"; shift
  local options=("$@") index
  echo "$prompt" >&2
  select value in "${options[@]}"; do
    [[ -n "$value" ]] || continue
    printf '%s\n' "$value"
    return
  done
}

PLATFORM="$(choose "Platform" android ios)"
FLAVOR="$(choose "Flavor" dev stg prod)"
read -r -p "Build name (for example 1.4.0): " BUILD_NAME
read -r -p "Build number (integer): " BUILD_NUMBER
[[ "$BUILD_NAME" =~ ^[0-9]+\.[0-9]+\.[0-9]+([+-][A-Za-z0-9.-]+)?$ ]] || {
  echo "Invalid semantic build name: $BUILD_NAME" >&2; exit 1;
}
[[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || {
  echo "Build number must be an integer." >&2; exit 1;
}

if [[ "$PLATFORM" == "android" ]]; then
  ARTIFACT="$(choose "Android artifact" apk appbundle)"
  DESTINATION="$(choose "Destination" local firebase)"
  (cd "$APP_DIR" && fvm flutter build "$ARTIFACT" \
    --flavor "$FLAVOR" \
    --release \
    --build-name "$BUILD_NAME" \
    --build-number "$BUILD_NUMBER" \
    --dart-define="FLAVOR=$FLAVOR")
  if [[ "$DESTINATION" == "firebase" ]]; then
    command -v firebase >/dev/null 2>&1 || {
      echo "Firebase CLI is required for upload." >&2; exit 1;
    }
    [[ -n "${FIREBASE_APP_ID_ANDROID:-}" ]] || {
      echo "Set FIREBASE_APP_ID_ANDROID." >&2; exit 1;
    }
    if [[ "$ARTIFACT" == "apk" ]]; then
      FILE="$APP_DIR/build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"
    else
      FILE="$APP_DIR/build/app/outputs/bundle/${FLAVOR}Release/app-${FLAVOR}-release.aab"
    fi
    firebase_args=(appdistribution:distribute "$FILE" --app "$FIREBASE_APP_ID_ANDROID")
    if [[ -n "${FIREBASE_GROUPS:-}" ]]; then
      firebase_args+=(--groups "$FIREBASE_GROUPS")
    fi
    firebase "${firebase_args[@]}"
  fi
else
  SIGNING="$(choose "iOS signing" automatic match)"
  DESTINATION="$(choose "Destination" local testflight-internal testflight-external app-store)"
  export FLAVOR BUILD_NAME BUILD_NUMBER SIGNING
  case "$DESTINATION" in
    local)
      (cd "$APP_DIR" && fvm flutter build ipa \
        --flavor "$FLAVOR" \
        --release \
        --build-name "$BUILD_NAME" \
        --build-number "$BUILD_NUMBER" \
        --dart-define="FLAVOR=$FLAVOR")
      ;;
    *)
      command -v bundle >/dev/null 2>&1 || {
        echo "Bundler is required for Fastlane." >&2; exit 1;
      }
      export RELEASE_DESTINATION="$DESTINATION"
      (cd "$APP_DIR/ios" && bundle exec fastlane release)
      ;;
  esac
fi

echo "Release workflow completed for $APP_NAME $BUILD_NAME+$BUILD_NUMBER."
