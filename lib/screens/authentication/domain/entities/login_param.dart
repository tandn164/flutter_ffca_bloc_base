import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password}) : super();

  @override
  List<Object?> get props => [email, password];
}