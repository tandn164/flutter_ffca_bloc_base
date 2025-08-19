import 'dart:convert';
import 'package:flutter_bloc_base/screens/authentication/domain/entities/login_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/rest_client_service.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/authentication_dtos.dart';

abstract class AuthenticationDataSource {
  Future<LoginSession> getLastLoginSession();
  Future<void> cacheSession(LoginSession login);
  Future<BaseResponse<LoginSession>> login(String email, String password);
  Future<BaseResponse<LoginSession>> register(
      String username, String email, String password);
  Future<void> logout();
}

class AuthenticationDataSourceImpl extends AuthenticationDataSource {
  final RestClientService restClientService;
  final SharedPreferences sharedPreferences;

  AuthenticationDataSourceImpl(
      {required this.restClientService, required this.sharedPreferences});

  @override
  Future<void> cacheSession(LoginSession login) {
    return sharedPreferences.setString(LOGIN_SESSION, jsonEncode(login));
  }

  @override
  Future<LoginSession> getLastLoginSession() {
    String? login = sharedPreferences.getString(LOGIN_SESSION);
    if (login == null) {
      throw CacheException();
    }
    return Future.value(LoginSessionDTO.fromJson(jsonDecode(login)));
  }

  @override
  Future<BaseResponse<LoginSession>> login(
      String email, String password) async {
    final response = await restClientService.apiAuthLoginPost(jsonEncode({
      email: email,
      password: password,
    }));

    if (response.statusCode != 200) {
      throw ServerException.fromObject(response.error);
    }

    return BaseResponse<LoginSession>.fromJson(
        response.body, (data) => LoginSessionDTO.fromJson(data));
  }

  @override
  Future<BaseResponse<LoginSession>> register(
      String username, String email, String password) async {
    final body = jsonEncode({
      email: email, password: password, username: username
    });

    final response = await restClientService.apiAuthRegisterPost(body);

    if (response.statusCode != 200) {
      throw ServerException.fromObject(response.error);
    }

    return BaseResponse<LoginSession>.fromJson(
        response.body, (data) => LoginSessionDTO.fromJson(data));
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(LOGIN_SESSION);
  }
}