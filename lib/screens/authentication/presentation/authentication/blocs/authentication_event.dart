part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent([List props = const <dynamic>[]]) : super();
}

class CheckAuthenticateEvent extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}

class LogoutEvent extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}

class TokenExpiredEvent extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}