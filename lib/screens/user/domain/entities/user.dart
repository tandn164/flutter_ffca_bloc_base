import 'package:equatable/equatable.dart';

/// User entity representing core business object
/// Contains business logic and rules
/// Independent of external frameworks
class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.isVerified,
    required this.isActive,
  });

  // Business logic methods
  bool canCreatePost() => isVerified && isActive && email.isNotEmpty;

  bool canFollowOthers() => isVerified && isActive;

  String get displayName {
    return username.isEmpty ? email : username;
  }

  String get initials {
    if (username.isNotEmpty) return username[0].toUpperCase();
    return email[0].toUpperCase();
  }

  /// Account age in days
  int get accountAgeInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if user is new (created within last 7 days)
  bool get isNewUser => accountAgeInDays <= 7;

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        createdAt,
        isVerified,
        isActive,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username)';
  }
} 