import 'package:equatable/equatable.dart';
import '../../../../core/utils/widget_util.dart';
import '../../domain/entities/user.dart';

/// UI model for user profile screen state
/// Contains both the user entity and UI-specific properties
class UserProfileModel extends Equatable {
  final User user;
  final bool isLoading;
  final bool isUpdating;
  final bool isUploadingAvatar;
  final String? errorMessage;
  final String? successMessage;

  const UserProfileModel({
    required this.user,
    this.isLoading = false,
    this.isUpdating = false,
    this.isUploadingAvatar = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get isProcessing => isLoading || isUpdating || isUploadingAvatar;

  String get memberSinceText {
    final now = DateTime.now();
    final difference = now.difference(user.createdAt);
    
    if (difference.inDays == 0) {
      return l10n.userToday;
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).round();
      return '$months months ago';
    } else {
      final years = (difference.inDays / 365).round();
      return '$years years ago';
    }
  }

  bool get canEditProfile => !isProcessing && user.isActive;

  // State management methods
  UserProfileModel copyWith({
    User? user,
    bool? isLoading,
    bool? isUpdating,
    bool? isUploadingAvatar,
    String? errorMessage,
    String? successMessage,
  }) {
    return UserProfileModel(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  UserProfileModel clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  UserProfileModel setLoading() {
    return copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  UserProfileModel setUpdating() {
    return copyWith(
      isUpdating: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  UserProfileModel setUploadingAvatar() {
    return copyWith(
      isUploadingAvatar: true,
      errorMessage: null,
      successMessage: null,
    );
  }

  UserProfileModel setSuccess(User updatedUser, [String? message]) {
    return copyWith(
      user: updatedUser,
      isLoading: false,
      isUpdating: false,
      isUploadingAvatar: false,
      errorMessage: null,
      successMessage: message,
    );
  }

  UserProfileModel setError(String error) {
    return copyWith(
      isLoading: false,
      isUpdating: false,
      isUploadingAvatar: false,
      errorMessage: error,
      successMessage: null,
    );
  }

  @override
  List<Object?> get props => [
        user,
        isLoading,
        isUpdating,
        isUploadingAvatar,
        errorMessage,
        successMessage,
      ];
} 