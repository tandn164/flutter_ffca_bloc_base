import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for getting current user profile
/// Implements business logic for fetching user data
class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  final UserRepository repository;

  GetCurrentUserUseCase({required this.repository});

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
} 