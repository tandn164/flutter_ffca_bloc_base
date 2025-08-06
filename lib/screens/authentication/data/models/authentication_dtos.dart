class LoginEmailDto {
  final String email;
  final String password;

  const LoginEmailDto({
    required this.email,
    required this.password
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory LoginEmailDto.fromJson(Map<String, dynamic> json) {
    return LoginEmailDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}

class RegisterEmailDto {
  final String email;
  final String password;
  final String username;

  const RegisterEmailDto({
    required this.email,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
    };
  }

  factory RegisterEmailDto.fromJson(Map<String, dynamic> json) {
    return RegisterEmailDto(
      email: json['email'] as String,
      password: json['password'] as String,
      username: json['username'] as String,
    );
  }
}
