#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="${APP:-sample_app}"
APP_DIR="$ROOT/apps/$APP_NAME"
# shellcheck disable=SC1091
source "$ROOT/tool/toolchain.env"
# shellcheck disable=SC1091
source "$ROOT/tool/bootstrap/ruby_env.sh"

[[ -f "$APP_DIR/pubspec.yaml" ]] || { echo "Unknown app: $APP_NAME" >&2; exit 1; }

choose() {
  local prompt="$1"; shift
  local options=("$@") value
  echo "$prompt" >&2
  select value in "${options[@]}"; do
    [[ -n "$value" ]] || continue
    printf '%s\n' "$value"
    return
  done
}

prompt_value() {
  local variable="$1" prompt="$2" default_value="$3" value
  value="${!variable:-}"
  if [[ -z "$value" ]]; then
    read -r -p "$prompt [$default_value]: " value
    value="${value:-$default_value}"
  fi
  printf -v "$variable" '%s' "$value"
}

validate_one_of() {
  local label="$1" value="$2"; shift 2
  local allowed
  for allowed in "$@"; do
    [[ "$value" == "$allowed" ]] && return
  done
  echo "Invalid $label '$value'. Expected one of: $*." >&2
  exit 1
}

pubspec_version="$(sed -n 's/^version:[[:space:]]*\([^+[:space:]]*\).*/\1/p' "$APP_DIR/pubspec.yaml" | head -n1)"
pubspec_build="$(sed -n 's/^version:[^+]*+\([0-9][0-9]*\).*/\1/p' "$APP_DIR/pubspec.yaml" | head -n1)"
pubspec_version="${pubspec_version:-1.0.0}"
pubspec_build="${pubspec_build:-1}"

PLATFORM="${PLATFORM:-}"
[[ -n "$PLATFORM" ]] || PLATFORM="$(choose "Platform" android ios)"
validate_one_of platform "$PLATFORM" android ios

FLAVOR="${FLAVOR:-}"
[[ -n "$FLAVOR" ]] || FLAVOR="$(choose "Flavor" dev stg prod)"
validate_one_of flavor "$FLAVOR" dev stg prod

prompt_value BUILD_NAME "Build name" "$pubspec_version"
prompt_value BUILD_NUMBER "Build number" "$pubspec_build"
[[ "$BUILD_NAME" =~ ^[0-9]+\.[0-9]+\.[0-9]+([+-][A-Za-z0-9.-]+)?$ ]] || {
  echo "Invalid semantic build name: $BUILD_NAME" >&2; exit 1;
}
[[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || {
  echo "Build number must be an integer." >&2; exit 1;
}

DESTINATION="${DESTINATION:-}"
if [[ "$PLATFORM" == "android" ]]; then
  [[ -n "$DESTINATION" ]] || DESTINATION="$(choose "Destination" export-apk export-aab firebase)"
  validate_one_of destination "$DESTINATION" export-apk export-aab firebase
  ARTIFACT="${ARTIFACT:-$([[ "$DESTINATION" == "export-aab" ]] && echo appbundle || echo apk)}"
  validate_one_of artifact "$ARTIFACT" apk appbundle
  if [[ "$DESTINATION" == "export-apk" && "$ARTIFACT" != "apk" ]] ||
     [[ "$DESTINATION" == "export-aab" && "$ARTIFACT" != "appbundle" ]]; then
    echo "Destination $DESTINATION requires its matching artifact." >&2
    exit 1
  fi
else
  [[ -n "$DESTINATION" ]] || DESTINATION="$(choose "Destination" export-ipa firebase testflight-internal testflight-external app-store)"
  validate_one_of destination "$DESTINATION" export-ipa firebase testflight-internal testflight-external app-store
  ARTIFACT="ipa"
  SIGNING="${SIGNING:-}"
  [[ -n "$SIGNING" ]] || SIGNING="$(choose "iOS signing" automatic match)"
  validate_one_of signing "$SIGNING" automatic match
fi

RELEASE_NOTES="${RELEASE_NOTES:-$(git -C "$ROOT" log -1 --pretty=%s 2>/dev/null || true)}"
RELEASE_NOTES="${RELEASE_NOTES:-$APP_NAME $BUILD_NAME+$BUILD_NUMBER}"

if [[ "$DESTINATION" == "firebase" ]]; then
  command -v python3 >/dev/null 2>&1 || { echo "Python 3 is required to read Firebase config. Run make init." >&2; exit 1; }
  FIREBASE_APP_ID="$(python3 "$ROOT/tool/release/firebase_app_id.py" "$APP_DIR" "$PLATFORM" "$FLAVOR")"
  export FIREBASE_APP_ID
  FIREBASE_GROUPS="${FIREBASE_GROUPS:-}"
  if [[ -n "${FIREBASE_SERVICE_CREDENTIALS_FILE:-}" ]]; then
    # Fastlane changes directories; resolve user-supplied relative paths now.
    FIREBASE_SERVICE_CREDENTIALS_FILE="$(python3 -c 'import os,sys; print(os.path.abspath(os.path.expanduser(sys.argv[1])))' "$FIREBASE_SERVICE_CREDENTIALS_FILE")"
    [[ -r "$FIREBASE_SERVICE_CREDENTIALS_FILE" ]] || { echo "Cannot read Firebase service-account credential: $FIREBASE_SERVICE_CREDENTIALS_FILE" >&2; exit 1; }
    export FIREBASE_SERVICE_CREDENTIALS_FILE
  fi
fi

echo
echo "Release summary"
echo "  app:         $APP_NAME"
echo "  platform:    $PLATFORM"
echo "  flavor:      $FLAVOR"
echo "  version:     $BUILD_NAME+$BUILD_NUMBER"
echo "  destination: $DESTINATION"
echo "  artifact:    $ARTIFACT"
[[ "$PLATFORM" == "ios" ]] && echo "  signing:     $SIGNING"
[[ "$DESTINATION" == "firebase" ]] && echo "  groups:      ${FIREBASE_GROUPS:-<none>}"
[[ "$DESTINATION" == "firebase" ]] && echo "  Firebase ID: $FIREBASE_APP_ID"
echo "  notes:       $RELEASE_NOTES"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo "Dry run complete; authentication/network access was not checked; nothing was built or uploaded."
  exit 0
fi

command -v fvm >/dev/null 2>&1 || { echo "FVM is required. Run make init." >&2; exit 1; }
activate_project_ruby || { echo "Project Ruby $RUBY_VERSION is required. Run make init." >&2; exit 1; }
command -v bundle >/dev/null 2>&1 || { echo "Bundler $BUNDLER_VERSION is required. Run make init." >&2; exit 1; }
(cd "$ROOT" && project_bundle check >/dev/null) || {
  echo "Ruby dependencies are missing. Run: bundle install" >&2; exit 1;
}

if [[ "$DESTINATION" == "firebase" ]]; then
  echo "Checking Firebase authentication and app access before building (read-only)..."
  if ! (cd "$ROOT" && project_bundle exec ruby tool/release/firebase_preflight.rb); then
    echo "Google Service config identifies the destination app; it does not grant upload permission." >&2
    echo "Local setup: install Firebase CLI (https://firebase.google.com/docs/cli), then run: firebase login" >&2
    echo "Expired/wrong account: firebase login --reauth" >&2
    echo "CI alternative: set FIREBASE_SERVICE_CREDENTIALS_FILE to an absolute service-account JSON path with Firebase App Distribution Admin access." >&2
    echo "If already authenticated, check the app ID, enable App Distribution in Firebase Console, and check IAM/network access." >&2
    echo "Guide: $ROOT/tool/release/README.md (First-time Firebase setup). No build or upload has started." >&2
    if [[ -t 0 && -z "${CI:-}" && "${CONFIRM:-0}" != "1" && -z "${FIREBASE_SERVICE_CREDENTIALS_FILE:-}${FIREBASE_TOKEN:-}${GOOGLE_APPLICATION_CREDENTIALS:-}" ]] && command -v firebase >/dev/null 2>&1; then
      read -r -p "Open Firebase login now? [y/N]: " answer
      [[ "$answer" =~ ^[Yy]$ ]] || exit 1
      firebase login --reauth
      (cd "$ROOT" && project_bundle exec ruby tool/release/firebase_preflight.rb) || exit 1
    else
      exit 1
    fi
  fi
fi
if [[ "$DESTINATION" == "testflight-external" && -z "${TESTFLIGHT_GROUPS:-}" ]]; then
  echo "Set TESTFLIGHT_GROUPS for an external TestFlight release." >&2
  exit 1
fi
if [[ "$PLATFORM" == "android" && "$FLAVOR" == "prod" ]]; then
  if grep -q 'signingConfigs.getByName("debug")' "$APP_DIR/android/app/build.gradle.kts"; then
    echo "warning: prod currently uses the Android debug signing key." >&2
  fi
fi

if [[ "${CONFIRM:-0}" != "1" ]]; then
  read -r -p "Continue with this release? [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]] || { echo "Release cancelled."; exit 0; }
fi

export APP_NAME FLAVOR BUILD_NAME BUILD_NUMBER DESTINATION ARTIFACT RELEASE_NOTES
export FIREBASE_APP_ID="${FIREBASE_APP_ID:-}" FIREBASE_GROUPS="${FIREBASE_GROUPS:-}"
export FIREBASE_SERVICE_CREDENTIALS_FILE="${FIREBASE_SERVICE_CREDENTIALS_FILE:-}"
export SIGNING="${SIGNING:-automatic}" TESTFLIGHT_GROUPS="${TESTFLIGHT_GROUPS:-}"
export CHANGELOG="${CHANGELOG:-$RELEASE_NOTES}"
export FASTLANE_SKIP_UPDATE_CHECK=1

platform_dir="$APP_DIR/$PLATFORM"
(cd "$platform_dir" && project_bundle exec fastlane "$PLATFORM" release)

echo "Release completed for $APP_NAME $BUILD_NAME+$BUILD_NUMBER ($DESTINATION)."
