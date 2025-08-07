import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/widget_util.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../models/user_profile_model.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  UserProfileBloc({
    required this.getCurrentUserUseCase,
  }) : super(const UserProfileInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<RefreshUserProfileEvent>(_onRefreshUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) => emit(UserProfileError(message: failure.message)),
      (user) {
        final profileModel = UserProfileModel(user: user);
        emit(UserProfileLoaded(profileModel: profileModel));
      },
    );
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    // Re-trigger load user profile
    add(const LoadUserProfileEvent());
  }
} 