import 'package:meta/meta.dart';

import 'api_failure.dart';

@immutable
sealed class ApiResult<T> {
  const ApiResult();
}

@immutable
final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.value);
  final T value;
}

@immutable
final class ApiError<T> extends ApiResult<T> {
  const ApiError(this.failure);
  final ApiFailure failure;
}
