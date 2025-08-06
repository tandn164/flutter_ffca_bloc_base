import 'package:dartz/dartz.dart';

import '../entities/login_param.dart';
import '../entities/login_session.dart';
import '../repositories/authentication_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class LoginUseCase implements UseCase<LoginSession, LoginParams> {
  final AuthenticationRepository repository;

  LoginUseCase({required this.repository});

  @override
  Future<Either<Failure, LoginSession>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}
