import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/rest_client_service.dart';
import '../models/login_response.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/authentication_dtos.dart';

abstract class AuthenticationDataSource {
  Future<LoginResponse> getLastLoginSession();
  Future<void> cacheSession(LoginResponse login);
  Future<BaseResponse<LoginResponse>> login(String email, String password);
  Future<BaseResponse<LoginResponse>> register(
      String username, String email, String password);
  Future<void> logout();
}

class AuthenticationDataSourceImpl extends AuthenticationDataSource {
  final RestClientService restClientService;
  final SharedPreferences sharedPreferences;

  AuthenticationDataSourceImpl(
      {required this.restClientService, required this.sharedPreferences});

  @override
  Future<void> cacheSession(LoginResponse login) {
    return sharedPreferences.setString(LOGIN_SESSION, jsonEncode(login));
  }

  @override
  Future<LoginResponse> getLastLoginSession() {
    String? login = sharedPreferences.getString(LOGIN_SESSION);
    if (login == null) {
      throw CacheException();
    }
    return Future.value(LoginResponse.fromJson(jsonDecode(login)));
  }

  @override
  Future<BaseResponse<LoginResponse>> login(
      String email, String password) async {
    final body =
        LoginEmailDto(email: email, password: password);

    // final response = await restClientService.apiAuthLoginPost(body.toJson());
    //
    // if (response.statusCode != 200) {
    //   throw ServerException.fromObject(response.error);
    // }

    Future.delayed(Duration(seconds: 1));
    final response = getMockLoginResponse();
    
    return BaseResponse<LoginResponse>.fromJson(
        response, (data) => LoginResponse.fromJson(data));
  }

  @override
  Future<BaseResponse<LoginResponse>> register(
      String username, String email, String password) async {
    final body = RegisterEmailDto(
        email: email, password: password, username: username);

    // final response = await restClientService.apiAuthRegisterPost(body.toJson());
    //
    // if (response.statusCode != 200) {
    //   throw ServerException.fromObject(response.error);
    // }

    Future.delayed(Duration(seconds: 1));
    final response = getMockLoginResponse();

    return BaseResponse<LoginResponse>.fromJson(
        response, (data) => LoginResponse.fromJson(data));
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(LOGIN_SESSION);
  }

  Map<String, dynamic> getMockLoginResponse() {
    return {
      "data": {
        "accessToken": "mock_access_token",
        "refreshToken": "mock_refresh_token",
        "isVerified": true
      },
      "meta": {
        "code": 200,
        "msg": "",
        "message": "",
        "errorCode": "",
      }
    };
  }
}