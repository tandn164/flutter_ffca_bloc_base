import '../../../../core/utils/serializable.dart';
import '../../domain/entities/login_session.dart';

class LoginResponse extends LoginSession implements Serializable {
  LoginResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    isVerified = json['isVerified'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['isVerified'] = isVerified;
    return data;
  }
}