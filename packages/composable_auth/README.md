# Composable Auth

Authentication service with configurable auth modes and smart token refresh for Flutter applications.

## Features

- **Configurable Auth Modes**: Support for `authRequired` and `guestAllowed` modes
- **Smart Token Refresh**: Proactive token refresh before expiry with deduplication
- **JWT Support**: Automatic JWT parsing and expiry detection
- **Session Management**: Automatic session validation and recovery
- **Route Guards**: Built-in route-based authentication checks
- **Retry Logic**: Configurable retry attempts for token refresh operations

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  composable_auth:
    path: ../packages/composable_auth
```

## Usage

### 1. Configure Authentication Mode

```dart
final authConfig = AuthConfig(
  mode: AuthMode.authRequired, // or AuthMode.guestAllowed
  refreshBeforeExpiry: Duration(minutes: 5),
  publicRoutes: ['/home', '/about'], // for guestAllowed mode
  maxRetryAttempts: 3,
  retryDelay: Duration(seconds: 2),
);
```

### 2. Initialize the Module

```dart
import 'package:composable_auth/composable_auth.dart';
import 'package:composable_core/composable_core.dart';

// In your main app initialization
final authModule = ComposableAuthModule(
  config: authConfig,
  onLogin: (email, password) async {
    // Your login API call
    final response = await apiService.login(email, password);
    return response.data; // Should contain access_token, refresh_token, user
  },
  onLogout: (token) async {
    // Your logout API call
    await apiService.logout(token);
  },
  onRefreshToken: (refreshToken) async {
    // Your token refresh API call
    final response = await apiService.refreshToken(refreshToken);
    return response.data;
  },
  onSessionExpired: () {
    // Handle session expiry (navigate to login, show message, etc.)
    print('Session expired, please login again');
  },
);

// Register the module
ComposableCoreBootstrap.instance.registerModule(authModule);
await ComposableCoreBootstrap.instance.initialize();
```

### 3. Use AuthService

```dart
// Get AuthService instance
final authService = GetIt.instance<AuthService>();

// Listen to auth state changes
authService.stateStream.listen((state) {
  switch (state.status) {
    case AuthStatus.authenticated:
      // User is logged in
      navigateToHome();
      break;
    case AuthStatus.guest:
      // User is in guest mode
      showGuestInterface();
      break;
    case AuthStatus.unauthenticated:
      // User needs to login
      navigateToLogin();
      break;
    case AuthStatus.expired:
      // Session expired
      showSessionExpiredDialog();
      break;
  }
});

// Login
final success = await authService.login('user@example.com', 'password');
if (success) {
  print('Login successful');
}

// Logout
await authService.logout();

// Check if route requires authentication
final requiresAuth = authService.requiresAuth('/profile');

// Refresh token if needed
await authService.refreshTokenIfNeeded();
```

### 4. Route Guards

```dart
// In your route guard logic
bool canActivateRoute(String route) {
  final authService = GetIt.instance<AuthService>();
  
  if (authService.requiresAuth(route)) {
    return authService.state.isAuthenticated;
  }
  
  return true; // Public route or guest allowed
}
```

## Authentication Modes

### AuthRequired Mode
- App requires authentication on startup
- All routes require authentication by default
- No guest access allowed

### GuestAllowed Mode  
- App allows guest access to certain routes
- Only specified routes require authentication
- Users can browse public content without login

## Token Management

The package includes smart token management features:

- **Automatic Refresh**: Tokens are refreshed before expiry
- **Deduplication**: Multiple concurrent refresh attempts are merged into single request
- **Retry Logic**: Failed refresh attempts are retried with exponential backoff
- **JWT Parsing**: Automatic extraction of expiry time and user data from JWT tokens

## State Management

The `AuthState` provides comprehensive authentication status:

```dart
enum AuthStatus {
  initial,        // Checking authentication
  authenticated,  // User is logged in
  guest,          // Guest mode (if allowed)
  unauthenticated,// Needs authentication
  expired,        // Session expired
  authenticating, // Login in progress
  refreshing,     // Token refresh in progress
}
```

## Integration with Other Packages

This package is designed to work with:
- `composable_network` for API calls
- `composable_core` for module management
- Any HTTP client (Dio, Chopper, etc.) via callbacks

## Best Practices

1. **Configure appropriate refresh timing**: Set `refreshBeforeExpiry` to allow enough time for refresh operations
2. **Handle session expiry gracefully**: Provide clear user feedback when sessions expire
3. **Use route guards**: Protect sensitive routes with authentication checks
4. **Monitor auth state**: React to auth state changes in your UI
5. **Implement proper error handling**: Handle network failures and invalid credentials appropriately

## Implementation in Other Projects

To use this pattern in non-ComposableCore projects:

1. Copy the core auth logic patterns (token management, refresh scheduling)
2. Adapt the dependency injection to your project's DI container
3. Implement the callback interfaces for your specific API client
4. Follow the state management patterns for your preferred state solution

The key concepts are transferable across different Flutter architectures.