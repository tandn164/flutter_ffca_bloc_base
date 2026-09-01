#!/usr/bin/env bash
# Register a workspace app with Android Studio / IntelliJ (module + run config).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/tool/scaffold/common.sh"

APP_NAME="${1:-${NAME:-}}"
require_name "APP_NAME" "$APP_NAME"

APP_DIR="$ROOT/apps/$APP_NAME"
if [[ ! -f "$APP_DIR/pubspec.yaml" ]]; then
  echo "error: apps/$APP_NAME not found" >&2
  exit 1
fi

info() { echo "==> $*"; }

info "create apps/$APP_NAME/${APP_NAME}.iml"
rm -f "$APP_DIR/demo_app.iml" "$APP_DIR/sample_app.iml" "$APP_DIR/flutter_ffca_base.iml"
cat >"$APP_DIR/${APP_NAME}.iml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$/lib" isTestSource="false" />
      <sourceFolder url="file://$MODULE_DIR$/test" isTestSource="true" />
      <excludeFolder url="file://$MODULE_DIR$/.dart_tool" />
      <excludeFolder url="file://$MODULE_DIR$/.pub" />
      <excludeFolder url="file://$MODULE_DIR$/build" />
      <excludeFolder url="file://$MODULE_DIR$/android/.gradle" />
      <excludeFolder url="file://$MODULE_DIR$/ios/Pods" />
      <excludeFolder url="file://$MODULE_DIR$/ios/.symlinks" />
    </content>
    <orderEntry type="inheritedJdk" />
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="library" name="Dart SDK" level="project" />
    <orderEntry type="library" name="Flutter Plugins" level="project" />
    <orderEntry type="library" name="Dart Packages" level="project" />
  </component>
</module>
XML

IDEA="$ROOT/.idea"
mkdir -p "$IDEA/runConfigurations"

info "update .idea/modules.xml"
python3 - <<'PY' "$IDEA/modules.xml" "$APP_NAME"
import pathlib
import sys
import xml.etree.ElementTree as ET

path = pathlib.Path(sys.argv[1])
app = sys.argv[2]
module_url = f"file://$PROJECT_DIR$/apps/{app}/{app}.iml"
module_path = f"$PROJECT_DIR$/apps/{app}/{app}.iml"

if path.exists():
    tree = ET.parse(path)
    root = tree.getroot()
else:
    root = ET.Element("project", version="4")
    tree = ET.ElementTree(root)

manager = root.find("component[@name='ProjectModuleManager']")
if manager is None:
    manager = ET.SubElement(root, "component", name="ProjectModuleManager")
modules = manager.find("modules")
if modules is None:
    modules = ET.SubElement(manager, "modules")

for module in modules.findall("module"):
    if module.get("filepath") == module_path:
        break
else:
    ET.SubElement(
        modules,
        "module",
        fileurl=module_url,
        filepath=module_path,
    )
    tree.write(str(path), encoding="UTF-8", xml_declaration=True)
PY

info "create run configuration $APP_NAME"
cat >"$IDEA/runConfigurations/${APP_NAME}.xml" <<XML
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="${APP_NAME}" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="filePath" value="\$PROJECT_DIR\$/apps/${APP_NAME}/lib/main.dart" />
    <option name="additionalArgs" value="--flavor dev --dart-define=FLAVOR=dev" />
    <option name="workingDirectory" value="\$PROJECT_DIR\$/apps/${APP_NAME}" />
    <method v="2" />
  </configuration>
</component>
XML

info "enable Dart module $APP_NAME"
python3 - <<'PY' "$IDEA/dart.xml" "$APP_NAME"
import pathlib
import sys
import xml.etree.ElementTree as ET

path = pathlib.Path(sys.argv[1])
app = sys.argv[2]

if path.exists():
    tree = ET.parse(path)
    root = tree.getroot()
else:
    root = ET.Element("project", version="4")
    tree = ET.ElementTree(root)
    ET.SubElement(
        root,
        "component",
        name="DartProjectSettings",
    )

settings = root.find("component[@name='DartProjectSettings']")
if settings is None:
    settings = ET.SubElement(root, "component", name="DartProjectSettings")
    ET.SubElement(
        settings,
        "option",
        name="sdkPath",
        value="$PROJECT_DIR$/.fvm/flutter_sdk/bin/cache/dart-sdk",
    )

modules_opt = settings.find("option[@name='modules']")
if modules_opt is None:
    modules_opt = ET.SubElement(settings, "option", name="modules")
    list_el = ET.SubElement(modules_opt, "list")
else:
    list_el = modules_opt.find("list")
    if list_el is None:
        list_el = ET.SubElement(modules_opt, "list")

existing = {option.get("value") for option in list_el.findall("option")}
if app not in existing:
    ET.SubElement(list_el, "option", value=app)

tree.write(str(path), encoding="UTF-8", xml_declaration=True)
PY

VSCODE="$ROOT/.vscode/settings.json"
if [[ -f "$VSCODE" ]]; then
  info "add apps/$APP_NAME to .vscode projectRoots"
  python3 - <<'PY' "$VSCODE" "$APP_NAME"
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
app = f"apps/{sys.argv[2]}"
data = json.loads(path.read_text())
roots = data.setdefault("dart.projectRoots", [])
if app not in roots:
    roots.append(app)
    roots.sort()
path.write_text(json.dumps(data, indent=2) + "\n")
PY
fi

echo
echo "Registered IDE run configuration: ${APP_NAME}"
echo "Restart Android Studio or use File → Sync Project with Gradle / Invalidate Caches if it does not appear."
