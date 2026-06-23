enum AuthMode {
  /// App allows guest access, some features require auth
  guestAllowed,
  
  /// App requires authentication on startup
  authRequired,
}

class AuthConfig {
  const AuthConfig({
    this.mode = AuthMode.authRequired,
    this.refreshBeforeExpiry = const Duration(minutes: 5),
    this.publicRoutes = const [],
    this.maxRetryAttempts = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  /// Authentication mode
  final AuthMode mode;
  
  /// Refresh token this duration before expiry
  final Duration refreshBeforeExpiry;
  
  /// Routes that don't require auth when mode is guestAllowed
  final List<String> publicRoutes;
  
  /// Max retry attempts for token refresh
  final int maxRetryAttempts;
  
  /// Delay between retry attempts
  final Duration retryDelay;
  
  /// Check if route is public (doesn't require auth)
  bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }
  
  /// Check if guest access is allowed
  bool get allowsGuestAccess => mode == AuthMode.guestAllowed;
  
  /// Check if auth is required on startup
  bool get requiresAuthOnStartup => mode == AuthMode.authRequired;
}