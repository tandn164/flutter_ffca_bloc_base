part of 'register_email_bloc.dart';

abstract class RegisterEmailEvent extends Equatable {
  const RegisterEmailEvent();
}

final class UsernameChanged extends RegisterEmailEvent {
  const UsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

final class EmailChanged extends RegisterEmailEvent {
  const EmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class PasswordChanged extends RegisterEmailEvent {
  const PasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class SendEmailSubmitted extends RegisterEmailEvent {
  const SendEmailSubmitted();

  @override
  List<Object?> get props => [];
}

final class VerificationCodeChangeEvent extends RegisterEmailEvent {
  const VerificationCodeChangeEvent(this.verificationCode);

  final String verificationCode;

  @override
  List<Object> get props => [verificationCode];
}

final class VerifyCodeInitialEvent extends RegisterEmailEvent {
  const VerifyCodeInitialEvent();

  @override
  List<Object?> get props => [];
}

final class CountdownChangeEvent extends RegisterEmailEvent {
  const CountdownChangeEvent();

  @override
  List<Object> get props => [];
}

final class ResendCodeEvent extends RegisterEmailEvent {
  const ResendCodeEvent();

  @override
  List<Object> get props => [];
}

final class RegisterSubmitted extends RegisterEmailEvent {
  const RegisterSubmitted();

  @override
  List<Object?> get props => [];
}
