# Environment Configuration Guide

## 📋 Overview

This project uses `flutter_dotenv` for environment variable management, providing a secure and flexible way to handle configuration across different environments.

## 🏗️ Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Environment Files
The project includes several environment files:

- `.env` - Active environment (auto-generated)
- `.env.example` - Template file with all available variables
- `.env.development` - Development configuration
- `.env.staging` - Staging configuration  
- `.env.production` - Production configuration

### 3. Switch Environment
Use the provided script to switch between environments:

```bash
# Set development environment
./scripts/set_env.sh development

# Set staging environment  
./scripts/set_env.sh staging

# Set production environment
./scripts/set_env.sh production
```

## 🔧 Available Environment Variables

### API Configuration
```env
API_BASE_URL=your-api-base-url.com
API_TIMEOUT=30000
```

### Environment Settings
```env
APP_ENV=development          # development, staging, production
DEBUG_MODE=true              # true/false
```

### Authentication
```env
JWT_SECRET=your-jwt-secret-key
REFRESH_TOKEN_EXPIRY=7200000  # milliseconds
```

### App Metadata
```env
APP_NAME=Flutter BLoC Base
APP_VERSION=1.0.0
```

### Feature Flags
```env
ENABLE_ANALYTICS=false       # true/false
ENABLE_CRASH_REPORTING=false # true/false
```

## 💻 Usage in Code

### Basic Usage
```dart
import 'package:flutter_bloc_base/core/config/environment.dart';

// Access environment variables
String apiUrl = Environment.apiBaseUrl;
bool isDebug = Environment.debugMode;
```

### Using AppConfig (Recommended)
```dart
import 'package:flutter_bloc_base/core/config/app_config.dart';

// API Configuration
String apiUrl = AppConfig.api.baseUrl;
String fullUrl = AppConfig.api.fullUrl;

// Feature flags
bool analyticsEnabled = AppConfig.features.analytics;
bool debugMode = AppConfig.features.debugMode;

// App metadata
String appName = AppConfig.app.displayName;
String version = AppConfig.app.version;

// Debug settings
bool showDebugBanner = AppConfig.debug.showDebugBanner;
```

## 🔒 Security Best Practices

### 1. Never Commit .env Files
The `.env` file contains sensitive information and should never be committed to version control.

```gitignore
# Already included in .gitignore
.env
```

### 2. Use Different Secrets for Different Environments
Each environment should have its own unique secrets:

- Development: Use test/dummy secrets
- Staging: Use staging-specific secrets  
- Production: Use secure production secrets

### 3. Environment File Structure
```
.env.example          # ✅ Commit this (template)
.env.development     # ✅ Commit this (safe dev config)
.env.staging         # ⚠️  Careful (may contain staging secrets)
.env.production      # ❌ Never commit (contains production secrets)
.env                 # ❌ Never commit (active environment)
```

## 🎯 Environment-Specific Features

### Development
- Debug mode enabled
- Detailed logging
- Development tools available
- Test API endpoints

### Staging
- Production-like environment
- Analytics enabled for testing
- Staging API endpoints
- Debug mode for troubleshooting

### Production
- Debug mode disabled
- Minimal logging
- Production API endpoints
- All security features enabled

## 🚀 Build Commands

### Development Build
```bash
./scripts/set_env.sh development
flutter run
```

### Staging Build
```bash
./scripts/set_env.sh staging
flutter build apk --release
```

### Production Build
```bash
./scripts/set_env.sh production
flutter build apk --release --obfuscate --split-debug-info=build/symbols
```

## 🐛 Troubleshooting

### Environment Not Loading
1. Check if `.env` file exists in project root
2. Verify environment variables are properly formatted
3. Ensure `Environment.init()` is called before accessing variables

### Build Errors
1. Run `flutter clean && flutter pub get`
2. Check if all environment files have correct syntax
3. Verify no special characters in environment values

### Missing Variables
1. Compare your `.env` with `.env.example`
2. Add any missing variables with appropriate values
3. Restart the app after changes

## 📝 Adding New Environment Variables

1. Add the variable to all environment files
2. Update `.env.example` with documentation
3. Add getter in `Environment` class
4. Optionally add typed access in `AppConfig`
5. Update this documentation

Example:
```dart
// In Environment class
static String get newFeature => dotenv.env['NEW_FEATURE'] ?? 'default';

// In AppConfig (optional)
static bool get newFeatureEnabled => Environment.newFeature == 'enabled';
``` 