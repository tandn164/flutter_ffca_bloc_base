import 'package:equatable/equatable.dart';

class RegisterEmailParams extends Equatable {
  final String username;
  final String email;
  final String password;

  const RegisterEmailParams(
      {required this.username, required this.email, required this.password})
      : super();

  @override
  List<Object?> get props => [username, email, password];
}
