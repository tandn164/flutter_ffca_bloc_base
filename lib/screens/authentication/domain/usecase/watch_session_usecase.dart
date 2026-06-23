import 'package:flutter_bloc_base/screens/authentication/domain/repositories/authentication_repository.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/login_session.dart';

class WatchSessionUseCase implements StreamUseCase<LoginSession?, NoParams> {
  final AuthenticationRepository repository;

  WatchSessionUseCase({required this.repository});

  @override
  Stream<LoginSession?> call(NoParams params) {
    return repository.watchSession();
  }
}