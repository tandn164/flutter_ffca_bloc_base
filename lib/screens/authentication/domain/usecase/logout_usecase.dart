import 'package:dartz/dartz.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/repositories/authentication_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class LogoutUseCase implements UseCase<void, void> {
  final AuthenticationRepository repository;

  LogoutUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(void params) async {
    return await repository.logout();
  }
}