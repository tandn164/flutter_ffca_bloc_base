#!/usr/bin/env bash
# First-time / repair setup for ComposableCore dev environment.
# Usage: tool/env/setup_env.sh

set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "==> ComposableCore setup"
echo ""

# 1. FVM + pinned Flutter
if command -v fvm >/dev/null 2>&1 && [[ -f "${ROOT_DIR}/.fvm/fvm_config.json" ]]; then
  FLUTTER_PIN="$(python3 -c "import json; print(json.load(open('.fvm/fvm_config.json'))['flutterSdkVersion'])" 2>/dev/null || echo "3.32.8")"
  echo "==> FVM: install Flutter ${FLUTTER_PIN}"
  fvm install "${FLUTTER_PIN}" || true
  fvm use "${FLUTTER_PIN}" || true
else
  echo "==> FVM not found — using system flutter (install: https://fvm.app)"
fi

FLUTTER_CMD="flutter"
if command -v fvm >/dev/null 2>&1 && [[ -f "${ROOT_DIR}/.fvm/fvm_config.json" ]]; then
  FLUTTER_CMD="fvm flutter"
fi

# 2. melos (for future monorepo)
if ! command -v melos >/dev/null 2>&1; then
  echo "==> Installing melos globally"
  dart pub global activate melos || true
  if [[ ":$PATH:" != *":${HOME}/.pub-cache/bin:"* ]]; then
    echo "    Add to PATH: export PATH=\"\$PATH:${HOME}/.pub-cache/bin\""
  fi
fi

# 3. .env
if [[ ! -f "${ROOT_DIR}/.env" ]]; then
  echo "==> Creating .env from .env.example"
  cp "${ROOT_DIR}/.env.example" "${ROOT_DIR}/.env"
fi

# 4. composable sync + bootstrap
echo "==> composable sync"
dart run tool/composable_sync.dart

if command -v melos >/dev/null 2>&1; then
  echo "==> melos bootstrap"
  melos bootstrap
else
  echo "==> flutter pub get"
  $FLUTTER_CMD pub get
fi

# 6. codegen
echo "==> codegen"
$FLUTTER_CMD gen-l10n
if grep -q "build_runner" pubspec.yaml 2>/dev/null; then
  $FLUTTER_CMD pub run build_runner build --delete-conflicting-outputs || true
fi

# 7. CocoaPods (macOS)
if [[ "$(uname -s)" == "Darwin" ]] && [[ -f "${ROOT_DIR}/ios/Podfile" ]]; then
  echo "==> pod install (ios)"
  (cd ios && pod install) || echo "    pod install failed — install CocoaPods and retry: make pods"
fi

echo ""
echo "==> Final check"
bash "${ROOT_DIR}/tool/env/check_env.sh" || true

echo ""
echo "Done. Run: make run"
