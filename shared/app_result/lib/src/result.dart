sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  });

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;
  Failure? get failureOrNull =>
      this is Err<T> ? (this as Err<T>).failure : null;
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  R fold<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) =>
      ok(value);
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  R fold<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) =>
      err(failure);
}

sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class DecodeFailure extends Failure {
  const DecodeFailure([super.message = 'Could not decode response']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}
