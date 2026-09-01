import 'package:auth_domain/auth_domain.dart';

abstract interface class TokenRefresher {
  /// New tokens, or `null` on transient failure (network / 5xx).
  /// Throw to signal revoked refresh (caller kicks the session).
  Future<TokenPair?> refresh(String refreshToken);
}
