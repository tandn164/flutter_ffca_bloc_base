import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chopper/chopper.dart';
import 'package:flutter_bloc_base/screens/authentication/data/models/authentication_dtos.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/entities/login_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/constants.dart';

class AuthInterceptor implements Interceptor {
  const AuthInterceptor({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    String? session = sharedPreferences.getString(LOGIN_SESSION);
    LoginSession? response;
    String accessToken = "";

    if (session != null) {
      response = LoginSessionDTO.fromJson(jsonDecode(session));
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

    return chain.proceed(updatedRequest);
  }
}
