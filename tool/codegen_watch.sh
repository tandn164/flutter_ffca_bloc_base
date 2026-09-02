#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
source tool/package_utils.sh
[[ -n "${PACKAGE:-}" ]] || { echo 'Set PACKAGE, e.g. make codegen-watch PACKAGE=features/sample/sample_data' >&2; exit 1; }
codegen_packages | grep -Fxq "$PACKAGE" || { echo 'PACKAGE must be a codegen-enabled workspace package.' >&2; exit 1; }
cd "$PACKAGE"
exec "${DART_CMD[@]}" run build_runner watch --delete-conflicting-outputs
