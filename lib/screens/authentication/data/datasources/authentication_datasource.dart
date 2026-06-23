import 'dart:async';
import 'dart:convert';

import 'package:composable_network/composable_network.dart';
import 'package:composable_cache/composable_cache.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/entities/login_session.dart';

import '../../../../core/base/base_response.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/authentication_dtos.dart';

abstract class AuthenticationDataSource {
  /// Get cached session (cache-first strategy)
  Future<LoginSession?> getLastLoginSession();
  
  /// Cache session with TTL
  Future<void> cacheSession(LoginSession login, {Duration? ttl});
  
  /// Watch session changes reactively  
  Stream<LoginSession?> watchSession();
  
  /// Login with network + cache update
  Future<BaseResponse<LoginSession>> login(String email, String password);
  
  /// Register with network + cache update
  Future<BaseResponse<LoginSession>> register(String username, String email, String password);
  
  /// Logout and clear cache
  Future<void> logout();
}

class AuthenticationDataSourceImpl extends AuthenticationDataSource {
  AuthenticationDataSourceImpl({
    required this.restClientService,
    required this.cacheManager,
    SafeResponseParser? responseParser,
  }) : _responseParser = responseParser ?? const SafeResponseParser();

  final RestClientService restClientService;
  final CacheManager cacheManager;
  final SafeResponseParser _responseParser;
  
  static const String _sessionCacheKey = 'login_session';

  @override
  Future<void> cacheSession(LoginSession login, {Duration? ttl}) async {
    await cacheManager.put(
      _sessionCacheKey, 
      jsonEncode(login.toJson()),
      ttl: ttl ?? const Duration(days: 30), // Long-lived auth session
    );
  }

  @override
  Future<LoginSession?> getLastLoginSession() async {
    try {
      final sessionJson = await cacheManager.get<String>(_sessionCacheKey);
      if (sessionJson == null) return null;
      
      return LoginSessionDTO.fromJson(jsonDecode(sessionJson));
    } catch (e) {
      // Cache miss or parsing error - return null instead of throwing
      return null;
    }
  }

  @override
  Stream<LoginSession?> watchSession() {
    return cacheManager.watch<String>(_sessionCacheKey).asyncMap((sessionJson) async {
      if (sessionJson == null) return null;
      
      try {
        return LoginSessionDTO.fromJson(jsonDecode(sessionJson));
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<BaseResponse<LoginSession>> login(String email, String password) async {
    final response = await restClientService.apiAuthLoginPost(jsonEncode({
      'email': email,
      'password': password,
    }));

    if (response.statusCode != 200) {
      throw ServerException.fromObject(response.error);
    }

    final sessionResponse = _parseSessionResponse(response.body);
    
    // Cache successful login session
    if (sessionResponse.data != null) {
      await cacheSession(sessionResponse.data!);
    }

    return sessionResponse;
  }

  @override
  Future<BaseResponse<LoginSession>> register(String username, String email, String password) async {
    final body = jsonEncode({
      'email': email,
      'password': password,
      'username': username,
    });

    final response = await restClientService.apiAuthRegisterPost(body);

    if (response.statusCode != 200) {
      throw ServerException.fromObject(response.error);
    }

    final sessionResponse = _parseSessionResponse(response.body);
    
    // Cache successful registration session
    if (sessionResponse.data != null) {
      await cacheSession(sessionResponse.data!);
    }

    return sessionResponse;
  }

  BaseResponse<LoginSession> _parseSessionResponse(Object? body) {
    final result = _responseParser.parseObject<BaseResponse<LoginSession>>(
      body,
      decode: (json) => BaseResponse<LoginSession>.fromJson(
        json,
        (data) => LoginSessionDTO.fromJson(data),
      ),
    );

    return switch (result) {
      ApiSuccess(:final value) => value,
      ApiError(:final failure) => throw ServerException.fromObject(
          failure.message ?? failure.toString(),
        ),
    };
  }

  @override
  Future<void> logout() async {
    // Clear cached session
    await cacheManager.invalidate(_sessionCacheKey);
    
    // TODO: Call logout API if needed
    // await restClientService.logoutUser(...);
  }
}
