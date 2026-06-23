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

class AttachDeviceEvent extends AuthenticationEvent {
  final String userId;

  const AttachDeviceEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DetachDeviceEvent extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}