class LoginSession {
  String? accessToken;
  String? refreshToken;
  bool? isVerified;

  LoginSession({this.accessToken, this.refreshToken, this.isVerified});

  /// Convert to JSON - needed for caching
  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'isVerified': isVerified,
  };

  /// Create from JSON - for cache deserialization  
  factory LoginSession.fromJson(Map<String, dynamic> json) => LoginSession(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    isVerified: json['isVerified'],
  );
}
