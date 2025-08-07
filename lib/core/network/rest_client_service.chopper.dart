// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_client_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$RestClientService extends RestClientService {
  _$RestClientService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = RestClientService;

  @override
  Future<Response<dynamic>> logoutUser(
    String jsonBody,
    String token,
  ) {
    final Uri $url = Uri.parse('tokens');
    final Map<String, String> $headers = {
      'Authorization': token,
      'Content-type': 'application/json',
    };
    final $body = jsonBody;
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> refreshToken(String jsonBody) {
    final Uri $url = Uri.parse('refresh-token');
    final Map<String, String> $headers = {
      'Content-type': 'application/json',
    };
    final $body = jsonBody;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> apiAuthLoginPost(dynamic body) {
    final Uri $url = Uri.parse('/auth/login');
    final Map<String, String> $headers = {
      'Content-type': 'application/json',
    };
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> apiAuthRegisterPost(dynamic body) {
    final Uri $url = Uri.parse('/auth/register');
    final Map<String, String> $headers = {
      'Content-type': 'application/json',
    };
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
