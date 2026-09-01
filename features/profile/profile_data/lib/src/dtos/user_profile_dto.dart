import 'package:profile_domain/profile_domain.dart';

class UserProfileDto {
  const UserProfileDto({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory UserProfileDto.fromJson(Object json) {
    final map = json as Map<String, dynamic>;
    return UserProfileDto(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  UserProfile toEntity() => UserProfile(id: id, name: name, email: email);
}
