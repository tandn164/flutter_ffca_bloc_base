#!/usr/bin/env bash
# Scaffold features/<name>/{domain,data,presentation} and wire into an app manifest.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/tool/scaffold/common.sh"

NAME="${NAME:-}"
APP="${APP:-sample_app}"
WIRE="${WIRE:-1}"
ROUTE_KIND="${ROUTE_KIND:-public}" # public | tab

require_name "NAME" "$NAME"

if [[ -d "$ROOT/features/$NAME" ]]; then
  echo "error: features/$NAME already exists" >&2
  exit 1
fi

APP_DIR="$ROOT/apps/$APP"
if [[ ! -f "$APP_DIR/pubspec.yaml" ]]; then
  echo "error: apps/$APP not found" >&2
  exit 1
fi

PASCAL="$(to_pascal "$NAME")"
FEATURE_ROOT="$ROOT/features/$NAME"

info() { echo "==> $*"; }

write_analysis_options() {
  local dir="$1"
  cat >"$dir/analysis_options.yaml" <<'YAML'
include: package:lints/recommended.yaml
YAML
}

info "create features/$NAME packages"
mkdir -p \
  "$FEATURE_ROOT/${NAME}_domain/lib/src" \
  "$FEATURE_ROOT/${NAME}_domain/test" \
  "$FEATURE_ROOT/${NAME}_data/lib/src" \
  "$FEATURE_ROOT/${NAME}_data/test" \
  "$FEATURE_ROOT/${NAME}_presentation/lib/src" \
  "$FEATURE_ROOT/${NAME}_presentation/test"

write_analysis_options "$FEATURE_ROOT/${NAME}_domain"
write_analysis_options "$FEATURE_ROOT/${NAME}_data"
write_analysis_options "$FEATURE_ROOT/${NAME}_presentation"

cat >"$FEATURE_ROOT/${NAME}_domain/pubspec.yaml" <<YAML
name: ${NAME}_domain
description: Pure Dart ${NAME} contracts and use cases.
version: 1.0.0
publish_to: "none"

environment:
  sdk: ^3.6.0
resolution: workspace

dev_dependencies:
  lints: ^6.0.0
  test: ^1.25.0
YAML

cat >"$FEATURE_ROOT/${NAME}_data/pubspec.yaml" <<YAML
name: ${NAME}_data
description: Data implementation for ${NAME}.
version: 1.0.0
publish_to: "none"

environment:
  sdk: ^3.6.0
resolution: workspace

dependencies:
  ${NAME}_domain:
    path: ../${NAME}_domain

dev_dependencies:
  lints: ^6.0.0
  test: ^1.25.0
YAML

cat >"$FEATURE_ROOT/${NAME}_presentation/pubspec.yaml" <<YAML
name: ${NAME}_presentation
description: Flutter UI for ${NAME}.
version: 1.0.0
publish_to: "none"

environment:
  sdk: ^3.6.0
  flutter: ">=3.16.0"
resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  ${NAME}_domain:
    path: ../${NAME}_domain

dev_dependencies:
  flutter_lints: ^6.0.0
  flutter_test:
    sdk: flutter
YAML

cat >"$FEATURE_ROOT/${NAME}_domain/lib/${NAME}_domain.dart" <<DART
export 'src/${NAME}_repository.dart';
export 'src/${NAME}_use_cases.dart';
DART

cat >"$FEATURE_ROOT/${NAME}_domain/lib/src/${NAME}_repository.dart" <<DART
abstract class ${PASCAL}Repository {
  Future<List<String>> listItems();
}
DART

cat >"$FEATURE_ROOT/${NAME}_domain/lib/src/${NAME}_use_cases.dart" <<DART
import '${NAME}_repository.dart';

class List${PASCAL}Items {
  const List${PASCAL}Items(this.repository);

  final ${PASCAL}Repository repository;

  Future<List<String>> call() => repository.listItems();
}
DART

cat >"$FEATURE_ROOT/${NAME}_domain/test/${NAME}_use_cases_test.dart" <<DART
import 'package:${NAME}_domain/${NAME}_domain.dart';
import 'package:test/test.dart';

class _Fake${PASCAL}Repository implements ${PASCAL}Repository {
  @override
  Future<List<String>> listItems() async => const ['sample'];
}

void main() {
  test('List${PASCAL}Items delegates to repository', () async {
    final items = await List${PASCAL}Items(_Fake${PASCAL}Repository())();
    expect(items, ['sample']);
  });
}
DART

cat >"$FEATURE_ROOT/${NAME}_data/lib/${NAME}_data.dart" <<DART
export 'src/${NAME}_repository_impl.dart';
DART

cat >"$FEATURE_ROOT/${NAME}_data/lib/src/${NAME}_repository_impl.dart" <<DART
import 'package:${NAME}_domain/${NAME}_domain.dart';

class ${PASCAL}RepositoryImpl implements ${PASCAL}Repository {
  const ${PASCAL}RepositoryImpl();

  @override
  Future<List<String>> listItems() async => const [];
}
DART

cat >"$FEATURE_ROOT/${NAME}_data/test/${NAME}_repository_impl_test.dart" <<DART
import 'package:${NAME}_data/${NAME}_data.dart';
import 'package:test/test.dart';

void main() {
  test('returns an empty list by default', () async {
    const repository = ${PASCAL}RepositoryImpl();
    expect(await repository.listItems(), isEmpty);
  });
}
DART

cat >"$FEATURE_ROOT/${NAME}_presentation/lib/${NAME}_presentation.dart" <<DART
export 'src/${NAME}_page.dart';
DART

cat >"$FEATURE_ROOT/${NAME}_presentation/lib/src/${NAME}_page.dart" <<DART
import 'package:flutter/material.dart';

class ${PASCAL}Page extends StatelessWidget {
  const ${PASCAL}Page({super.key, this.title = '${PASCAL}'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('${PASCAL} feature scaffold')),
    );
  }
}
DART

cat >"$FEATURE_ROOT/${NAME}_presentation/test/${NAME}_page_test.dart" <<DART
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:${NAME}_presentation/${NAME}_presentation.dart';

void main() {
  testWidgets('renders scaffold title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ${PASCAL}Page(title: 'Test ${PASCAL}')),
    );
    expect(find.text('Test ${PASCAL}'), findsOneWidget);
  });
}
DART

cat >"$FEATURE_ROOT/README.md" <<MD
# ${PASCAL} Feature

Scaffolded with \`make new-feature NAME=${NAME}\`.

## Packages

- \`${NAME}_domain\`: repository contract and use cases.
- \`${NAME}_data\`: repository implementation.
- \`${NAME}_presentation\`: Flutter UI.

## Testing

\`\`\`bash
dart test features/${NAME}/${NAME}_domain
dart test features/${NAME}/${NAME}_data
flutter test features/${NAME}/${NAME}_presentation
\`\`\`
MD

info "register workspace packages"
ensure_workspace_line "$ROOT/pubspec.yaml" "  - features/${NAME}/${NAME}_domain"
ensure_workspace_line "$ROOT/pubspec.yaml" "  - features/${NAME}/${NAME}_data"
ensure_workspace_line "$ROOT/pubspec.yaml" "  - features/${NAME}/${NAME}_presentation"

if [[ "$WIRE" == "1" ]]; then
  info "wire into apps/$APP"
  ensure_pubspec_dependency "$APP_DIR/pubspec.yaml" "${NAME}_domain" "../../features/${NAME}/${NAME}_domain"
  ensure_pubspec_dependency "$APP_DIR/pubspec.yaml" "${NAME}_data" "../../features/${NAME}/${NAME}_data"
  ensure_pubspec_dependency "$APP_DIR/pubspec.yaml" "${NAME}_presentation" "../../features/${NAME}/${NAME}_presentation"

  ADAPTER="$APP_DIR/lib/app/features/${NAME}_feature.dart"
  if [[ "$ROUTE_KIND" == "tab" ]]; then
    cat >"$ADAPTER" <<DART
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:${NAME}_data/${NAME}_data.dart';
import 'package:${NAME}_domain/${NAME}_domain.dart';
import 'package:${NAME}_presentation/${NAME}_presentation.dart';

void register${PASCAL}Dependencies(GetIt sl) {
  sl
    ..registerLazySingleton<${PASCAL}Repository>(
      () => const ${PASCAL}RepositoryImpl(),
    )
    ..registerLazySingleton(() => List${PASCAL}Items(sl<${PASCAL}Repository>()));
}

StatefulShellBranch create${PASCAL}Branch(GetIt sl) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/${NAME}',
        builder: (_, __) => const ${PASCAL}Page(),
      ),
    ],
  );
}
DART
  else
    cat >"$ADAPTER" <<DART
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:${NAME}_data/${NAME}_data.dart';
import 'package:${NAME}_domain/${NAME}_domain.dart';
import 'package:${NAME}_presentation/${NAME}_presentation.dart';

void register${PASCAL}Dependencies(GetIt sl) {
  sl
    ..registerLazySingleton<${PASCAL}Repository>(
      () => const ${PASCAL}RepositoryImpl(),
    )
    ..registerLazySingleton(() => List${PASCAL}Items(sl<${PASCAL}Repository>()));
}

List<RouteBase> create${PASCAL}Routes(GetIt sl) {
  return [
    GoRoute(
      path: '/${NAME}',
      builder: (_, __) => const ${PASCAL}Page(),
    ),
  ];
}
DART
  fi

  MANIFEST="$APP_DIR/lib/app/features/${APP}_features.dart"
  if [[ ! -f "$MANIFEST" ]]; then
    MANIFEST="$(find "$APP_DIR/lib/app/features" -maxdepth 1 -name '*_features.dart' | head -n1)"
  fi
  if [[ -z "$MANIFEST" || ! -f "$MANIFEST" ]]; then
    echo "warning: app feature manifest not found; skipped wiring ${APP}_features.dart" >&2
  else
    python3 - <<'PY' "$MANIFEST" "$NAME" "$PASCAL" "$ROUTE_KIND"
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
name, pascal, route_kind = sys.argv[2], sys.argv[3], sys.argv[4]
text = path.read_text()

import_line = f"import '{name}_feature.dart';"
if import_line not in text:
    anchor = "import 'sample_feature.dart';"
    if anchor in text:
        text = text.replace(anchor, anchor + "\n" + import_line, 1)
    else:
        last = text.rfind("import '")
        end = text.find("';", last) + 2
        text = text[:end] + "\n" + import_line + text[end:]

register = f"  register{pascal}Dependencies(sl);"
if register not in text:
    text = text.replace(
        "  registerSampleDependencies(sl);\n",
        "  registerSampleDependencies(sl);\n" + register + "\n",
        1,
    )

if route_kind == "tab":
    branch = f"    create{pascal}Branch(sl),"
    if branch not in text:
        pattern = r'(List<StatefulShellBranch>\s+create\w+ShellBranches\(GetIt sl\)\s*\{\s*return\s*\[)(.*?)(\];)'
        def append_branch(match):
            existing = match[2].rstrip().rstrip(',')
            return match[1] + existing + ',\n' + branch + '\n' + match[3]
        text, count = re.subn(pattern, append_branch, text, count=1, flags=re.S)
        if count != 1:
            raise SystemExit('Unable to locate shell branch manifest; wire the new feature explicitly.')
else:
    routes = f"    ...create{pascal}Routes(sl),"
    if routes not in text:
        text = text.replace(
            "    ...createShowcaseRoutes(),\n",
            "    ...createShowcaseRoutes(),\n" + routes + "\n",
            1,
        )

path.write_text(text)
PY
  fi

  BOUNDARY_TEST="$APP_DIR/test/app/package_boundary_test.dart"
  if [[ -f "$BOUNDARY_TEST" ]]; then
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
if name in items:
    raise SystemExit(0)
items.append(name)
replacement = "for (final feature in [" + ", ".join(f"'{item}'" for item in items) + "])"
text = re.sub(pattern, replacement, text, count=1)
path.write_text(text)
PY
  fi
fi

info "apply generated model, BLoC, DI, and route conventions"
python3 "$ROOT/tool/scaffold/generated_feature.py" "$ROOT" "$NAME" "$APP" "$WIRE"

info "dart pub get"
(cd "$ROOT" && fvm dart pub get >/dev/null)

info "generate sources"
(cd "$ROOT" && APP="$APP" bash tool/codegen_all.sh)

cat <<EOF

Created features/${NAME}/ (${NAME}_domain, ${NAME}_data, ${NAME}_presentation)
$( [[ "$WIRE" == "1" ]] && echo "Wired into apps/${APP} (adapter + pubspec + manifest)" )

Next:
  make lint APP=${APP}
  make test APP=${APP}
  Edit features/${NAME} and apps/${APP}/lib/app/features/${NAME}_feature.dart

Options:
  ROUTE_KIND=tab make new-feature NAME=${NAME}   # shell tab instead of public route
  WIRE=0 make new-feature NAME=${NAME}            # packages only, no app wiring
EOF
