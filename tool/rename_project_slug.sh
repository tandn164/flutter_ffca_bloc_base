#!/usr/bin/env bash
# Replace a workspace slug (e.g. flutter_ffca_base) across the repo.
# Used by adopt_project.sh when forking this base into a real product workspace.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/tool/scaffold/common.sh"

FROM_SLUG="${FROM_SLUG:-${FROM:-}}"
TO_SLUG="${TO_SLUG:-${TO:-${PACKAGE:-}}}"
FROM_TITLE="${FROM_TITLE:-}"
TO_TITLE="${TO_TITLE:-${TITLE:-}}"
CONFIRM="${CONFIRM:-0}"

require_name "FROM_SLUG" "$FROM_SLUG"
require_name "TO_SLUG" "$TO_SLUG"

if [[ "$FROM_SLUG" == "$TO_SLUG" ]]; then
  echo "error: FROM_SLUG and TO_SLUG must differ" >&2
  exit 1
fi

if [[ "$CONFIRM" != "1" ]]; then
  cat <<EOF
This renames workspace slug "${FROM_SLUG}" → "${TO_SLUG}" across source, native IDs, and IDE files.

Run with confirmation:
  CONFIRM=1 bash tool/rename_project_slug.sh FROM_SLUG=${FROM_SLUG} TO_SLUG=${TO_SLUG}

Or adopt this base into a product workspace:
  CONFIRM=1 make adopt-project PACKAGE=${TO_SLUG} TITLE="My Product"

EOF
  exit 1
fi

slug_to_camel() {
  python3 - <<'PY' "$1"
import sys

parts = sys.argv[1].split("_")
if not parts:
    raise SystemExit(1)
print(parts[0] + "".join(part.capitalize() for part in parts[1:]))
PY
}

FROM_CAMEL="$(slug_to_camel "$FROM_SLUG")"
TO_CAMEL="$(slug_to_camel "$TO_SLUG")"

if [[ -z "$TO_TITLE" && -n "$FROM_TITLE" ]]; then
  TO_TITLE="$(python3 - <<'PY' "$TO_SLUG"
import sys
print(" ".join(part.capitalize() for part in sys.argv[1].split("_")))
PY
)"
fi

info() { echo "==> $*"; }

info "replace text references ${FROM_SLUG} → ${TO_SLUG}"
python3 - <<'PY' "$ROOT" "$FROM_SLUG" "$TO_SLUG" "$FROM_CAMEL" "$TO_CAMEL" "$FROM_TITLE" "$TO_TITLE"
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
from_slug, to_slug = sys.argv[2], sys.argv[3]
from_camel, to_camel = sys.argv[4], sys.argv[5]
from_title, to_title = sys.argv[6], sys.argv[7]

skip_dirs = {
    ".git",
    ".dart_tool",
    "build",
    ".gradle",
    "Pods",
    ".symlinks",
    ".fvm",
    ".pub",
    "node_modules",
}

text_suffixes = {
    ".dart",
    ".yaml",
    ".yml",
    ".md",
    ".sh",
    ".json",
    ".xml",
    ".iml",
    ".plist",
    ".pbxproj",
    ".kts",
    ".kt",
    ".gradle",
    ".properties",
    ".env",
    ".example",
    ".development",
    ".staging",
    ".production",
    ".arb",
    "Appfile",
    "Fastfile",
    "Makefile",
    "Gemfile",
    "Podfile",
    "Podfile.lock",
}

pairs = [
    (f"{from_slug}_workspace", f"{to_slug}_workspace"),
    (f"com.company.{from_slug}", f"com.company.{to_slug}"),
    (f"com.company.{from_camel}", f"com.company.{to_camel}"),
    (f"com.company.{from_slug}", f"com.company.{to_slug}"),
    (from_slug, to_slug),
]
if from_title and to_title and from_title != to_title:
    pairs.append((from_title, to_title))

changed = 0
for path in root.rglob("*"):
    if not path.is_file():
        continue
    if any(part in skip_dirs for part in path.parts):
        continue
    if path.suffix and path.suffix not in text_suffixes and path.name not in text_suffixes:
        continue
    try:
        text = path.read_text()
    except (UnicodeDecodeError, OSError):
        continue
    original = text
    for old, new in pairs:
        text = text.replace(old, new)
    if text != original:
        path.write_text(text)
        changed += 1

print(f"updated {changed} files")
PY

while IFS= read -r -d '' kotlin_root; do
  from_dir="$kotlin_root/$FROM_SLUG"
  to_dir="$kotlin_root/$TO_SLUG"
  if [[ -d "$from_dir" && ! -d "$to_dir" ]]; then
    info "move Kotlin package $(basename "$(dirname "$from_dir")")/${FROM_SLUG} → ${TO_SLUG}"
    mv "$from_dir" "$to_dir"
  fi
done < <(find "$ROOT/apps" -type d -path '*/android/app/src/main/kotlin/*' -print0 2>/dev/null || true)

from_iml="$ROOT/${FROM_SLUG}.iml"
to_iml="$ROOT/${TO_SLUG}.iml"
if [[ -f "$from_iml" ]]; then
  info "rename root module ${FROM_SLUG}.iml → ${TO_SLUG}.iml"
  mv "$from_iml" "$to_iml"
fi

info "dart pub get"
(cd "$ROOT" && fvm dart pub get >/dev/null)

cat <<EOF

Renamed workspace slug ${FROM_SLUG} → ${TO_SLUG}.

Next:
  Review git diff
  Update Android/iOS signing if bundle IDs changed
  Restart Android Studio

EOF
