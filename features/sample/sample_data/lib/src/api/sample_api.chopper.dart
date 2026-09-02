// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$SampleApi extends SampleApi {
  _$SampleApi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = SampleApi;

  @override
  Future<Response<dynamic>> getSample() {
    final Uri $url = Uri.parse('/sample/items');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createSample(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/sample/items');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateSample(
    String id,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/sample/items/${id}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteSample(String id) {
    final Uri $url = Uri.parse('/sample/items/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
