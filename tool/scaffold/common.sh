#!/usr/bin/env bash
set -euo pipefail

scaffold_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

require_name() {
  local label="$1"
  local value="${2:-}"
  if [[ -z "$value" ]]; then
    echo "error: $label is required (e.g. orders, merchant_app)" >&2
    exit 1
  fi
  if [[ ! "$value" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "error: $label must be snake_case: [a-z][a-z0-9_]* (got '$value')" >&2
    exit 1
  fi
}

to_pascal() {
  python3 - <<'PY' "$1"
import sys
print("".join(part.capitalize() for part in sys.argv[1].split("_")))
PY
}

ensure_workspace_line() {
  local file="$1"
  local line="$2"
  if grep -Fq "$line" "$file"; then
    return 0
  fi
  printf '\n%s\n' "$line" >>"$file"
}

remove_workspace_line() {
  local file="$1"
  local line="$2"
  python3 - <<'PY' "$file" "$line"
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
line = sys.argv[2]
text = path.read_text()
lines = [entry for entry in text.splitlines() if entry != line]
path.write_text("\n".join(lines) + ("\n" if lines else ""))
PY
}

ensure_pubspec_dependency() {
  local file="$1"
  local dep_name="$2"
  local dep_path="$3"
  if grep -Fq "${dep_name}:" "$file"; then
    return 0
  fi
  python3 - <<'PY' "$file" "$dep_name" "$dep_path"
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
name, dep_path = sys.argv[2], sys.argv[3]
text = path.read_text()
block = f"  {name}:\n    path: {dep_path}\n"
if re.search(rf"^\s{re.escape(name)}:\s*$", text, flags=re.M):
    raise SystemExit(0)
match = re.search(r"^dev_dependencies:\s*$", text, flags=re.M)
if not match:
    raise SystemExit(f"dev_dependencies not found in {path}")
text = text[: match.start()] + block + text[match.start() :]
path.write_text(text)
PY
}

remove_pubspec_dependency() {
  local file="$1"
  local dep_name="$2"
  if ! grep -Fq "${dep_name}:" "$file"; then
    return 0
  fi
  python3 - <<'PY' "$file" "$dep_name"
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
name = sys.argv[2]
text = path.read_text()
text = re.sub(
    rf"^  {re.escape(name)}:\n    path: [^\n]+\n",
    "",
    text,
    count=1,
    flags=re.M,
)
path.write_text(text)
PY
}
