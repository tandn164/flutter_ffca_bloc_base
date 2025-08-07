// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginEmailDto _$LoginEmailDtoFromJson(Map<String, dynamic> json) =>
    LoginEmailDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginEmailDtoToJson(LoginEmailDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterEmailDto _$RegisterEmailDtoFromJson(Map<String, dynamic> json) =>
    RegisterEmailDto(
      email: json['email'] as String,
      password: json['password'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$RegisterEmailDtoToJson(RegisterEmailDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'username': instance.username,
    };
