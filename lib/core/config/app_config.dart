import 'package:flutter/foundation.dart';
import 'environment.dart';

/// Application configuration class
/// Provides typed access to environment variables and computed configurations
class AppConfig {
  AppConfig._();

  /// Current environment type
  static EnvironmentType get currentEnvironment {
    switch (Environment.appEnv.toLowerCase()) {
      case 'production':
        return EnvironmentType.production;
      case 'staging':
        return EnvironmentType.staging;
      case 'development':
      default:
        return EnvironmentType.development;
    }
  }

  /// API Configuration
  static ApiConfig get api => ApiConfig._();

  /// Auth Configuration
  static AuthConfig get auth => AuthConfig._();

  /// Feature flags
  static FeatureFlags get features => FeatureFlags._();

  /// App metadata
  static AppMetadata get app => AppMetadata._();

  /// Debug settings
  static DebugConfig get debug => DebugConfig._();
}

/// Environment types
enum EnvironmentType {
  development,
  staging,
  production,
}

/// API Configuration
class ApiConfig {
  ApiConfig._();

  String get baseUrl => Environment.apiBaseUrl;
  int get timeout => Environment.apiTimeout;
  
  /// Full API endpoint URL
  String get fullUrl => 'https://$baseUrl';
  
  /// Whether to use secure connections
  bool get useHttps => !Environment.isDevelopment;
}

/// Authentication Configuration
class AuthConfig {
  AuthConfig._();

  String get jwtSecret => Environment.jwtSecret;
  int get refreshTokenExpiry => Environment.refreshTokenExpiry;
  
  /// Token expiry in minutes
  int get refreshTokenExpiryMinutes => refreshTokenExpiry ~/ (1000 * 60);
}

/// Feature Flags
class FeatureFlags {
  FeatureFlags._();

  bool get analytics => Environment.enableAnalytics;
  bool get crashReporting => Environment.enableCrashReporting;
  
  /// Development-only features
  bool get devTools => Environment.isDevelopment;
  bool get debugMode => Environment.debugMode;
}

/// App Metadata
class AppMetadata {
  AppMetadata._();

  String get name => Environment.appName;
  String get version => Environment.appVersion;
  String get environment => Environment.appEnv;
  
  /// App title with environment suffix
  String get displayName {
    if (Environment.isProduction) {
      return name;
    }
    return '$name (${environment.toUpperCase()})';
  }
}

/// Debug Configuration
class DebugConfig {
  DebugConfig._();

  bool get enabled => Environment.debugMode && kDebugMode;
  bool get verbose => enabled && Environment.isDevelopment;
  
  /// Should show debug overlays
  bool get showDebugBanner => !Environment.isProduction;
  
  /// Should log network requests
  bool get logNetworkRequests => enabled;
  
  /// Should show performance overlay
  bool get showPerformanceOverlay => enabled && Environment.isDevelopment;
} 