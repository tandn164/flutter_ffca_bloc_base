// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: json['user_id'] as String,
      email: json['email_address'] as String,
      username: json['username'] as String,
      createdAt: json['created_timestamp'] as String,
      isVerified: json['is_email_verified'] as bool,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'user_id': instance.id,
      'email_address': instance.email,
      'username': instance.username,
      'created_timestamp': instance.createdAt,
      'is_email_verified': instance.isVerified,
      'is_active': instance.isActive,
    };
