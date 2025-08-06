import "dart:async";

import 'package:chopper/chopper.dart';
import 'package:flutter_bloc_base/core/utils/constants.dart';

part "rest_client_service.chopper.dart";

@ChopperApi(baseUrl: API_BASE_URL)
abstract class RestClientService extends ChopperService {
  static RestClientService create([ChopperClient? client]) =>
      _$RestClientService(client);

  @DELETE(path: LOGIN_USER, headers: {'Content-type': 'application/json'})
  Future<Response> logoutUser(
      @Body() String jsonBody, @Header("Authorization") String token);

  @POST(path: REFRESH_TOKEN, headers: {'Content-type': 'application/json'})
  Future<Response> refreshToken(@Body() String jsonBody);

  // Authentication endpoints
  @POST(path: '/auth/login', headers: {'Content-type': 'application/json'})
  Future<Response> apiAuthLoginPost(@Body() dynamic body);

  @POST(path: '/auth/register', headers: {'Content-type': 'application/json'})
  Future<Response> apiAuthRegisterPost(@Body() dynamic body);
}
