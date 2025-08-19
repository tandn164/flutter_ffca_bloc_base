import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_base/screens/authentication/data/models/authentication_dtos.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/entities/login_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/base/base_response.dart';
import '../core/config/environment.dart';
import '../core/network/rest_client_service.dart';
import '../core/utils/constants.dart';

class AppAuthenticator implements Authenticator {
  AppAuthenticator({required this.sharedPreferences, this.onTokenExpired});

  final SharedPreferences sharedPreferences;
  final VoidCallback? onTokenExpired;

  @override
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) async {
    if (response.statusCode == HttpStatus.unauthorized) {
      final retryCount = int.parse(request.headers['Retry-Count'] ?? '0');
      if (retryCount >= 3) {
        onTokenExpired?.call();
        return null;
      }

      try {
        final newToken = await _refreshToken();

        return applyHeaders(
          request,
          {
            HttpHeaders.authorizationHeader: 'Bearer $newToken',
            'Retry-Count': (retryCount + 1).toString(),
          },
        );
      } catch (e) {
        onTokenExpired?.call();
        return null;
      }
    }

    return null;
  }

  Completer<String>? _completer;

  Future<String> _refreshToken() {
    var completer = _completer;
    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }

    final chopper = ChopperClient(
      interceptors: [
        CurlInterceptor(),
        HttpLoggingInterceptor(),
        RefreshTokenInterceptor(sharedPreferences: sharedPreferences)
      ],
      converter: const JsonConverter(),
      baseUrl: Uri.https(Environment.apiBaseUrl),
    );
    final client = RestClientService.create(chopper);

    completer = Completer<String>();
    _completer = completer;

    client.refreshToken().then((response) {
      final session = BaseResponse<LoginSession>.fromJson(
          response.body, (data) => LoginSessionDTO.fromJson(data));
      sharedPreferences.setString(LOGIN_SESSION, jsonEncode(session.data));
      completer?.complete(session.data?.accessToken);
    }).onError((error, stackTrace) {
      completer?.completeError(error ?? 'Refresh token error', stackTrace);
    });

    return completer.future;
  }

  @override
  AuthenticationCallback? get onAuthenticationFailed => null;

  @override
  AuthenticationCallback? get onAuthenticationSuccessful => null;
}


class RefreshTokenInterceptor implements Interceptor {
  const RefreshTokenInterceptor({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    String? session = sharedPreferences.getString(LOGIN_SESSION);
    LoginSession? response;
    String accessToken = "";

    if (session != null) {
      response = LoginSessionDTO.fromJson(jsonDecode(session));
    }

    if (session != null && response?.refreshToken != null) {
      accessToken = 'Bearer ${response!.refreshToken!}';
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
