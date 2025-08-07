import 'package:equatable/equatable.dart';

/// Base class for user profile events
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load current user profile
class LoadUserProfileEvent extends UserProfileEvent {
  const LoadUserProfileEvent();
}

/// Event to refresh user profile
class RefreshUserProfileEvent extends UserProfileEvent {
  const RefreshUserProfileEvent();
}
