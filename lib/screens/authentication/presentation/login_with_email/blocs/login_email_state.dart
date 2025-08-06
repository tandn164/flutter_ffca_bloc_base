part of 'login_email_bloc.dart';

@immutable
final class LoginEmailState extends Equatable {
  const LoginEmailState(
      {this.status = LoginEmailStatus.initial,
      this.email = const Email.pure(),
      this.password = const Password.pure(),
      this.isValid = false,
      this.errorMessage = ""});

  final LoginEmailStatus status;
  final Email email;
  final Password password;
  final bool isValid;
  final String errorMessage;

  LoginEmailState copyWith(
      {LoginEmailStatus? status,
      Email? email,
      Password? password,
      bool? isValid,
      String? errorMessage}) {
    return LoginEmailState(
        status: status ?? this.status,
        email: email ?? this.email,
        password: password ?? this.password,
        isValid: isValid ?? this.isValid,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object> get props => [status, email, password];
}
