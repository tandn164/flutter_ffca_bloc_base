import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service
/// Provides centralized access to environment variables
class Environment {
  // Private constructor
  Environment._();

  /// Initialize environment variables from .env file
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'localhost';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // Environment Settings
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';
  static bool get isStaging => appEnv == 'staging';
  static bool get debugMode => bool.tryParse(dotenv.env['DEBUG_MODE'] ?? 'false') ?? false;

  // Auth Configuration
  static String get jwtSecret => dotenv.env['JWT_SECRET'] ?? 'default-secret';
  static int get refreshTokenExpiry => 
      int.tryParse(dotenv.env['REFRESH_TOKEN_EXPIRY'] ?? '7200000') ?? 7200000;

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Flutter BLoC Base';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // Feature Flags
  static bool get enableAnalytics => 
      bool.tryParse(dotenv.env['ENABLE_ANALYTICS'] ?? 'false') ?? false;
  static bool get enableCrashReporting => 
      bool.tryParse(dotenv.env['ENABLE_CRASH_REPORTING'] ?? 'false') ?? false;

  /// Get environment variable with fallback
  static String get(String key, [String fallback = '']) {
    return dotenv.env[key] ?? fallback;
  }

  /// Check if environment variable exists
  static bool has(String key) {
    return dotenv.env.containsKey(key);
  }

  /// Get all environment variables (for debugging)
  static Map<String, String> get all => Map.from(dotenv.env);

  /// Environment info for debugging
  static String get environmentInfo {
    return '''
Environment: $appEnv
Debug Mode: $debugMode
API Base URL: $apiBaseUrl
App Version: $appVersion
Analytics: ${enableAnalytics ? 'Enabled' : 'Disabled'}
''';
  }
} 