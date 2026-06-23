import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:composable_auth/composable_auth.dart';

void main() {
  group('TokenManager', () {
    late TokenManager tokenManager;
    late SharedPreferences mockPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      tokenManager = TokenManager(sharedPreferences: mockPrefs);
    });

    test('should save and retrieve access token', () async {
      const testToken = 'test_access_token';
      
      await tokenManager.saveTokens(accessToken: testToken);
      
      expect(tokenManager.accessToken, equals(testToken));
      expect(tokenManager.hasAccessToken, isTrue);
    });

    test('should save and retrieve refresh token', () async {
      const testToken = 'test_refresh_token';
      
      await tokenManager.saveTokens(
        accessToken: 'access',
        refreshToken: testToken,
      );
      
      expect(tokenManager.refreshToken, equals(testToken));
      expect(tokenManager.hasRefreshToken, isTrue);
    });

    test('should save and retrieve user data', () async {
      const userData = {'id': '123', 'email': 'test@example.com'};
      
      await tokenManager.saveTokens(
        accessToken: 'access',
        userData: userData,
      );
      
      expect(tokenManager.userData, equals(userData));
    });

    test('should clear all tokens', () async {
      await tokenManager.saveTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        userData: {'id': '123'},
      );
      
      await tokenManager.clearTokens();
      
      expect(tokenManager.accessToken, isNull);
      expect(tokenManager.refreshToken, isNull);
      expect(tokenManager.userData, isNull);
      expect(tokenManager.hasAccessToken, isFalse);
      expect(tokenManager.hasRefreshToken, isFalse);
    });

    test('should handle invalid user data gracefully', () async {
      await mockPrefs.setString('user_data', 'invalid_json');
      
      expect(tokenManager.userData, isNull);
    });

    group('JWT token validation', () {
      test('should return true for expired token check when token is null', () {
        expect(tokenManager.isAccessTokenExpired, isTrue);
      });

      test('should return true for expired token check when token is invalid', () async {
        await tokenManager.saveTokens(accessToken: 'invalid_jwt_token');
        
        expect(tokenManager.isAccessTokenExpired, isTrue);
      });

      test('should return null for expiry time when token is null', () {
        expect(tokenManager.accessTokenExpiryTime, isNull);
      });

      test('should return null for expiry time when token is invalid', () async {
        await tokenManager.saveTokens(accessToken: 'invalid_jwt_token');
        
        expect(tokenManager.accessTokenExpiryTime, isNull);
      });

      test('should return null for token payload when token is null', () {
        expect(tokenManager.tokenPayload, isNull);
      });

      test('should return null for token payload when token is invalid', () async {
        await tokenManager.saveTokens(accessToken: 'invalid_jwt_token');
        
        expect(tokenManager.tokenPayload, isNull);
      });

      test('should return null for user ID when token is null', () {
        expect(tokenManager.userIdFromToken, isNull);
      });
    });

    group('shouldRefreshToken', () {
      test('should return true when token is null', () {
        expect(
          tokenManager.shouldRefreshToken(const Duration(minutes: 5)), 
          isTrue,
        );
      });

      test('should return true when token is invalid', () async {
        await tokenManager.saveTokens(accessToken: 'invalid_jwt_token');
        
        expect(
          tokenManager.shouldRefreshToken(const Duration(minutes: 5)), 
          isTrue,
        );
      });
    });
  });
}