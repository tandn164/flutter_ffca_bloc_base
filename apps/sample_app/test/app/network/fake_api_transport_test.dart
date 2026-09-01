import 'dart:convert';

import 'package:auth_data/auth_data.dart';
import 'package:feed_data/feed_data.dart';
import 'package:sample_app/app/features/sample_features.dart';
import 'package:sample_app/app/network/fake/fake_api_transport.dart';
import 'package:sample_app/app/network/fake/fake_auth_handler.dart';
import 'package:sample_app/app/network/fake/fake_demo_store.dart';
import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_data/profile_data.dart';

void main() {
  late FakeConnectivity net;
  late FakeApiTransport api;

  setUp(() {
    net = FakeConnectivity();
    api = FakeApiTransport(
      connectivity: net,
      handlers: createDemoFakeHandlers(),
    );
  });

  test('login demo account returns tokens', () async {
    final res = await api.send(
      const ApiRequest(
        method: 'POST',
        path: AuthApi.loginPath,
        body: {'email': DemoApi.email, 'password': DemoApi.password},
      ),
    );
    expect(res.statusCode, 200);
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    expect(json['accessToken'], DemoApi.accessToken);
    expect(json['refreshToken'], DemoApi.refreshToken);
  });

  test('login rejects wrong password', () async {
    final res = await api.send(
      const ApiRequest(
        method: 'POST',
        path: AuthApi.loginPath,
        body: {'email': DemoApi.email, 'password': 'nope'},
      ),
    );
    expect(res.statusCode, 401);
  });

  test('me requires a demo access token', () async {
    final denied = await api
        .send(const ApiRequest(method: 'GET', path: ProfileApi.mePath));
    expect(denied.statusCode, 401);
    final ok = await api.send(
      const ApiRequest(
        method: 'GET',
        path: ProfileApi.mePath,
        headers: {'Authorization': 'Bearer ${DemoApi.accessToken}'},
      ),
    );
    expect(ok.statusCode, 200);
    expect(jsonDecode(ok.body)['email'], DemoApi.email);
  });

  test('refresh accepts the demo refresh token', () async {
    final res = await api.send(
      const ApiRequest(
        method: 'POST',
        path: AuthApi.refreshPath,
        body: {'refreshToken': DemoApi.refreshToken},
      ),
    );
    expect(res.statusCode, 200);
    expect(jsonDecode(res.body)['accessToken'], DemoApi.accessRefreshed);
  });

  test('feed pages 10 items and sets hasMore', () async {
    final page1 =
        await api.send(const ApiRequest(method: 'GET', path: FeedApi.feedPath));
    final json1 = jsonDecode(page1.body) as Map<String, dynamic>;
    expect((json1['items'] as List).length, 10);
    expect(json1['hasMore'], isTrue);
  });

  test('signup then login and update profile', () async {
    final created = await api.send(
      const ApiRequest(
        method: 'POST',
        path: AuthApi.signupPath,
        body: {
          'email': 'new@example.com',
          'password': 'secret1',
          'name': 'New'
        },
      ),
    );
    expect(created.statusCode, 200);
    final tokens = jsonDecode(created.body) as Map<String, dynamic>;
    final headers = {'Authorization': 'Bearer ${tokens['accessToken']}'};

    final me = await api.send(
      ApiRequest(method: 'GET', path: ProfileApi.mePath, headers: headers),
    );
    expect(jsonDecode(me.body)['name'], 'New');

    final patched = await api.send(
      ApiRequest(
        method: 'PATCH',
        path: ProfileApi.mePath,
        headers: headers,
        body: {'name': 'Updated'},
      ),
    );
    expect(jsonDecode(patched.body)['name'], 'Updated');
  });

  test('withHandlers composes only selected fake capabilities', () async {
    final authOnly = FakeApiTransport(
      connectivity: net,
      handlers: [FakeAuthHandler(FakeDemoStore())],
    );

    final login = await authOnly.send(
      const ApiRequest(
        method: 'POST',
        path: AuthApi.loginPath,
        body: {'email': DemoApi.email, 'password': DemoApi.password},
      ),
    );
    final feed = await authOnly.send(
      const ApiRequest(method: 'GET', path: FeedApi.feedPath),
    );

    expect(login.statusCode, 200);
    expect(feed.statusCode, 404);
  });
}
