import 'package:json_annotation/json_annotation.dart';

part 'authentication_dtos.g.dart';

@JsonSerializable()
class LoginEmailDto {
  final String email;
  final String password;

  const LoginEmailDto({
    required this.email,
    required this.password
  });

  /// Connect the generated [_$LoginEmailDtoFromJson] function to the `fromJson` factory.
  factory LoginEmailDto.fromJson(Map<String, dynamic> json) => _$LoginEmailDtoFromJson(json);

  /// Connect the generated [_$LoginEmailDtoToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$LoginEmailDtoToJson(this);
}

@JsonSerializable()
class RegisterEmailDto {
  final String email;
  final String password;
  final String username;

  const RegisterEmailDto({
    required this.email,
    required this.password,
    required this.username,
  });

  /// Connect the generated [_$RegisterEmailDtoFromJson] function to the `fromJson` factory.
  factory RegisterEmailDto.fromJson(Map<String, dynamic> json) => _$RegisterEmailDtoFromJson(json);

  /// Connect the generated [_$RegisterEmailDtoToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$RegisterEmailDtoToJson(this);
}
