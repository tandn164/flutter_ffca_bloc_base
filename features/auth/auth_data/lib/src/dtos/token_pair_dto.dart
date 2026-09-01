import 'package:auth_domain/auth_domain.dart';

class TokenPairDto {
  const TokenPairDto({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory TokenPairDto.fromJson(Object json) {
    final map = json as Map<String, dynamic>;
    return TokenPairDto(
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
    );
  }

  TokenPair toEntity() => TokenPair(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}
