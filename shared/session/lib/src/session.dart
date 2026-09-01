import 'package:flutter/foundation.dart';

enum SessionStatus { unknown, guest, unauthenticated, authenticated }

class SessionState {
  const SessionState({required this.status});

  final SessionStatus status;

  bool get isAuthenticated => status == SessionStatus.authenticated;
}

/// App gateway for GoRouter and the auth interceptor. Use cases do not read this.
abstract class Session implements Listenable {
  SessionState get state;

  Stream<SessionState> watch();

  Future<void> restore();
  Future<void> signIn(
      {required String accessToken, required String refreshToken});
  Future<void> signOut({bool kick = false});

  /// True if tokens refreshed. False on transient failure (do not kick).
  /// Throw if refresh is revoked (caller kicks).
  Future<bool> refresh();

  Map<String, String> get authorizationHeaders;
}
