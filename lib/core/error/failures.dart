import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../base/base_response.dart';
import '../utils/widget_util.dart';
import 'error_code.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message, [List properties = const <dynamic>[]]) : super();
}

class ServerFailure extends Failure {

  const ServerFailure([String message = 'Server error occurred']) : super(message);

  factory ServerFailure.fromObject(Object? object) {
    final meta = Meta.fromJson(jsonDecode(object as String)["meta"]);
    String msg = meta.msg ?? meta.message ?? l10n.unknownError;
    if (msg.length > 150) {
      msg = msg.substring(0, 150);
    }
    if (meta.errorCode != null) {
      final errorCode = ErrorCode.fromValue(meta.errorCode!);
      msg = errorCode.errorMessage;
    }
    return ServerFailure(msg);
  }

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);

  @override
  List<Object?> get props => [message];
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error occurred']) : super(message);

  @override
  List<Object?> get props => [message];
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure([String message = 'No connection available']) : super(message);

  @override
  List<Object?> get props => [message];
}
