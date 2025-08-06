class LoginSession {
  String? accessToken;
  String? refreshToken;
  bool? isVerified;

  LoginSession({this.accessToken, this.refreshToken, this.isVerified});
}
