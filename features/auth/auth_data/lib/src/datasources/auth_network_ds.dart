import 'package:app_result/app_result.dart';

import '../api/auth_api.dart';
import '../chopper_result.dart';
import '../dtos/token_pair_dto.dart';

class AuthNetworkDs {
  AuthNetworkDs(this._api);

  final AuthApi _api;

  Future<Result<TokenPairDto>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.login({'email': email, 'password': password});
      return resultFromChopper(response, TokenPairDto.fromJson);
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }

  Future<Result<TokenPairDto>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _api.signup({
        'email': email,
        'password': password,
        'name': name,
      });
      return resultFromChopper(response, TokenPairDto.fromJson);
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }
}
