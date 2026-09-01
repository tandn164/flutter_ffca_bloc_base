import 'package:app_result/app_result.dart';
import 'package:auth_domain/auth_domain.dart';

import '../api/auth_api.dart';
import '../datasources/auth_network_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(AuthApi api) : _network = AuthNetworkDs(api);

  final AuthNetworkDs _network;

  @override
  Future<Result<TokenPair>> login({
    required String email,
    required String password,
  }) async {
    final result = await _network.login(email: email, password: password);
    return result.fold(
      ok: (dto) => Ok(dto.toEntity()),
      err: (failure) => Err(failure),
    );
  }

  @override
  Future<Result<TokenPair>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await _network.signup(
      email: email,
      password: password,
      name: name,
    );
    return result.fold(
      ok: (dto) => Ok(dto.toEntity()),
      err: (failure) => Err(failure),
    );
  }
}
