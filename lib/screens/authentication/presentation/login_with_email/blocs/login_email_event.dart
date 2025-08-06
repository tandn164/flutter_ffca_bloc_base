part of 'login_email_bloc.dart';

@immutable
abstract class LoginEmailEvent extends Equatable {
  const LoginEmailEvent([List props = const <dynamic>[]]) : super();
}

final class LoginEmailChanged extends LoginEmailEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class LoginPasswordChanged extends LoginEmailEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class LoginSubmitted extends LoginEmailEvent {
  const LoginSubmitted();

  @override
  List<Object?> get props => [];
}