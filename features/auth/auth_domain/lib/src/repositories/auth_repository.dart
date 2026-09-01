import 'package:app_result/app_result.dart';

import '../entities/token_pair.dart';

abstract class AuthRepository {
  Future<Result<TokenPair>> login({required String email, required String password});

  Future<Result<TokenPair>> signup({
    required String email,
    required String password,
    required String name,
  });
}
