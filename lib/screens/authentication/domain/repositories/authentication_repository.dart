import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/login_session.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, LoginSession>> login(String email, String password);
  Future<Either<Failure, LoginSession>> register(
      String username, String email, String password);
  Future<Either<Failure, LoginSession>> fetchLastSession();
  Future<Either<Failure, void>> logout();
}
