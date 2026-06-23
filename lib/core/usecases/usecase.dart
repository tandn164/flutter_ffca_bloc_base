import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_base/core/error/failures.dart';

/// Base interface for all use cases
/// 
/// Use cases represent the business logic of the application.
/// They should be independent of the UI and external frameworks.
/// 
/// Type Parameters:
/// - [Type]: The return type of the use case
/// - [Params]: The input parameters required by the use case
/// 
/// Example:
/// ```dart
/// class LoginUseCase implements UseCase<LoginSession, LoginParams> {
///   @override
///   Future<Either<Failure, LoginSession>> call(LoginParams params) async {
///     // Business logic here
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Execute the use case with given parameters
  /// 
  /// Returns [Either<Failure, Type>]:
  /// - Left: Contains a [Failure] if the operation failed
  /// - Right: Contains the result of type [Type] if successful
  Future<Either<Failure, Type>> call(Params params);
}

/// Base interface for stream-based use cases
/// 
/// Stream use cases are used for reactive operations that emit
/// multiple values over time, such as watching data changes.
/// 
/// Type Parameters:
/// - [Type]: The stream element type
/// - [Params]: The input parameters required by the use case
/// 
/// Example:
/// ```dart
/// class WatchUserUseCase implements StreamUseCase<User, NoParams> {
///   @override
///   Stream<User> call(NoParams params) {
///     return repository.watchUser();
///   }
/// }
/// ```
abstract class StreamUseCase<Type, Params> {
  /// Execute the stream use case with given parameters
  /// 
  /// Returns a [Stream<Type>] that emits values over time
  Stream<Type> call(Params params);
}

/// Standard parameter class to use when a UseCase doesn't need any parameters
/// 
/// This provides a consistent way to handle parameterless use cases
/// instead of using `void` which can be inconsistent.
/// 
/// Example:
/// ```dart
/// class GetCurrentUserUseCase implements UseCase<User, NoParams> {
///   @override
///   Future<Either<Failure, User>> call(NoParams params) async {
///     return await repository.getCurrentUser();
///   }
/// }
/// 
/// // Usage:
/// final result = await getCurrentUserUseCase(NoParams());
/// ```
class NoParams extends Equatable {
  /// Creates a NoParams instance
  const NoParams();

  @override
  List<Object> get props => [];
}
