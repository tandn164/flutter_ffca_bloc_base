import 'package:chopper/chopper.dart';

part 'auth_api.chopper.dart';

/// Credential endpoints only. Profile `/me` lives with the profile feature.
@ChopperApi()
abstract class AuthApi extends ChopperService {
  static const loginPath = '/demo/login';
  static const signupPath = '/demo/signup';
  static const refreshPath = '/demo/refresh';

  static AuthApi create([ChopperClient? client]) => _$AuthApi(client);

  @POST(path: loginPath)
  Future<Response<dynamic>> login(@Body() Map<String, dynamic> body);

  @POST(path: signupPath)
  Future<Response<dynamic>> signup(@Body() Map<String, dynamic> body);

  @POST(path: refreshPath)
  Future<Response<dynamic>> refresh(@Body() Map<String, dynamic> body);
}
