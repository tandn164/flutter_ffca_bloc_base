part of 'authentication_bloc.dart';

@immutable
class AuthenticationState extends Equatable {
  final AuthStatus authStatus;

  const AuthenticationState._({
    this.authStatus = AuthStatus.initial,
  });

  const AuthenticationState.initial() : this._();

  const AuthenticationState.update({
    required AuthStatus authStatus,
  }) : this._(
          authStatus: authStatus,
        );

  AuthenticationState copyWith({
    AuthStatus? authStatus,
  }) {
    return AuthenticationState.update(
      authStatus: authStatus ?? this.authStatus,
    );
  }

  bool get isGuest => authStatus.isGuest;
  bool get isUser => authStatus.isUser;

  @override
  List<Object?> get props =>
      [authStatus];
}
