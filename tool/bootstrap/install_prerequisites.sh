#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/tool/toolchain.env"
# shellcheck disable=SC1091
source "$ROOT/tool/bootstrap/ruby_env.sh"

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

install_project_ruby() {
  if ! command -v rbenv >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1 && confirm "Install rbenv and ruby-build with Homebrew?"; then
      brew install rbenv ruby-build
    else
      echo "rbenv is missing. Install it from https://github.com/rbenv/rbenv." >&2
      exit 1
    fi
  fi
  if ! rbenv commands | grep -qx 'install'; then
    if command -v brew >/dev/null 2>&1 && confirm "Install ruby-build with Homebrew?"; then
      brew install ruby-build
    else
      echo "ruby-build is required to install Ruby ${RUBY_VERSION}." >&2
      exit 1
    fi
  fi
  if ! rbenv versions --bare | grep -Fxq "$RUBY_VERSION"; then
    if confirm "Install project Ruby ${RUBY_VERSION}?"; then
      rbenv install "$RUBY_VERSION"
    else
      echo "Ruby ${RUBY_VERSION} is required by .ruby-version." >&2
      exit 1
    fi
  fi
  activate_project_ruby
}

install_bundler() {
  local detected=""
  detected="$(project_bundle --version 2>/dev/null | awk '{print $3}' || true)"
  [[ "$detected" == "$BUNDLER_VERSION" ]] && return
  if confirm "Install Bundler ${BUNDLER_VERSION} for project Ruby ${RUBY_VERSION}?"; then
    gem install bundler -v "$BUNDLER_VERSION" --no-document
    rbenv rehash
    return
  fi
  echo "Bundler ${BUNDLER_VERSION} is required for project Ruby ${RUBY_VERSION}." >&2
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
install_project_ruby
install_bundler
if [[ "$(uname -s)" == "Darwin" ]]; then
  install_java_macos
  check_xcode
fi

echo "Prerequisite bootstrap completed. make doctor will verify exact versions."
