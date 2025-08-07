#!/bin/bash

# Code Generation Script for Flutter BLoC Base
# This script automates the generation of JSON serialization and Chopper HTTP clients

set -e  # Exit on any error

echo "🔧 Starting code generation..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if flutter is available
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Get dependencies first
print_step "Getting dependencies..."
flutter pub get

# Generate localization files
print_step "Generating localization files..."
if flutter gen-l10n; then
    print_success "Localization files generated"
else
    print_warning "Localization generation failed, continuing..."
fi

# Generate JSON serialization and Chopper files
print_step "Generating JSON serialization and Chopper HTTP clients..."

# Check if we should delete conflicting outputs
if [ "$1" = "--clean" ] || [ "$1" = "-c" ]; then
    print_warning "Cleaning existing generated files..."
    if flutter pub run build_runner build --delete-conflicting-outputs; then
        print_success "Code generation completed (with cleanup)"
    else
        print_error "Code generation failed"
        exit 1
    fi
else
    if flutter pub run build_runner build; then
        print_success "Code generation completed"
    else
        print_warning "Code generation failed, trying with cleanup..."
        if flutter pub run build_runner build --delete-conflicting-outputs; then
            print_success "Code generation completed (with cleanup)"
        else
            print_error "Code generation failed even with cleanup"
            exit 1
        fi
    fi
fi

# Verify generated files
print_step "Verifying generated files..."

generated_files=(
    "lib/core/network/rest_client_service.chopper.dart"
    "lib/screens/user/data/models/user_dto.g.dart"
    "lib/screens/authentication/data/models/authentication_dtos.g.dart"
)

all_files_exist=true
for file in "${generated_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file"
    else
        print_error "✗ Missing: $file"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = true ]; then
    print_success "All generated files are present"
else
    print_error "Some generated files are missing"
    exit 1
fi

# Run analysis to check for errors
print_step "Running Flutter analysis..."
if flutter analyze --no-congratulate; then
    print_success "No analysis issues found"
else
    print_warning "Analysis found some issues, check output above"
fi

echo ""
print_success "🎉 Code generation completed successfully!"
echo ""
echo "📝 Generated files:"
echo "   - JSON serialization: *.g.dart files"
echo "   - HTTP clients: *.chopper.dart files"
echo "   - Localizations: generated/l10n/*.dart files"
echo ""
echo "💡 Usage:"
echo "   ./scripts/generate_code.sh         # Normal generation"
echo "   ./scripts/generate_code.sh --clean # Clean and regenerate"
echo "" 