import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chopper/chopper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/constants.dart';
import '../screens/authentication/data/models/login_response.dart';

class AuthInterceptor implements Interceptor {
  const AuthInterceptor({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    String? session = sharedPreferences.getString(LOGIN_SESSION);
    LoginResponse? response;
    String accessToken = "";

    if (session != null) {
      response = LoginResponse.fromJson(jsonDecode(session));
    }

    if (session != null && response?.accessToken != null) {
      accessToken = 'Bearer ${response!.accessToken!}';
    }

    final updatedRequest = applyHeader(
      chain.request,
      HttpHeaders.authorizationHeader,
      accessToken,
      override: false,
    );

    print(
      '[AuthInterceptor] accessToken: ${updatedRequest.headers[HttpHeaders.authorizationHeader]}',
    );

    return chain.proceed(updatedRequest);
  }
}
