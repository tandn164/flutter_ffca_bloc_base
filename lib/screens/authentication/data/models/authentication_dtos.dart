import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/login_session.dart';

part 'authentication_dtos.g.dart';

@JsonSerializable()
class LoginSessionDTO extends LoginSession {
  LoginSessionDTO({
    super.accessToken,
    super.refreshToken,
    super.isVerified,
  });

  /// Connect the generated [_$LoginSessionDTOFromJson] function to the `fromJson` factory.
  factory LoginSessionDTO.fromJson(Map<String, dynamic> json) => _$LoginSessionDTOFromJson(json);

  /// Connect the generated [_$LoginSessionDTOToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$LoginSessionDTOToJson(this);
}
