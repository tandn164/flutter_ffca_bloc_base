// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'feed_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$FeedApi extends FeedApi {
  _$FeedApi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = FeedApi;

  @override
  Future<Response<dynamic>> getFeed() {
    final Uri $url = Uri.parse('/demo/feed');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createFeed(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/demo/feed');
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
  Future<Response<dynamic>> updateFeed(
    String id,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/demo/feed/${id}');
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
  Future<Response<dynamic>> deleteFeed(String id) {
    final Uri $url = Uri.parse('/demo/feed/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
