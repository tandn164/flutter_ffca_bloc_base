import 'package:app_result/app_result.dart';

import '../entities/token_pair.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase {
  SignupUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<TokenPair>> execute({
    required String email,
    required String password,
    required String name,
  }) {
    return _repository.signup(email: email, password: password, name: name);
  }
}
