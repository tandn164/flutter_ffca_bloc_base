import 'package:dartz/dartz.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/repositories/authentication_repository.dart';

import '../../../../core/utils/widget_util.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class TokenUseCase implements UseCase<String, void> {
  final AuthenticationRepository repository;

  TokenUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(void params) async {
    final response = await repository.fetchLastSession();
    return response.fold((l) => left(l), (r) {
      if (r.accessToken == null) {
        return left(CacheFailure(l10n.cacheFailure));
      } else {
        return right(r.accessToken!);
      }
    });
  }
}