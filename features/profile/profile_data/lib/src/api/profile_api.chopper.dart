// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'profile_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ProfileApi extends ProfileApi {
  _$ProfileApi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ProfileApi;

  @override
  Future<Response<dynamic>> me() {
    final Uri $url = Uri.parse('/demo/me');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateMe(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/demo/me');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
