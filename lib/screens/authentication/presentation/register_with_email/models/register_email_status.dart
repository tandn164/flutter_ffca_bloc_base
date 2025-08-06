enum RegisterEmailStatus {
  initialRegisterEmail,
  registerProcess,
  registerSuccess,
  registerFail,
}

extension RegisterEmailStatusX on RegisterEmailStatus {
  bool get isInitialRegisterByEmail =>
      this == RegisterEmailStatus.initialRegisterEmail;
  bool get isRegisterProcess =>
      this == RegisterEmailStatus.registerProcess;
  bool get isRegisterSuccess =>
      this == RegisterEmailStatus.registerSuccess;
  bool get isRegisterFail =>
      this == RegisterEmailStatus.registerFail;
}