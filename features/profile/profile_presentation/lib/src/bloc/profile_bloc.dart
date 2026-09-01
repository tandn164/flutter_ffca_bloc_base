import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_domain/profile_domain.dart';

enum ProfileNoticeKind { success, error }

class ProfileNotice extends Equatable {
  const ProfileNotice({
    required this.message,
    required this.kind,
    required this.id,
  });

  final String message;
  final ProfileNoticeKind kind;
  final int id;

  @override
  List<Object?> get props => [message, kind, id];
}

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileSaved extends ProfileEvent {
  const ProfileSaved(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

class ProfileSignedOut extends ProfileEvent {
  const ProfileSignedOut();
}

sealed class ProfileState extends Equatable {
  const ProfileState({this.busy = false, this.notice});

  final bool busy;
  final ProfileNotice? notice;
}

class ProfileLoading extends ProfileState {
  const ProfileLoading({super.busy, super.notice});

  @override
  List<Object?> get props => [busy, notice];
}

class ProfileData extends ProfileState {
  const ProfileData(this.profile, {super.busy, super.notice});
  final UserProfile profile;

  @override
  List<Object?> get props => [profile, busy, notice];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message, {super.busy, super.notice});
  final String message;

  @override
  List<Object?> get props => [message, busy, notice];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required Future<void> Function() onSignOut,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _onSignOut = onSignOut,
        super(const ProfileLoading()) {
    on<ProfileStarted>(_load);
    on<ProfileSaved>(_save);
    on<ProfileSignedOut>(_signOut);
  }

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final Future<void> Function() _onSignOut;
  int _noticeId = 0;

  ProfileNotice _notice(String message, ProfileNoticeKind kind) {
    return ProfileNotice(message: message, kind: kind, id: ++_noticeId);
  }

  Future<void> _load(ProfileStarted event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    final result = await _getProfile.execute();
    result.fold(
      ok: (profile) => emit(ProfileData(profile)),
      err: (f) => emit(ProfileError(
        f.message,
        notice: _notice(f.message, ProfileNoticeKind.error),
      )),
    );
  }

  Future<void> _save(ProfileSaved event, Emitter<ProfileState> emit) async {
    final current = state;
    if (current is ProfileData) {
      emit(ProfileData(current.profile, busy: true));
    }
    try {
      final result = await _updateProfile.execute(name: event.name);
      result.fold(
        ok: (profile) => emit(ProfileData(
          profile,
          notice: _notice('Profile updated', ProfileNoticeKind.success),
        )),
        err: (f) {
          if (current is ProfileData) {
            emit(ProfileData(
              current.profile,
              notice: _notice(f.message, ProfileNoticeKind.error),
            ));
          } else {
            emit(ProfileError(
              f.message,
              notice: _notice(f.message, ProfileNoticeKind.error),
            ));
          }
        },
      );
    } finally {
      if (!isClosed && state.busy) {
        final latest = state;
        if (latest is ProfileData) {
          emit(ProfileData(latest.profile, notice: latest.notice));
        } else if (latest is ProfileError) {
          emit(ProfileError(latest.message, notice: latest.notice));
        }
      }
    }
  }

  Future<void> _signOut(ProfileSignedOut event, Emitter<ProfileState> emit) async {
    await _onSignOut();
  }
}
