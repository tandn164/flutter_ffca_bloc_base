enum LoginEmailStatus {
  initial,
  emailEditing,
  passwordEditing,
  loginProcess,
  loginSuccess,
  loginFail,
}

extension LoginEmailStatusX on LoginEmailStatus {
  bool get isInitial =>
      this == LoginEmailStatus.initial;
  bool get isEditing => this == LoginEmailStatus.emailEditing || this == LoginEmailStatus.passwordEditing;
  bool get isLoginProcess => this == LoginEmailStatus.loginProcess;
  bool get isLoginFail => this == LoginEmailStatus.loginFail;
  bool get isLoginSuccess =>
      this == LoginEmailStatus.loginSuccess;
}