import 'package:app_session/app_session.dart';
import 'package:flutter/foundation.dart';

import 'token_refresher.dart';
import 'token_vault.dart';

class AuthSession extends ChangeNotifier implements Session {
  AuthSession({
    required this.vault,
    required this.refresher,
    this.guestAllowed = true,
    this.restoreDelay = const Duration(milliseconds: 400),
  });

  final TokenVault vault;
  final TokenRefresher refresher;
  final bool guestAllowed;
  final Duration restoreDelay;

  SessionState _state = const SessionState(status: SessionStatus.unknown);
  String? _access;
  String? _refresh;
  Future<bool>? _refreshing;

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
    final stored = await vault.read();
    if (stored != null) {
      _access = stored.accessToken;
      _refresh = stored.refreshToken;
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
    refreshCalls = 0;
    await _persist(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> _persist({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
    await vault.write(accessToken: accessToken, refreshToken: refreshToken);
    _set(const SessionState(status: SessionStatus.authenticated));
  }

  @override
  Future<void> signOut({bool kick = false}) async {
    _access = null;
    _refresh = null;
    await vault.clear();
    _set(SessionState(
      status: guestAllowed && !kick ? SessionStatus.guest : SessionStatus.unauthenticated,
    ));
  }

  @override
  Future<bool> refresh() {
    _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
    return _refreshing!;
  }

  Future<bool> _doRefresh() async {
    refreshCalls++;
    final token = _refresh;
    if (token == null || token.isEmpty) return false;
    final pair = await refresher.refresh(token);
    if (pair == null) return false;
    await _persist(accessToken: pair.accessToken, refreshToken: pair.refreshToken);
    return true;
  }
}
