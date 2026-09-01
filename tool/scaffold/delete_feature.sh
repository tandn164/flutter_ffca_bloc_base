#!/usr/bin/env bash
# Remove features/<name> and optionally unwire it from an app manifest.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/tool/scaffold/common.sh"

NAME="${NAME:-}"
APP="${APP:-sample_app}"
WIRE="${WIRE:-1}"
CONFIRM="${CONFIRM:-0}"
PROTECTED="${PROTECTED:-auth,feed,profile,onboarding}"

require_name "NAME" "$NAME"

IFS=',' read -r -a protected_features <<<"$PROTECTED"
for protected in "${protected_features[@]}"; do
  if [[ "$NAME" == "$protected" ]]; then
    echo "error: refusing to delete protected feature '$NAME'" >&2
    exit 1
  fi
done

FEATURE_DIR="$ROOT/features/$NAME"
if [[ ! -d "$FEATURE_DIR" ]]; then
  echo "error: features/$NAME not found" >&2
  exit 1
fi

APP_DIR="$ROOT/apps/$APP"
if [[ "$WIRE" == "1" && ! -f "$APP_DIR/pubspec.yaml" ]]; then
  echo "error: apps/$APP not found" >&2
  exit 1
fi

if [[ "$WIRE" == "1" ]]; then
  while IFS= read -r -d '' pubspec; do
    app_name="$(basename "$(dirname "$pubspec")")"
    [[ "$app_name" == "$APP" ]] && continue
    if grep -Fq "${NAME}_domain:" "$pubspec"; then
      echo "error: apps/$app_name still depends on ${NAME}; remove wiring there first or use WIRE=0" >&2
      exit 1
    fi
  done < <(find "$ROOT/apps" -name pubspec.yaml -print0)
fi

if [[ "$CONFIRM" != "1" ]]; then
  cat <<EOF
This will permanently delete features/${NAME} and remove workspace entries.
$( [[ "$WIRE" == "1" ]] && echo "It will also unwire apps/${APP} (adapter, pubspec, manifest, boundary test)." )

Run with confirmation:
  CONFIRM=1 make delete-feature NAME=${NAME} APP=${APP}

Packages only (keep app wiring to remove manually):
  CONFIRM=1 WIRE=0 make delete-feature NAME=${NAME}

EOF
  exit 1
fi

PASCAL="$(to_pascal "$NAME")"

info() { echo "==> $*"; }

if [[ "$WIRE" == "1" ]]; then
  info "unwire apps/$APP"
  remove_pubspec_dependency "$APP_DIR/pubspec.yaml" "${NAME}_domain"
  remove_pubspec_dependency "$APP_DIR/pubspec.yaml" "${NAME}_data"
  remove_pubspec_dependency "$APP_DIR/pubspec.yaml" "${NAME}_presentation"

  ADAPTER="$APP_DIR/lib/app/features/${NAME}_feature.dart"
  if [[ -f "$ADAPTER" ]]; then
    info "remove adapter ${NAME}_feature.dart"
    rm -f "$ADAPTER"
  fi

  MANIFEST="$APP_DIR/lib/app/features/${APP}_features.dart"
  if [[ ! -f "$MANIFEST" ]]; then
    MANIFEST="$(find "$APP_DIR/lib/app/features" -maxdepth 1 -name '*_features.dart' | head -n1)"
  fi
  if [[ -n "$MANIFEST" && -f "$MANIFEST" ]]; then
    info "update feature manifest $(basename "$MANIFEST")"
    python3 - <<'PY' "$MANIFEST" "$NAME" "$PASCAL"
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
name, pascal = sys.argv[2], sys.argv[3]
lines = path.read_text().splitlines()
filtered = []
for line in lines:
    stripped = line.strip()
    if stripped == f"import '{name}_feature.dart';":
        continue
    if stripped == f"register{pascal}Dependencies(sl);":
        continue
    if stripped == f"...create{pascal}Routes(sl),":
        continue
    if stripped == f"create{pascal}Branch(sl),":
        continue
    filtered.append(line)

text = "\n".join(filtered) + "\n"
text = re.sub(r"\n{3,}", "\n\n", text)
path.write_text(text)
PY
  fi

  BOUNDARY_TEST="$APP_DIR/test/app/package_boundary_test.dart"
  if [[ -f "$BOUNDARY_TEST" ]]; then
    info "update package boundary test"
    python3 - <<'PY' "$BOUNDARY_TEST" "$NAME"
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
name = sys.argv[2]
text = path.read_text()
pattern = r"for \(final feature in \[([^\]]*)\]\)"
match = re.search(pattern, text)
if not match:
    raise SystemExit(0)
items = [item.strip().strip("'") for item in match.group(1).split(",") if item.strip()]
if name not in items:
    raise SystemExit(0)
items = [item for item in items if item != name]
replacement = "for (final feature in [" + ", ".join(f"'{item}'" for item in items) + "])"
text = re.sub(pattern, replacement, text, count=1)
path.write_text(text)
PY
  fi
fi

info "unregister workspace packages"
remove_workspace_line "$ROOT/pubspec.yaml" "  - features/${NAME}/${NAME}_domain"
remove_workspace_line "$ROOT/pubspec.yaml" "  - features/${NAME}/${NAME}_data"
remove_workspace_line "$ROOT/pubspec.yaml" "  - features/${NAME}/${NAME}_presentation"

info "remove features/$NAME"
rm -rf "$FEATURE_DIR"

info "dart pub get"
(cd "$ROOT" && fvm dart pub get >/dev/null)

cat <<EOF

Removed features/${NAME}.
$( [[ "$WIRE" == "1" ]] && echo "Unwired from apps/${APP}." )

Next:
  make lint APP=${APP}
  make test APP=${APP}

EOF
