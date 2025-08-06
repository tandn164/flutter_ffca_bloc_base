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

  const ServerFailure(super.message);

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
  const CacheFailure(super.message);

  @override
  List<Object?> get props => [message];
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure(super.message);

  @override
  List<Object?> get props => [message];
}
