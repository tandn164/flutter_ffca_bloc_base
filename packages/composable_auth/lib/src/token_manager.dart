import 'dart:async';
import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  TokenManager({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;
  final Logger _logger = Logger('TokenManager');

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  /// Get stored access token
  String? get accessToken => _sharedPreferences.getString(_accessTokenKey);
  
  /// Get stored refresh token
  String? get refreshToken => _sharedPreferences.getString(_refreshTokenKey);
  
  /// Get stored user data
  Map<String, dynamic>? get userData {
    final userDataString = _sharedPreferences.getString(_userDataKey);
    if (userDataString != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(userDataString));
      } catch (e) {
        _logger.warning('Failed to decode user data: $e');
        return null;
      }
    }
    return null;
  }

  /// Save tokens and user data
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? userData,
  }) async {
    try {
      await _sharedPreferences.setString(_accessTokenKey, accessToken);
      
      if (refreshToken != null) {
        await _sharedPreferences.setString(_refreshTokenKey, refreshToken);
      }
      
      if (userData != null) {
        await _sharedPreferences.setString(_userDataKey, jsonEncode(userData));
      }
      
      _logger.info('Tokens saved successfully');
    } catch (e) {
      _logger.severe('Failed to save tokens: $e');
      rethrow;
    }
  }

  /// Clear all stored tokens and user data
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _sharedPreferences.remove(_accessTokenKey),
        _sharedPreferences.remove(_refreshTokenKey),
        _sharedPreferences.remove(_userDataKey),
      ]);
      
      _logger.info('Tokens cleared successfully');
    } catch (e) {
      _logger.severe('Failed to clear tokens: $e');
      rethrow;
    }
  }

  /// Check if access token exists
  bool get hasAccessToken => accessToken != null;
  
  /// Check if refresh token exists
  bool get hasRefreshToken => refreshToken != null;

  /// Check if access token is expired
  bool get isAccessTokenExpired {
    final token = accessToken;
    if (token == null) return true;
    
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      _logger.warning('Failed to decode JWT token: $e');
      return true;
    }
  }

  /// Get token expiry time
  DateTime? get accessTokenExpiryTime {
    final token = accessToken;
    if (token == null) return null;
    
    try {
      final expiryTime = JwtDecoder.getExpirationDate(token);
      return expiryTime;
    } catch (e) {
      _logger.warning('Failed to get token expiry time: $e');
      return null;
    }
  }

  /// Check if token should be refreshed (before expiry)
  bool shouldRefreshToken(Duration beforeExpiry) {
    final expiryTime = accessTokenExpiryTime;
    if (expiryTime == null) return true;
    
    final now = DateTime.now();
    final refreshTime = expiryTime.subtract(beforeExpiry);
    
    return now.isAfter(refreshTime);
  }

  /// Get token payload
  Map<String, dynamic>? get tokenPayload {
    final token = accessToken;
    if (token == null) return null;
    
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      _logger.warning('Failed to decode token payload: $e');
      return null;
    }
  }

  /// Get user ID from token
  String? get userIdFromToken {
    final payload = tokenPayload;
    if (payload == null) return null;
    
    // Try common JWT fields for user ID
    return payload['sub'] ?? 
           payload['user_id'] ?? 
           payload['id'] ?? 
           payload['userId'];
  }
}