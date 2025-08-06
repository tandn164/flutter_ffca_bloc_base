import 'package:dartz/dartz.dart';

import '../../domain/entities/login_session.dart';
import '../datasources/authentication_datasource.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/widget_util.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationDataSource dataSource;
  final NetworkInfo networkInfo;

  AuthenticationRepositoryImpl(
      {required this.dataSource, required this.networkInfo});

  @override
  Future<Either<Failure, LoginSession>> login(
      String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.login(email, password);
        if (result.data != null) {
          dataSource.cacheSession(result.data!);
          return Right(result.data!);
        } else {
          return Left(
              ServerFailure(result.meta?.msg ?? l10n.unknownError));
        }
      } on CacheException {
        return Left(CacheFailure(l10n.cacheFailure));
      }
    } else {
      return Left(NoConnectionFailure(l10n.noConnectionFailure));
    }
  }

  @override
  Future<Either<Failure, LoginSession>> register(
      String username, String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await dataSource.register(username, email, password);
        if (result.data != null) {
          dataSource.cacheSession(result.data!);
          return Right(result.data!);
        } else {
          return Left(
              ServerFailure(result.meta?.msg ?? l10n.unknownError));
        }
      } on CacheException {
        return Left(CacheFailure(l10n.cacheFailure));
      }
    } else {
      return Left(NoConnectionFailure(l10n.noConnectionFailure));
    }
  }


  @override
  Future<Either<Failure, LoginSession>> fetchLastSession() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.getLastLoginSession();
        return Right(result);
      } on CacheException {
        return Left(CacheFailure(l10n.cacheFailure));
      }
    } else {
      return Left(NoConnectionFailure(l10n.noConnectionFailure));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final result = await dataSource.logout();
    return Right(result);
  }
}
