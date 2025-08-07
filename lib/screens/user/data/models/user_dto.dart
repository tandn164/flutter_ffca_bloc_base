import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_dto.g.dart';

/// Data Transfer Object for User
/// Maps directly to API response structure
/// Contains JSON serialization/deserialization
@JsonSerializable()
class UserDto {
  @JsonKey(name: 'user_id')
  final String id;

  @JsonKey(name: 'email_address')
  final String email;

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'created_timestamp')
  final String createdAt;

  @JsonKey(name: 'is_email_verified')
  final bool isVerified;

  @JsonKey(name: 'is_active')
  final bool isActive;

  const UserDto({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.isVerified,
    required this.isActive,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  /// Convert DTO to Entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      createdAt: DateTime.parse(createdAt),
      isVerified: isVerified,
      isActive: isActive,
    );
  }

  /// Convert Entity to DTO
  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      username: user.username,
      createdAt: user.createdAt.toIso8601String(),
      isVerified: user.isVerified,
      isActive: user.isActive,
    );
  }

  /// Create mock user DTO for testing
  factory UserDto.mock({
    String? id,
    String? email,
    String? username,
  }) {
    return UserDto(
      id: id ?? 'user_123',
      email: email ?? 'john.doe@example.com',
      username: username ?? 'johndoe',
      createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      isVerified: true,
      isActive: true,
    );
  }
} 