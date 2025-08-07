import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/widget_util.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final userDto = await dataSource.getCurrentUser();
        return Right(userDto.toEntity());
      } on ServerException {
        return Left(ServerFailure(l10n.unknownError));
      } on CacheException {
        return Left(CacheFailure(l10n.cacheFailure));
      } catch (e) {
        return Left(ServerFailure(l10n.unknownError));
      }
    } else {
      return Left(NoConnectionFailure(l10n.noConnectionFailure));
    }
  }
} 