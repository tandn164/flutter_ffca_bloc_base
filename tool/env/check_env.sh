#!/usr/bin/env bash
# Verify local machine matches composable_environment.json requirements.
# Usage: tool/env/check_env.sh [--soft]
#   --soft  Collect all issues but exit 0 (used by make setup mid-run)

set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

SOFT=false
if [[ "${1:-}" == "--soft" ]]; then
  SOFT=true
fi

ENV_FILE="${ROOT_DIR}/composable_environment.json"
CONFIG_FILE="${ROOT_DIR}/composable_config.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0
warnings=0

ok()   { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; errors=$((errors + 1)); }
warn() { echo -e "${YELLOW}!${NC} $1"; warnings=$((warnings + 1)); }

version_ge() {
  # Returns 0 if $1 >= $2 (semver-ish numeric segments)
  local a="$1" b="$2"
  if [[ "$(printf '%s\n%s\n' "$b" "$a" | sort -V | head -1)" == "$b" ]]; then
    return 0
  fi
  return 1
}

read_json_field() {
  local file="$1" key="$2"
  python3 -c "
import json, sys
data = json.load(open('$file'))
keys = '$key'.split('.')
v = data
for k in keys:
    v = v[k]
print(v)
" 2>/dev/null
}

echo "ComposableCore environment check"
echo "========================"

if [[ ! -f "$ENV_FILE" ]]; then
  fail "composable_environment.json not found"
else
  ok "composable_environment.json found"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  fail "composable_config.json not found"
else
  ok "composable_config.json found"
  if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$CONFIG_FILE" >/dev/null 2>&1; then
      ok "composable_config.json is valid JSON"
    else
      fail "composable_config.json is invalid JSON"
    fi
  fi
fi

# --- Flutter (prefer FVM) ---
EXPECTED_FLUTTER=""
if [[ -f "$ENV_FILE" ]] && command -v python3 >/dev/null 2>&1; then
  EXPECTED_FLUTTER="$(read_json_field "$ENV_FILE" "flutter" || true)"
fi

FLUTTER_CMD=""
if [[ -f "${ROOT_DIR}/.fvm/fvm_config.json" ]] && command -v fvm >/dev/null 2>&1; then
  if [[ -d "${ROOT_DIR}/.fvm/flutter_sdk" ]] || fvm list 2>/dev/null | grep -q "3.32"; then
    FLUTTER_CMD="fvm flutter"
  fi
fi
if [[ -z "$FLUTTER_CMD" ]] && command -v flutter >/dev/null 2>&1; then
  FLUTTER_CMD="flutter"
fi

if [[ -z "$FLUTTER_CMD" ]]; then
  fail "Flutter not found — run: make setup"
else
  ACTUAL_FLUTTER="$($FLUTTER_CMD --version 2>/dev/null | head -1 | awk '{print $2}')"
  if [[ -n "$EXPECTED_FLUTTER" && "$ACTUAL_FLUTTER" != "$EXPECTED_FLUTTER" ]]; then
    fail "Flutter: expected ${EXPECTED_FLUTTER}, got ${ACTUAL_FLUTTER} — run: fvm install && fvm use ${EXPECTED_FLUTTER}"
  else
    ok "Flutter ${ACTUAL_FLUTTER} (${FLUTTER_CMD})"
  fi
fi

# --- Dart ---
if [[ -n "$FLUTTER_CMD" ]]; then
  ACTUAL_DART="$($FLUTTER_CMD --version 2>/dev/null | grep -i '^Tools' | sed -n 's/.*Dart \([^ ]*\).*/\1/p')"
  if [[ -n "$ACTUAL_DART" ]]; then
    ok "Dart ${ACTUAL_DART}"
  else
    warn "Could not detect Dart version"
  fi
fi

# --- melos (workspace) ---
if dart run melos --version >/dev/null 2>&1; then
  ok "melos $(dart run melos --version 2>/dev/null | head -1)"
elif command -v melos >/dev/null 2>&1; then
  ok "melos $(melos --version 2>/dev/null | head -1)"
else
  warn "melos not available — run: flutter pub get (melos is a dev_dependency)"
fi

# --- CocoaPods (macOS + iOS) ---
if [[ "$(uname -s)" == "Darwin" ]]; then
  if command -v pod >/dev/null 2>&1; then
    POD_VER="$(pod --version 2>/dev/null | tr -d '\n')"
    EXPECTED_POD=""
    if [[ -f "$ENV_FILE" ]] && command -v python3 >/dev/null 2>&1; then
      EXPECTED_POD="$(read_json_field "$ENV_FILE" "cocoapods" | sed 's/>=//')"
    fi
    if [[ -n "$EXPECTED_POD" ]] && ! version_ge "$POD_VER" "$EXPECTED_POD"; then
      fail "CocoaPods: expected >= ${EXPECTED_POD}, got ${POD_VER}"
    else
      ok "CocoaPods ${POD_VER}"
    fi
  else
    warn "CocoaPods not found (needed for iOS) — run: sudo gem install cocoapods"
  fi

  if command -v xcodebuild >/dev/null 2>&1; then
    XCODE_VER="$(xcodebuild -version 2>/dev/null | head -1 | awk '{print $2}')"
    ok "Xcode ${XCODE_VER}"
  else
    warn "Xcode not found (needed for iOS builds)"
  fi
fi

# --- Java (Android) ---
if command -v java >/dev/null 2>&1; then
  JAVA_VER="$(java -version 2>&1 | head -1 | sed -n 's/.*version "\([^"]*\)".*/\1/p')"
  ok "Java ${JAVA_VER}"
else
  warn "Java not found (needed for Android builds)"
fi

# --- .env ---
if [[ -f "${ROOT_DIR}/.env" ]]; then
  ok ".env exists"
else
  fail ".env missing — run: make env-dev  (or: cp .env.example .env)"
fi

# --- Generated l10n ---
if [[ -f "${ROOT_DIR}/lib/generated/l10n/l10n.dart" ]]; then
  ok "Generated l10n found"
else
  warn "Generated l10n missing — run: make codegen"
fi

echo "========================"
if [[ $errors -gt 0 ]]; then
  echo -e "${RED}${errors} error(s)${NC}, ${warnings} warning(s)"
  if $SOFT; then
    exit 0
  fi
  exit 1
fi

echo -e "${GREEN}Environment OK${NC} (${warnings} warning(s))"
exit 0
