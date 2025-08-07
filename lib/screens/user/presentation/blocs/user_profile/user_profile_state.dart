import 'package:equatable/equatable.dart';
import '../../models/user_profile_model.dart';

/// Base class for user profile states
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is first created
class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

/// State when loading user profile
class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

/// State when user profile is loaded successfully
class UserProfileLoaded extends UserProfileState {
  final UserProfileModel profileModel;

  const UserProfileLoaded({required this.profileModel});

  @override
  List<Object?> get props => [profileModel];
}

/// State when profile operation is successful
class UserProfileSuccess extends UserProfileState {
  final UserProfileModel profileModel;
  final String? message;

  const UserProfileSuccess({
    required this.profileModel,
    this.message,
  });

  @override
  List<Object?> get props => [profileModel, message];
}

/// State when an error occurs
class UserProfileError extends UserProfileState {
  final UserProfileModel? profileModel;
  final String message;

  const UserProfileError({
    this.profileModel,
    required this.message,
  });

  @override
  List<Object?> get props => [profileModel, message];
} 