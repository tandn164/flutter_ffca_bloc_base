import 'package:app_result/app_result.dart';
import 'package:flutter/foundation.dart';

import 'session.dart';

enum DebugRefresh { ok, revoke, network }

/// In-memory Session for tests and apps that omit persisted auth.
class StubSession extends ChangeNotifier implements Session {
  StubSession({
    this.guestAllowed = true,
    this.restoreDelay = const Duration(milliseconds: 400),
    String? persistedAccessToken,
    String? persistedRefreshToken,
  })  : _access = persistedAccessToken,
        _refresh = persistedRefreshToken;

  final bool guestAllowed;
  final Duration restoreDelay;

  SessionState _state = const SessionState(status: SessionStatus.unknown);
  String? _access;
  String? _refresh;
  DebugRefresh debugRefresh = DebugRefresh.ok;

  @visibleForTesting
  int refreshCalls = 0;

  @visibleForTesting
  String? get debugAccessToken => _access;

  @override
  SessionState get state => _state;

  @override
  Map<String, String> get authorizationHeaders {
    final token = _access;
    if (token == null || token.isEmpty) return const {};
    return {'Authorization': 'Bearer $token'};
  }

  @override
  Stream<SessionState> watch() {
    return Stream<SessionState>.multi((controller) {
      controller.add(_state);
      void listener() => controller.add(_state);
      addListener(listener);
      controller.onCancel = () => removeListener(listener);
    });
  }

  void _set(SessionState next) {
    _state = next;
    notifyListeners();
  }

  @override
  Future<void> restore() async {
    if (restoreDelay > Duration.zero) {
      await Future<void>.delayed(restoreDelay);
    }
    if (_access != null && _access!.isNotEmpty) {
      _set(const SessionState(status: SessionStatus.authenticated));
      return;
    }
    if (guestAllowed) {
      _set(const SessionState(status: SessionStatus.guest));
    } else {
      _set(const SessionState(status: SessionStatus.unauthenticated));
    }
  }

  @override
  Future<void> signIn({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
    refreshCalls = 0;
    _set(const SessionState(status: SessionStatus.authenticated));
  }

  @override
  Future<void> signOut({bool kick = false}) async {
    _access = null;
    _refresh = null;
    _set(SessionState(
      status: guestAllowed && !kick
          ? SessionStatus.guest
          : SessionStatus.unauthenticated,
    ));
  }

  @override
  Future<bool> refresh() async {
    refreshCalls++;
    switch (debugRefresh) {
      case DebugRefresh.network:
        return false;
      case DebugRefresh.revoke:
        throw const AuthFailure('refresh revoked');
      case DebugRefresh.ok:
        if (_refresh == null) return false;
        _access = 'access-refreshed';
        _set(const SessionState(status: SessionStatus.authenticated));
        return true;
    }
  }
}
