#!/usr/bin/env bash
# Validate machine + project pins. Non-zero if a required check fails.
# Does not install tools or change JAVA_HOME / Xcode / shell profiles.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# shellcheck disable=SC1091
source "$ROOT/tool/toolchain.env"
# shellcheck disable=SC1091
source "$ROOT/tool/bootstrap/ruby_env.sh"

activate_project_ruby || true

FAILED=0
OS="$(uname -s)"
PREREQ_ONLY=0
if [[ "${1:-}" == "--prereq" ]]; then
  PREREQ_ONLY=1
fi

fail_check() {
  local component="$1" expected="$2" detected="$3" fix="$4"
  echo "❌ ${component}"
  echo "Expected: ${expected}"
  echo "Detected: ${detected}"
  echo
  echo "Suggested fix:"
  echo "  ${fix}"
  echo
  FAILED=1
}

pass_check() {
  echo "✓ $1"
}

version_ge() {
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" == "$2" ]]
}

java_major() {
  local line major
  line="$(java -version 2>&1 | head -1 || true)"
  if [[ "$line" =~ \"1\.([0-9]+) ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  elif [[ "$line" =~ \"([0-9]+) ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  else
    printf '%s\n' ""
  fi
}

android_sdk_root() {
  local candidates=()
  [[ -n "${ANDROID_SDK_ROOT:-}" ]] && candidates+=("$ANDROID_SDK_ROOT" "${ANDROID_SDK_ROOT}/sdk")
  [[ -n "${ANDROID_HOME:-}" ]] && candidates+=("$ANDROID_HOME" "${ANDROID_HOME}/sdk")
  candidates+=("${HOME}/Library/Android/sdk" "${HOME}/Android/Sdk")
  local c
  for c in "${candidates[@]}"; do
    if [[ -d "${c}/platforms" || -d "${c}/platform-tools" || -d "${c}/cmdline-tools" ]]; then
      printf '%s\n' "$c"
      return
    fi
  done
}

echo "Doctor — ${ROOT}"
echo

# --- bootstrap binaries ---
if command -v git >/dev/null 2>&1; then
  pass_check "Git $(git --version | awk '{print $3}')"
else
  fail_check "Git" "git on PATH" "missing" "Install Git: https://git-scm.com"
fi

if command -v make >/dev/null 2>&1; then
  pass_check "Make $(make --version 2>/dev/null | head -1)"
else
  fail_check "Make" "make on PATH" "missing" "Install Make (Xcode CLT / build-essential)."
fi

if command -v fvm >/dev/null 2>&1; then
  pass_check "FVM $(fvm --version 2>/dev/null | head -1)"
else
  fail_check "FVM" "FVM on PATH" "missing" "Install FVM (https://fvm.app), then: fvm install"
fi

# --- Flutter / Dart via FVM only (skipped in --prereq: make init installs SDK next) ---
if [[ "$PREREQ_ONLY" -eq 0 ]] && command -v fvm >/dev/null 2>&1; then
  flutter_ver="$(fvm flutter --version 2>/dev/null | grep -E '^Flutter ' | awk '{print $2; exit}' || true)"
  if [[ "$flutter_ver" == "$FLUTTER_VERSION" ]]; then
    pass_check "Flutter SDK ${flutter_ver}"
  else
    fail_check "Flutter SDK mismatch" "$FLUTTER_VERSION" "${flutter_ver:-not installed}" \
      "Run: make init   (or: fvm install ${FLUTTER_VERSION} && fvm use ${FLUTTER_VERSION})"
  fi

  dart_ver="$(fvm dart --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
  if [[ "$dart_ver" == "$DART_VERSION" ]]; then
    pass_check "Dart ${dart_ver}"
  else
    fail_check "Dart version mismatch" "$DART_VERSION (with Flutter ${FLUTTER_VERSION})" "${dart_ver:-unknown}" \
      "Run: make init   (or: fvm install ${FLUTTER_VERSION} && fvm use ${FLUTTER_VERSION})"
  fi
elif [[ "$PREREQ_ONLY" -eq 1 ]]; then
  pass_check "Flutter SDK skipped (prereq; make init will fvm install ${FLUTTER_VERSION})"
fi

# --- Java ---
if command -v java >/dev/null 2>&1; then
  detected_java="$(java_major)"
  if [[ "$detected_java" == "$JAVA_MAJOR" ]]; then
    pass_check "Java $(java -version 2>&1 | head -1)"
  else
    fail_check "Invalid Java version" "JDK ${JAVA_MAJOR}" "JDK ${detected_java:-unknown}" \
      "Install JDK ${JAVA_MAJOR} and set JAVA_HOME to that JDK. Do not use a different major."
  fi
else
  fail_check "Java/JDK" "JDK ${JAVA_MAJOR} on PATH" "missing" \
    "Install JDK ${JAVA_MAJOR} and configure JAVA_HOME."
fi

# --- Project file pins (Gradle / AGP / Kotlin / Android SDK numbers) ---
# APP = folder name under apps/ (default sample_app). Override: make doctor APP=sample_app
APP_NAME="${APP:-sample_app}"
case "$APP_NAME" in
  */*|apps)
    fail_check "APP" "apps/<name> child (e.g. sample_app)" "$APP_NAME" "Use APP=sample_app, not a path."
    ;;
esac
APP_REL="apps/${APP_NAME}"
APP="$ROOT/$APP_REL"
wrapper="$APP/android/gradle/wrapper/gradle-wrapper.properties"
if grep -q "gradle-${GRADLE_VERSION}-" "$wrapper" 2>/dev/null; then
  pass_check "Gradle wrapper ${GRADLE_VERSION}"
else
  fail_check "Gradle wrapper" "$GRADLE_VERSION in ${APP_REL}/android/gradle/wrapper/gradle-wrapper.properties" \
    "$(grep distributionUrl "$wrapper" 2>/dev/null || echo missing)" \
    "Keep the committed Gradle wrapper. Do not install a global Gradle."
fi

settings="$APP/android/settings.gradle.kts"
if grep -q "com.android.application\".*version \"${AGP_VERSION}\"" "$settings" \
  && grep -q "org.jetbrains.kotlin.android\".*version \"${KOTLIN_VERSION}\"" "$settings"; then
  pass_check "AGP ${AGP_VERSION} / Kotlin ${KOTLIN_VERSION}"
else
  fail_check "AGP / Kotlin" "AGP ${AGP_VERSION}, Kotlin ${KOTLIN_VERSION} in ${APP_REL}/android/settings.gradle.kts" \
    "see ${APP_REL}/android/settings.gradle.kts" \
    "Do not change those plugin versions to latest."
fi

if grep -q "com.google.gms.google-services\".*version \"${GOOGLE_SERVICES_PLUGIN_VERSION}\"" "$settings"; then
  pass_check "Google Services Gradle plugin ${GOOGLE_SERVICES_PLUGIN_VERSION}"
else
  fail_check "Google Services Gradle plugin" "$GOOGLE_SERVICES_PLUGIN_VERSION in ${APP_REL}/android/settings.gradle.kts" \
    "missing or mismatched" "Restore the pinned optional Firebase wiring."
fi

app_gradle="$APP/android/app/build.gradle.kts"
if grep -q "compileSdk = ${ANDROID_COMPILE_SDK}" "$app_gradle" \
  && grep -q "minSdk = ${ANDROID_MIN_SDK}" "$app_gradle" \
  && grep -q "targetSdk = ${ANDROID_TARGET_SDK}" "$app_gradle"; then
  pass_check "Android SDK levels min ${ANDROID_MIN_SDK} / compile ${ANDROID_COMPILE_SDK} / target ${ANDROID_TARGET_SDK}"
else
  fail_check "Android SDK levels" \
    "minSdk=${ANDROID_MIN_SDK} compileSdk=${ANDROID_COMPILE_SDK} targetSdk=${ANDROID_TARGET_SDK}" \
    "see ${APP_REL}/android/app/build.gradle.kts" \
    "Keep the committed SDK levels."
fi

# --- Android SDK on disk ---
sdk="$(android_sdk_root || true)"
if [[ -z "$sdk" ]]; then
  fail_check "Android SDK" "ANDROID_HOME or ANDROID_SDK_ROOT (platform android-${ANDROID_COMPILE_SDK})" "not set / not found" \
    "Install Android Studio and export ANDROID_HOME to the SDK path. Then: sdkmanager \"platforms;android-${ANDROID_COMPILE_SDK}\""
else
  if [[ -d "${sdk}/platforms/android-${ANDROID_COMPILE_SDK}" ]]; then
    pass_check "Android SDK ${sdk} (platforms/android-${ANDROID_COMPILE_SDK})"
  else
    fail_check "Android platform" "platforms/android-${ANDROID_COMPILE_SDK} under ${sdk}" "missing" \
      "sdkmanager \"platforms;android-${ANDROID_COMPILE_SDK}\""
  fi
fi

# --- .env template ---
if [[ -f "$APP/.env.example" ]]; then
  pass_check ".env.example present (${APP_REL})"
else
  fail_check "Environment template" "${APP_REL}/.env.example" "missing" "Restore .env.example from git."
fi

# --- project Ruby / release tooling ---
if command -v rbenv >/dev/null 2>&1; then
  ruby_ver="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || true)"
  ruby_bin="$(command -v ruby || true)"
  if [[ "$ruby_ver" == "$RUBY_VERSION" && "$ruby_bin" == *rbenv*/shims/ruby ]]; then
    pass_check "Ruby ${ruby_ver} selected by .ruby-version"
  else
    fail_check "Ruby" "${RUBY_VERSION} through rbenv" "${ruby_ver:-missing} (${ruby_bin:-not found})" \
      "Run: make init"
  fi
else
  fail_check "rbenv" "rbenv with Ruby ${RUBY_VERSION}" "missing" "Run: make init"
fi

if command -v bundle >/dev/null 2>&1; then
  bundler_ver="$(project_bundle --version 2>/dev/null | awk '{print $3}' || true)"
  if [[ "$bundler_ver" == "$BUNDLER_VERSION" ]]; then
    pass_check "Bundler ${bundler_ver}"
  else
    fail_check "Bundler" "$BUNDLER_VERSION" "${bundler_ver:-unknown}" "Run: make init"
  fi
else
  fail_check "Bundler" "$BUNDLER_VERSION under Ruby $RUBY_VERSION" "missing" "Run: make init"
fi

# --- macOS / iOS ---
if [[ "$OS" == "Darwin" ]]; then
  if command -v xcodebuild >/dev/null 2>&1; then
    xcode_ver="$(xcodebuild -version 2>/dev/null | awk '/^Xcode/{print $2; exit}' || true)"
    if [[ -n "$xcode_ver" ]] && version_ge "$xcode_ver" "$XCODE_MIN"; then
      pass_check "Xcode ${xcode_ver} (>= ${XCODE_MIN})"
    else
      fail_check "Xcode" ">= ${XCODE_MIN}" "${xcode_ver:-missing}" \
        "Install Xcode ${XCODE_MIN}+ from the App Store, then: sudo xcode-select -s /Applications/Xcode.app"
    fi
  else
    fail_check "Xcode" ">= ${XCODE_MIN} (xcodebuild)" "missing" \
      "Install Xcode from the App Store and Xcode Command Line Tools."
  fi

else
  pass_check "iOS/Xcode skipped (${OS})"
fi

echo
if [[ "$FAILED" -ne 0 ]]; then
  echo "Doctor failed. Fix the items above, then re-run: make doctor"
  exit 1
fi
echo "Doctor passed."
exit 0
