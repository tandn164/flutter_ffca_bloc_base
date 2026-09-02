#!/usr/bin/env bash

# Select the repository-pinned Ruby without changing the user's global Ruby.
activate_project_ruby() {
  if ! command -v rbenv >/dev/null 2>&1; then
    return 1
  fi
  export RBENV_ROOT="${RBENV_ROOT:-$(rbenv root)}"
  export RBENV_VERSION="$RUBY_VERSION"
  export PATH="$RBENV_ROOT/shims:$PATH"
  hash -r 2>/dev/null || true
  rbenv versions --bare | grep -Fxq "$RUBY_VERSION"
}

project_bundle() {
  bundle "_${BUNDLER_VERSION}_" "$@"
}
