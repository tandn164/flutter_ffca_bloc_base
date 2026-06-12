# ComposableCore — dev commands
# Run `make help` for all targets.

.DEFAULT_GOAL := help

ROOT_DIR := $(shell pwd)

# Prefer FVM when configured
ifeq ($(wildcard .fvm/fvm_config.json),.fvm/fvm_config.json)
  FLUTTER := fvm flutter
  DART    := fvm dart
else
  FLUTTER := flutter
  DART    := dart
endif

.PHONY: help check setup sync codegen run run-ios run-android test analyze clean \
        env-dev env-staging env-prod pods ci-check l10n-sync

help: ## List all commands
	@echo "ComposableCore"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Quick start (new machine):  make setup && make run"

check: ## Verify Flutter, tools, .env, generated files
	@bash tool/env/check_env.sh

setup: ## First-time setup: FVM, pub get, sync, codegen, pods
	@bash tool/env/setup_env.sh

sync: ## Run composable_sync + pub get (all workspace packages)
	@$(DART) run tool/composable_sync.dart
	@$(DART) run melos bootstrap 2>/dev/null || $(FLUTTER) pub get

bootstrap: ## melos bootstrap all packages
	@$(DART) run melos bootstrap

codegen: sync ## build_runner + gen-l10n
	@$(FLUTTER) gen-l10n
	@$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

run: ## Run app (default device)
	@$(FLUTTER) run

run-ios: ## Run on iOS simulator / device
	@$(FLUTTER) run -d ios

run-android: ## Run on Android emulator / device
	@$(FLUTTER) run -d android

test: ## Run unit / widget tests
	@$(FLUTTER) test

analyze: ## Run dart analyzer
	@$(DART) analyze .

clean: ## flutter clean
	@$(FLUTTER) clean

env-dev: ## Switch to development .env
	@if [ -f .env.development ]; then \
		cp .env.development .env && echo "✓ .env ← .env.development"; \
	else \
		cp .env.example .env && \
		sed -i.bak 's/APP_ENV=development/APP_ENV=development/' .env 2>/dev/null || \
		cp .env.example .env; \
		rm -f .env.bak; \
		echo "✓ .env ← .env.example (development)"; \
	fi

env-staging: ## Switch to staging .env
	@if [ -f .env.staging ]; then \
		cp .env.staging .env && echo "✓ .env ← .env.staging"; \
	else \
		echo "✗ .env.staging not found — create from .env.example"; exit 1; \
	fi

env-prod: ## Switch to production .env
	@if [ -f .env.production ]; then \
		cp .env.production .env && echo "✓ .env ← .env.production"; \
	else \
		echo "✗ .env.production not found — create from .env.example"; exit 1; \
	fi

pods: ## pod install (iOS)
	@cd ios && pod install

ci-check: ## CI subset: analyze + test + config validate
	@$(DART) run tool/composable_sync.dart
	@$(DART) analyze .
	@$(FLUTTER) test

l10n-sync: ## Sync ARB from Google Sheet (when script is available)
	@if [ -f tool/l10n_sync/sync.dart ]; then \
		$(DART) run tool/l10n_sync/sync.dart; \
		$(FLUTTER) gen-l10n; \
	else \
		echo "l10n Google Sheet sync not implemented yet (devTools.l10nGoogleSheet)"; \
		exit 1; \
	fi
