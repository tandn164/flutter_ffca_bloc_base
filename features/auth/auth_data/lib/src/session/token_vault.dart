class StoredTokens {
  const StoredTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

abstract class TokenVault {
  Future<StoredTokens?> read();

  Future<void> write({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clear();
}

class MemoryTokenVault implements TokenVault {
  StoredTokens? _tokens;

  @override
  Future<StoredTokens?> read() async => _tokens;

  @override
  Future<void> write({
    required String accessToken,
    required String refreshToken,
  }) async {
    _tokens = StoredTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> clear() async => _tokens = null;
}

class PrefsTokenVault implements TokenVault {
  PrefsTokenVault(
    this._get,
    this._set, {
    this.accessKey = 'auth.access',
    this.refreshKey = 'auth.refresh',
  });

  final String? Function(String key) _get;
  final Future<bool> Function(String key, String value) _set;
  final String accessKey;
  final String refreshKey;

  @override
  Future<StoredTokens?> read() async {
    final access = _get(accessKey);
    final refresh = _get(refreshKey);
    if (access == null || access.isEmpty || refresh == null || refresh.isEmpty) {
      return null;
    }
    return StoredTokens(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> write({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _set(accessKey, accessToken);
    await _set(refreshKey, refreshToken);
  }

  @override
  Future<void> clear() async {
    await _set(accessKey, '');
    await _set(refreshKey, '');
  }
}
