import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_base/interceptor/auth_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/base/base_response.dart';
import '../core/config/environment.dart';
import '../core/network/rest_client_service.dart';
import '../core/utils/constants.dart';
import '../screens/authentication/data/models/login_response.dart';

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
    print('[AppAuthenticator] response.statusCode: ${response.statusCode}');
    print(
      '[AppAuthenticator] request Retry-Count: ${request.headers['Retry-Count'] ?? 0}',
    );

    // 401
    if (response.statusCode == HttpStatus.unauthorized) {
      // Trying to update token only 1 time
      if (request.headers['Retry-Count'] != null) {
        print(
          '[AppAuthenticator] Unable to refresh token, retry count exceeded',
        );
        // Notify that token has expired and refresh failed
        onTokenExpired?.call();
        return null;
      }

      try {
        final newToken = await _refreshToken();

        return applyHeaders(
          request,
          {
            HttpHeaders.authorizationHeader: 'Bearer $newToken',
            'Retry-Count': '1',
          },
        );
      } catch (e) {
        print('[AppAuthenticator] Unable to refresh token: $e');
        // Notify that token has expired and refresh failed
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
      print('Token refresh is already in progress');
      return completer.future;
    }

    String? session = sharedPreferences.getString(LOGIN_SESSION);
    LoginResponse? response;
    String accessToken = "";

    if (session != null) {
      response = LoginResponse.fromJson(jsonDecode(session));
    }

    if (session != null && response?.refreshToken != null) {
      accessToken = 'Bearer ${response!.refreshToken!}';
    }

    final chopper = ChopperClient(
      interceptors: [
        CurlInterceptor(),
        HttpLoggingInterceptor(),
        AuthInterceptor(sharedPreferences: sharedPreferences),
      ],
      converter: const JsonConverter(),
      baseUrl: Uri.https(Environment.apiBaseUrl),
    );
    final client = RestClientService.create(chopper);

    completer = Completer<String>();
    _completer = completer;

    client.refreshToken(jsonEncode({"refresh_token": response?.refreshToken ?? ""})).then((response) {
      final session = BaseResponse<LoginResponse>.fromJson(
          response.body, (data) => LoginResponse.fromJson(data));
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

