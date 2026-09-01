# Orchestration only. Pins: tool/toolchain.env, .fvmrc, pubspec.lock (workspace), Gradle wrapper, Gemfile.lock.
#
# Multi-app: APP is the folder name under apps/ (no apps/ prefix).
#   make run APP=sample_app FLAVOR=stg
#   make run APP=merchant_app

.DEFAULT_GOAL := help

APP       ?= sample_app
APP_DIR   := apps/$(APP)
FLAVOR    ?= dev
WIRE      ?= 1
ROUTE_KIND ?= public
SOURCE    ?= sample_app
FLUTTER   := fvm flutter
DART      := fvm dart
DART_DEFINES := --dart-define=FLAVOR=$(FLAVOR)

.PHONY: help doctor init clean codegen test lint run get l10n release setup-hooks new-feature delete-feature new-app delete-app adopt-project _check_app

_check_app:
	@case "$(APP)" in */*|apps) echo "error: APP=$(APP) must be an apps/ child name (e.g. sample_app), not a path" >&2; exit 1 ;; esac
	@test -f "$(APP_DIR)/pubspec.yaml" || (echo "error: APP=$(APP) → $(APP_DIR) is not a Flutter package (missing pubspec.yaml)" >&2; exit 1)

help:
	@echo "  make help       list commands"
	@echo "  make doctor     check this machine has the required prerequisites"
	@echo "  make get        dart pub get (Dart pub workspace root)"
	@echo "  make init       doctor → FVM → pub get → .env → codegen → iOS (macOS) → validate"
	@echo "  make codegen    gen-l10n for apps/\$$APP + feature Chopper APIs"
	@echo "  make lint       dart analyze (apps/\$$APP + packages)"
	@echo "  make test       apps/\$$APP tests + package tests"
	@echo "  make run        flutter run --flavor \$$FLAVOR in apps/\$$APP"
	@echo "  make l10n       pull Google Sheet CSV and generate ARB/localizations"
	@echo "  make release    interactive Android/iOS build and upload wizard"
	@echo "  make setup-hooks install pre-commit and commit-message validation"
	@echo "  make new-feature NAME=orders [APP=sample_app] [ROUTE_KIND=public|tab]"
	@echo "  make delete-feature NAME=orders [APP=sample_app] CONFIRM=1"
	@echo "  make new-app NAME=merchant_app [SOURCE=sample_app]"
	@echo "  make delete-app NAME=merchant_app CONFIRM=1"
	@echo "  make adopt-project PACKAGE=acme_merchant TITLE=\"Acme Merchant\" CONFIRM=1"
	@echo "  make clean      flutter clean in apps/\$$APP"
	@echo ""
	@echo "  Defaults: APP=$(APP) → $(APP_DIR)  FLAVOR=$(FLAVOR)"
	@echo "  Example:  make run APP=sample_app FLAVOR=stg"

doctor:
	@APP="$(APP)" bash tool/doctor.sh

get:
	@$(DART) pub get

init: _check_app
	@APP="$(APP)" bash tool/init.sh

codegen: _check_app
	@APP="$(APP)" bash tool/codegen_all.sh

lint: _check_app
	@APP="$(APP)" bash tool/analyze_all.sh

test: _check_app
	@APP="$(APP)" bash tool/test_all.sh

run: _check_app
	@cd $(APP_DIR) && $(FLUTTER) run --flavor $(FLAVOR) $(DART_DEFINES)

clean: _check_app
	@cd $(APP_DIR) && $(FLUTTER) clean

l10n: _check_app
	@APP="$(APP)" bash tool/l10n/pull_sheet.sh

release: _check_app
	@APP="$(APP)" bash tool/release.sh

setup-hooks:
	@bash tool/quality/install_hooks.sh

new-feature:
	@test -n "$(NAME)" || (echo "error: NAME is required (e.g. make new-feature NAME=orders)" >&2; exit 1)
	@NAME="$(NAME)" APP="$(APP)" WIRE="$(WIRE)" ROUTE_KIND="$(ROUTE_KIND)" bash tool/scaffold/new_feature.sh

delete-feature:
	@test -n "$(NAME)" || (echo "error: NAME is required (e.g. make delete-feature NAME=orders CONFIRM=1)" >&2; exit 1)
	@NAME="$(NAME)" APP="$(APP)" WIRE="$(WIRE)" CONFIRM="$(CONFIRM)" bash tool/scaffold/delete_feature.sh

new-app:
	@test -n "$(NAME)" || (echo "error: NAME is required (e.g. make new-app NAME=merchant_app)" >&2; exit 1)
	@NAME="$(NAME)" SOURCE="$(SOURCE)" bash tool/scaffold/new_app.sh

delete-app:
	@test -n "$(NAME)" || (echo "error: NAME is required (e.g. make delete-app NAME=merchant_app CONFIRM=1)" >&2; exit 1)
	@NAME="$(NAME)" CONFIRM="$(CONFIRM)" bash tool/scaffold/delete_app.sh

adopt-project:
	@test -n "$(PACKAGE)" || (echo "error: PACKAGE is required (e.g. make adopt-project PACKAGE=acme_merchant CONFIRM=1)" >&2; exit 1)
	@PACKAGE="$(PACKAGE)" TITLE="$(TITLE)" CONFIRM="$(CONFIRM)" bash tool/adopt_project.sh
