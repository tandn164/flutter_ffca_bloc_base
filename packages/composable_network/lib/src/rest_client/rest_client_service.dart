import "dart:async";

import 'package:chopper/chopper.dart';
// Constants moved inline - remove dependency on main app constants

part "rest_client_service.chopper.dart";

// API endpoint constants  
const String _LOGIN_USER = 'tokens';
const String _CREATE_USER = 'create';
const String _REFRESH_TOKEN = 'refresh-token';

@ChopperApi()
abstract class RestClientService extends ChopperService {
  static RestClientService create([ChopperClient? client]) =>
      _$RestClientService(client);

  @DELETE(path: _LOGIN_USER, headers: {'Content-type': 'application/json'})
  Future<Response> logoutUser(
      @Body() String jsonBody, @Header("Authorization") String token);

  @POST(path: _REFRESH_TOKEN, headers: {'Content-type': 'application/json'})
  Future<Response> refreshToken();

  // Authentication endpoints
  @POST(path: '/auth/login', headers: {'Content-type': 'application/json'})
  Future<Response> apiAuthLoginPost(@Body() dynamic body);

  @POST(path: '/auth/register', headers: {'Content-type': 'application/json'})
  Future<Response> apiAuthRegisterPost(@Body() dynamic body);

  // Note: Notification endpoints moved to composable_push package (Phase 3)

  // Alternative: Comment out above methods if APIs are not ready yet
  // and uncomment the mock versions below:
  
  /*
  // Mock implementation until backend APIs are ready
  Future<Response> registerDeviceToken(dynamic body) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Response(MockRequest(), 200, 'OK');
  }

  Future<Response> attachDeviceToken(dynamic body) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Response(MockRequest(), 200, 'OK');
  }

  Future<Response> detachDeviceToken(dynamic body) async {
    await Future.delayed(Duration(milliseconds: 500));
    return Response(MockRequest(), 200, 'OK');
  }
  */
}
