// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginSessionDTO _$LoginSessionDTOFromJson(Map<String, dynamic> json) =>
    LoginSessionDTO(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      isVerified: json['isVerified'] as bool?,
    );

Map<String, dynamic> _$LoginSessionDTOToJson(LoginSessionDTO instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'isVerified': instance.isVerified,
    };
