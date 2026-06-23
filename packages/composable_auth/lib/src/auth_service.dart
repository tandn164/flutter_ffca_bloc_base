import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_config.dart';
import 'auth_state.dart';
import 'token_manager.dart';

/// Callback for handling session expiry
typedef SessionExpiredCallback = void Function();

/// Callback for token refresh
typedef TokenRefreshCallback = Future<Map<String, dynamic>?> Function(String refreshToken);

/// Callback for login
typedef LoginCallback = Future<Map<String, dynamic>?> Function(String email, String password);

/// Callback for logout
typedef LogoutCallback = Future<void> Function(String? token);

class AuthService {
  AuthService({
    required AuthConfig config,
    required SharedPreferences sharedPreferences,
    required this.onLogin,
    required this.onLogout,
    required this.onRefreshToken,
    this.onSessionExpired,
  }) : _config = config,
       _tokenManager = TokenManager(sharedPreferences: sharedPreferences);

  final AuthConfig _config;
  final TokenManager _tokenManager;
  final Logger _logger = Logger('AuthService');

  // Callbacks
  final LoginCallback onLogin;
  final LogoutCallback onLogout;
  final TokenRefreshCallback onRefreshToken;
  final SessionExpiredCallback? onSessionExpired;

  // State management
  final StreamController<AuthState> _stateController = StreamController<AuthState>.broadcast();
  AuthState _currentState = const AuthState();
  Timer? _refreshTimer;
  Completer<void>? _refreshCompleter;

  /// Current auth state
  AuthState get state => _currentState;
  
  /// Auth state stream
  Stream<AuthState> get stateStream => _stateController.stream;

  /// Initialize the auth service
  Future<void> initialize() async {
    try {
      _logger.info('Initializing AuthService with mode: ${_config.mode}');
      
      // Check for existing tokens
      final hasTokens = _tokenManager.hasAccessToken;
      
      if (hasTokens) {
        // Validate existing session
        await _validateExistingSession();
      } else {
        // No tokens, set initial state based on config
        if (_config.allowsGuestAccess) {
          _updateState(_currentState.guest());
        } else {
          _updateState(_currentState.unauthenticated());
        }
      }
    } catch (e) {
      _logger.severe('Failed to initialize AuthService: $e');
      _updateState(_currentState.unauthenticated('Initialization failed'));
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    if (_currentState.status == AuthStatus.authenticating) {
      _logger.warning('Authentication already in progress');
      return false;
    }

    try {
      _updateState(_currentState.copyWith(status: AuthStatus.authenticating));
      
      final result = await onLogin(email, password);
      if (result != null) {
        await _handleAuthSuccess(result);
        return true;
      } else {
        _updateState(_currentState.unauthenticated('Login failed'));
        return false;
      }
    } catch (e) {
      _logger.severe('Login failed: $e');
      _updateState(_currentState.unauthenticated('Login failed: $e'));
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final token = _tokenManager.accessToken;
      
      // Call logout callback
      await onLogout(token);
      
      // Clear local state
      await _clearSession();
      
      // Update state based on config
      if (_config.allowsGuestAccess) {
        _updateState(_currentState.guest());
      } else {
        _updateState(_currentState.unauthenticated());
      }
      
      _logger.info('Logout successful');
    } catch (e) {
      _logger.severe('Logout failed: $e');
      // Still clear local session even if server call fails
      await _clearSession();
      _updateState(_currentState.unauthenticated('Logout failed: $e'));
    }
  }

  /// Refresh token if needed
  Future<bool> refreshTokenIfNeeded() async {
    // Prevent concurrent refresh attempts
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return _currentState.isAuthenticated;
    }

    if (!_tokenManager.hasRefreshToken) {
      _logger.warning('No refresh token available');
      return false;
    }

    final shouldRefresh = _tokenManager.shouldRefreshToken(_config.refreshBeforeExpiry);
    if (!shouldRefresh && !_tokenManager.isAccessTokenExpired) {
      return true; // Token is still valid
    }

    return await _performTokenRefresh();
  }

  /// Force token refresh
  Future<bool> forceRefreshToken() async {
    return await _performTokenRefresh();
  }

  /// Check if route requires authentication
  bool requiresAuth(String route) {
    if (_config.allowsGuestAccess) {
      return !_config.isPublicRoute(route);
    }
    return true; // All routes require auth in authRequired mode
  }

  /// Validate existing session
  Future<void> _validateExistingSession() async {
    if (_tokenManager.isAccessTokenExpired) {
      _logger.info('Access token expired, attempting refresh');
      
      if (_tokenManager.hasRefreshToken) {
        final refreshSuccess = await _performTokenRefresh();
        if (!refreshSuccess) {
          await _handleSessionExpired();
        }
      } else {
        await _handleSessionExpired();
      }
    } else {
      // Token is valid, restore authenticated state
      final userData = _tokenManager.userData;
      final token = _tokenManager.accessToken!;
      
      _updateState(_currentState.authenticated(
        user: userData ?? {},
        token: token,
        refreshToken: _tokenManager.refreshToken,
      ));
      
      _scheduleTokenRefresh();
    }
  }

  /// Perform token refresh
  Future<bool> _performTokenRefresh() async {
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return _currentState.isAuthenticated;
    }

    _refreshCompleter = Completer<void>();
    
    try {
      _updateState(_currentState.refreshing());
      _logger.info('Refreshing token...');
      
      final refreshToken = _tokenManager.refreshToken;
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      int attempts = 0;
      while (attempts < _config.maxRetryAttempts) {
        try {
          final result = await onRefreshToken(refreshToken);
          if (result != null) {
            await _handleAuthSuccess(result);
            _refreshCompleter!.complete();
            return true;
          }
          break; // Don't retry if callback returns null
        } catch (e) {
          attempts++;
          _logger.warning('Token refresh attempt $attempts failed: $e');
          
          if (attempts < _config.maxRetryAttempts) {
            await Future.delayed(_config.retryDelay);
          } else {
            rethrow;
          }
        }
      }
      
      throw Exception('Token refresh failed after $attempts attempts');
    } catch (e) {
      _logger.severe('Token refresh failed: $e');
      await _handleSessionExpired();
      _refreshCompleter!.complete();
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Handle successful authentication
  Future<void> _handleAuthSuccess(Map<String, dynamic> authData) async {
    final token = authData['access_token'] ?? authData['accessToken'] ?? authData['token'];
    final refreshToken = authData['refresh_token'] ?? authData['refreshToken'];
    final user = authData['user'] ?? authData;

    if (token == null) {
      throw Exception('No access token in auth response');
    }

    await _tokenManager.saveTokens(
      accessToken: token,
      refreshToken: refreshToken,
      userData: user is Map<String, dynamic> ? user : null,
    );

    _updateState(_currentState.authenticated(
      user: user is Map<String, dynamic> ? user : {},
      token: token,
      refreshToken: refreshToken,
    ));

    _scheduleTokenRefresh();
  }

  /// Handle session expired
  Future<void> _handleSessionExpired() async {
    _logger.info('Session expired, clearing tokens');
    
    await _clearSession();
    
    if (_config.allowsGuestAccess) {
      _updateState(_currentState.guest());
    } else {
      _updateState(_currentState.expired());
    }

    onSessionExpired?.call();
  }

  /// Clear session data
  Future<void> _clearSession() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    await _tokenManager.clearTokens();
  }

  /// Schedule next token refresh
  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();
    
    final expiryTime = _tokenManager.accessTokenExpiryTime;
    if (expiryTime != null) {
      final refreshTime = expiryTime.subtract(_config.refreshBeforeExpiry);
      final now = DateTime.now();
      
      if (refreshTime.isAfter(now)) {
        final duration = refreshTime.difference(now);
        _logger.info('Scheduling token refresh in ${duration.inMinutes} minutes');
        
        _refreshTimer = Timer(duration, () {
          _performTokenRefresh();
        });
      } else {
        // Should refresh immediately
        Future.microtask(() => _performTokenRefresh());
      }
    }
  }

  /// Update state and notify listeners
  void _updateState(AuthState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
    _logger.fine('Auth state updated: ${_currentState.status}');
  }

  /// Dispose resources
  void dispose() {
    _refreshTimer?.cancel();
    _stateController.close();
  }
}