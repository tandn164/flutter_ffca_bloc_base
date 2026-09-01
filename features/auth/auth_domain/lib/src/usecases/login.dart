import 'package:app_result/app_result.dart';

import '../entities/token_pair.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<TokenPair>> execute({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
