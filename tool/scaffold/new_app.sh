#!/usr/bin/env bash
# Clone apps/<source> to apps/<name> and register it in the Dart workspace.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/tool/scaffold/common.sh"

NAME="${NAME:-}"
SOURCE="${SOURCE:-sample_app}"

require_name "NAME" "$NAME"

if [[ "$NAME" == "$SOURCE" ]]; then
  echo "error: NAME and SOURCE must differ" >&2
  exit 1
fi

SRC_DIR="$ROOT/apps/$SOURCE"
DST_DIR="$ROOT/apps/$NAME"

if [[ ! -f "$SRC_DIR/pubspec.yaml" ]]; then
  echo "error: source app apps/$SOURCE not found" >&2
  exit 1
fi
if [[ -e "$DST_DIR" ]]; then
  echo "error: apps/$NAME already exists" >&2
  exit 1
fi

info() { echo "==> $*"; }

info "copy apps/$SOURCE → apps/$NAME"
rsync -a \
  --exclude '.dart_tool' \
  --exclude 'build' \
  --exclude '.flutter-plugins' \
  --exclude '.flutter-plugins-dependencies' \
  --exclude 'ios/Pods' \
  --exclude 'ios/.symlinks' \
  --exclude 'android/.gradle' \
  --exclude '.env' \
  --exclude 'sample_app.iml' \
  --exclude 'flutter_ffca_base.iml' \
  "$SRC_DIR/" "$DST_DIR/"

info "set Dart package name to $NAME"
python3 - <<'PY' "$DST_DIR/pubspec.yaml" "$NAME"
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
name = sys.argv[2]
text = path.read_text()
text = re.sub(r'^name: .*$', f'name: {name}', text, count=1, flags=re.M)
path.write_text(text)
PY

info "register workspace app"
ensure_workspace_line "$ROOT/pubspec.yaml" "  - apps/$NAME"

if [[ ! -f "$DST_DIR/.env" && -f "$DST_DIR/.env.example" ]]; then
  cp "$DST_DIR/.env.example" "$DST_DIR/.env"
fi

info "dart pub get"
(cd "$ROOT" && fvm dart pub get >/dev/null)

info "register IDE run configuration"
bash "$ROOT/tool/scaffold/register_ide_app.sh" "$NAME"

cat <<EOF

Created apps/${NAME} from apps/${SOURCE}.

Next:
  make init APP=${NAME}
  make run APP=${NAME} FLAVOR=dev
  Trim apps/${NAME}/lib/app/features/${NAME}_features.dart to your feature set
  Update Android applicationId / iOS bundle id if this is a separate product

EOF
