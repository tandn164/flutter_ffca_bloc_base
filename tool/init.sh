#!/usr/bin/env bash
# make init — idempotent. Does not change JAVA_HOME, Xcode, or shell profiles.
#
#   doctor (prerequisites)
#   install/check FVM
#   fvm install
#   workspace + app pub get
#   setup apps/<APP>/.env
#   code generation
#   iOS dependencies (macOS only)
#   final validation
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail() { echo "error: $*" >&2; exit 1; }
# APP = folder name under apps/ (e.g. sample_app). Override: make init APP=sample_app
APP_NAME="${APP:-sample_app}"
case "$APP_NAME" in
  */*|apps) fail "APP=${APP_NAME} must be an apps/ child name (e.g. sample_app)" ;;
esac
APP_REL="apps/${APP_NAME}"
APP_DIR="$ROOT/$APP_REL"
export APP="$APP_NAME"
cd "$ROOT"
# shellcheck disable=SC1091
source "$ROOT/tool/toolchain.env"
# shellcheck disable=SC1091
source "$ROOT/tool/bootstrap/ruby_env.sh"

FLAVOR="${FLAVOR:-dev}"
OS="$(uname -s)"

info() { echo "==> $*"; }
ok() { echo "✓ $*"; }

[[ -f "$APP_DIR/pubspec.yaml" ]] || fail "APP=${APP_NAME} → ${APP_REL} missing pubspec.yaml"

info "bootstrap prerequisites"
bash "$ROOT/tool/bootstrap/install_prerequisites.sh"
activate_project_ruby || fail "Ruby ${RUBY_VERSION} is not installed through rbenv"
ok "Ruby $(ruby -e 'print RUBY_VERSION') selected by .ruby-version"

info "doctor"
bash "$ROOT/tool/doctor.sh" --prereq

info "install/check FVM"
if ! command -v fvm >/dev/null 2>&1; then
  echo "❌ FVM"
  echo "Expected: FVM on PATH"
  echo "Detected: missing"
  echo
  echo "Suggested fix:"
  echo "  Install FVM from https://fvm.app then re-run: make init"
  exit 1
fi
ok "FVM $(fvm --version 2>/dev/null | head -1)"

info "fvm install ${FLUTTER_VERSION}"
fvm install "$FLUTTER_VERSION"
fvm use "$FLUTTER_VERSION" --force
ok "Flutter SDK ${FLUTTER_VERSION}"

info "workspace pub get"
fvm dart pub get
ok "Dependencies restored (Dart pub workspace)"

info "setup ${APP_REL}/.env"
if [[ -f "$APP_DIR/.env" ]]; then
  ok ".env already exists (not overwritten)"
else
  src="$APP_DIR/.env.example"
  case "$FLAVOR" in
    dev) [[ -f "$APP_DIR/.env.development" ]] && src="$APP_DIR/.env.development" ;;
    stg) [[ -f "$APP_DIR/.env.staging" ]] && src="$APP_DIR/.env.staging" ;;
    prod) [[ -f "$APP_DIR/.env.production" ]] && src="$APP_DIR/.env.production" ;;
  esac
  [[ -f "$src" ]] || fail "missing ${src}"
  cp "$src" "$APP_DIR/.env"
  ok ".env created from ${src#"$ROOT"/}"
fi

info "code generation"
APP="$APP_NAME" bash "$ROOT/tool/codegen_all.sh"
ok "Code generation completed"

info "Ruby dependencies"
project_bundle config set --local path 'vendor/bundle'
project_bundle install
ok "Ruby dependencies ready"

if [[ "$OS" == "Darwin" ]]; then
  info "iOS dependencies"
  (cd "$APP_DIR/ios" && project_bundle exec pod install)
  ok "iOS dependencies ready"
else
  ok "iOS dependencies skipped (${OS})"
fi

info "final validation"
bash "$ROOT/tool/doctor.sh"
(cd "$APP_DIR" && fvm dart analyze lib test)
ok "Environment validation passed"

echo
echo "✓ Flutter SDK ready"
echo "✓ Ruby ${RUBY_VERSION} ready (project-local selection)"
echo "✓ Dependencies restored"
echo "✓ Environment configured"
echo "✓ Code generation completed"
echo "✓ Native dependencies ready"
echo "✓ Environment validation passed"
echo
echo "READY TO DEVELOP"
echo
echo "Run:"
echo "  make run"
