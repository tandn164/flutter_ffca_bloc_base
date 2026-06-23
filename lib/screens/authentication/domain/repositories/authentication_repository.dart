import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/login_session.dart';

abstract class AuthenticationRepository {
  /// Login with cache update
  Future<Either<Failure, LoginSession>> login(String email, String password);
  
  /// Register with cache update
  Future<Either<Failure, LoginSession>> register(String username, String email, String password);
  
  /// Fetch cached session (cache-first, no network)
  Future<Either<Failure, LoginSession?>> fetchLastSession();
  
  /// Watch session changes reactively
  Stream<LoginSession?> watchSession();
  
  /// Logout and clear cache
  Future<Either<Failure, void>> logout();
}
