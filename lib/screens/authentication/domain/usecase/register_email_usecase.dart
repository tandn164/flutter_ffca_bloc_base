import 'package:dartz/dartz.dart';

import '../entities/login_session.dart';
import '../entities/register_email_params.dart';
import '../repositories/authentication_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class RegisterEmailUseCase implements UseCase<LoginSession, RegisterEmailParams> {
  final AuthenticationRepository repository;

  RegisterEmailUseCase({required this.repository});

  @override
  Future<Either<Failure, LoginSession>> call(RegisterEmailParams params) async {
    return await repository.register(params.username, params.email, params.password);
  }
}
