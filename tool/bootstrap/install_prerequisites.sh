#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/tool/toolchain.env"

confirm() {
  local prompt="$1"
  if [[ "${AUTO_INSTALL:-0}" == "1" ]]; then return 0; fi
  if [[ ! -t 0 ]]; then return 1; fi
  read -r -p "$prompt [y/N] " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

install_fvm() {
  command -v fvm >/dev/null 2>&1 && return
  if command -v brew >/dev/null 2>&1 && confirm "Install FVM with Homebrew?"; then
    brew tap leoafarias/fvm
    brew install fvm
    return
  fi
  if command -v dart >/dev/null 2>&1 && confirm "Install FVM with dart pub global?"; then
    dart pub global activate fvm
    return
  fi
  echo "FVM is missing. Install it from https://fvm.app before continuing." >&2
  exit 1
}

install_java_macos() {
  if command -v java >/dev/null 2>&1; then return; fi
  if command -v brew >/dev/null 2>&1 && confirm "Install OpenJDK ${JAVA_MAJOR} with Homebrew?"; then
    brew install "openjdk@${JAVA_MAJOR}"
    return
  fi
  echo "JDK ${JAVA_MAJOR} is missing. Install it and configure JAVA_HOME." >&2
  exit 1
}

install_bundler() {
  command -v bundle >/dev/null 2>&1 && return
  if command -v gem >/dev/null 2>&1 && confirm "Install Bundler with gem?"; then
    gem install bundler
    return
  fi
  echo "Bundler is missing. Install it with: gem install bundler" >&2
  exit 1
}

check_xcode() {
  [[ "$(uname -s)" == "Darwin" ]] || return
  if command -v xcodebuild >/dev/null 2>&1; then return; fi
  if command -v xcodes >/dev/null 2>&1; then
    echo "Xcode is missing. Available versions can be installed with xcodes."
    if confirm "List installable Xcode versions now?"; then xcodes list; fi
  fi
  echo "Install Xcode ${XCODE_MIN}+ and accept its license before iOS setup." >&2
  exit 1
}

install_fvm
if [[ "$(uname -s)" == "Darwin" ]]; then
  install_java_macos
  install_bundler
  check_xcode
fi

echo "Prerequisite bootstrap completed. make doctor will verify exact versions."
