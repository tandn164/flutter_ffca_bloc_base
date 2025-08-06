part of 'register_email_bloc.dart';

@immutable
final class RegisterEmailState extends Equatable {
  const RegisterEmailState(
      {this.status = RegisterEmailStatus.initialRegisterEmail,
      this.username = const Username.pure(),
      this.email = const Email.pure(),
      this.password = const Password.pure(),
      this.isInfoValid = false,
      this.errorMessage = ""});

  final RegisterEmailStatus status;
  final Username username;
  final Email email;
  final Password password;
  final bool isInfoValid;
  final String errorMessage;

  RegisterEmailState copyWith(
      {RegisterEmailStatus? status,
      Username? username,
      Email? email,
      Password? password,
      bool? isInfoValid,
      String? errorMessage}) {
    return RegisterEmailState(
        status: status ?? this.status,
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
        isInfoValid: isInfoValid ?? this.isInfoValid,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  bool get isInitialRegisterByEmail => status.isInitialRegisterByEmail;
  bool get isRegisterProcess => status.isRegisterProcess;
  bool get isRegisterSuccess => status.isRegisterSuccess;
  bool get isRegisterFail => status.isRegisterFail;

  @override
  List<Object> get props => [
        status,
        username,
        email,
        password,
        isInfoValid
      ];
}
