enum AuthStatus {
  /// Initial state, checking authentication
  initial,
  
  /// User is authenticated
  authenticated,
  
  /// User is in guest mode (unauthenticated but allowed)
  guest,
  
  /// Authentication is required but user is not authenticated
  unauthenticated,
  
  /// Session has expired and needs refresh
  expired,
  
  /// Authentication is in progress
  authenticating,
  
  /// Refreshing token
  refreshing,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.refreshToken,
    this.error,
    this.isRefreshing = false,
  });

  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? token;
  final String? refreshToken;
  final String? error;
  final bool isRefreshing;

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && token != null;
  
  /// Check if user is guest
  bool get isGuest => status == AuthStatus.guest;
  
  /// Check if needs authentication
  bool get needsAuth => status == AuthStatus.unauthenticated || status == AuthStatus.expired;

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? token,
    String? refreshToken,
    String? error,
    bool? isRefreshing,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  /// Create authenticated state
  AuthState authenticated({
    required Map<String, dynamic> user,
    required String token,
    String? refreshToken,
  }) {
    return copyWith(
      status: AuthStatus.authenticated,
      user: user,
      token: token,
      refreshToken: refreshToken,
      error: null,
      isRefreshing: false,
    );
  }

  /// Create guest state
  AuthState guest() {
    return copyWith(
      status: AuthStatus.guest,
      user: null,
      token: null,
      refreshToken: null,
      error: null,
      isRefreshing: false,
    );
  }

  /// Create unauthenticated state
  AuthState unauthenticated([String? error]) {
    return copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      token: null,
      refreshToken: null,
      error: error,
      isRefreshing: false,
    );
  }

  /// Create expired state
  AuthState expired([String? error]) {
    return copyWith(
      status: AuthStatus.expired,
      error: error,
      isRefreshing: false,
    );
  }

  /// Create refreshing state
  AuthState refreshing() {
    return copyWith(
      status: AuthStatus.refreshing,
      isRefreshing: true,
      error: null,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, isAuthenticated: $isAuthenticated, isRefreshing: $isRefreshing)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.token == token &&
        other.refreshToken == refreshToken &&
        other.error == error &&
        other.isRefreshing == isRefreshing;
  }

  @override
  int get hashCode {
    return Object.hash(status, user, token, refreshToken, error, isRefreshing);
  }
}