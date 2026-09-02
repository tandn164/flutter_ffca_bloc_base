#!/usr/bin/env bash
# CI gate: generated sources are committed and must match a fresh generation.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
bash tool/codegen_all.sh
patterns=('*.g.dart' '*.freezed.dart' '*.config.dart' '*.chopper.dart')
git diff --exit-code HEAD -- "${patterns[@]}" || {
  echo 'Generated code is stale. Run make codegen and commit the generated changes.' >&2
  exit 1
}
untracked="$(git ls-files --others --exclude-standard -- "${patterns[@]}")"
if [[ -n "$untracked" ]]; then
  echo 'Generated files must be committed:' >&2
  echo "$untracked" >&2
  exit 1
fi
