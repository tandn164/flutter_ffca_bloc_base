import 'package:api_client/api_client.dart';
import 'package:auth_data/auth_data.dart';

import 'demo_api.dart';
import 'fake_api_handler.dart';
import 'fake_api_helpers.dart';
import 'fake_demo_store.dart';

class FakeAuthHandler implements FakeApiHandler {
  FakeAuthHandler(this.store);

  final FakeDemoStore store;

  @override
  ApiResponse? handle(ApiRequest request) {
    final method = request.method.toUpperCase();
    if (method == 'POST' && request.path == AuthApi.loginPath) {
      return _login(request);
    }
    if (method == 'POST' && request.path == AuthApi.signupPath) {
      return _signup(request);
    }
    if (method == 'POST' && request.path == AuthApi.refreshPath) {
      return _refresh(request);
    }
    return null;
  }

  ApiResponse _login(ApiRequest request) {
    final body = requestBody(request.body);
    final email = '${body['email'] ?? ''}'.trim().toLowerCase();
    final password = '${body['password'] ?? ''}';
    final account = store.accounts.values.cast<DemoAccount?>().firstWhere(
          (candidate) => candidate!.email == email,
          orElse: () => null,
        );
    if (account == null || account.password != password) {
      return const ApiResponse(
        statusCode: 401,
        body: '{"error":"invalid credentials"}',
      );
    }
    return _tokensFor(account);
  }

  ApiResponse _signup(ApiRequest request) {
    final body = requestBody(request.body);
    final email = '${body['email'] ?? ''}'.trim().toLowerCase();
    final password = '${body['password'] ?? ''}';
    final name = '${body['name'] ?? ''}'.trim();
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return const ApiResponse(
        statusCode: 400,
        body: '{"error":"missing fields"}',
      );
    }
    if (store.accounts.values.any((account) => account.email == email)) {
      return const ApiResponse(
        statusCode: 409,
        body: '{"error":"email taken"}',
      );
    }
    final id = 'u-${++store.userSequence}';
    final account = DemoAccount(
      id: id,
      email: email,
      password: password,
      name: name,
    );
    store.accounts[id] = account;
    store.accessToUser['access-$id'] = id;
    store.refreshToUser['refresh-$id'] = id;
    return _tokensFor(account);
  }

  ApiResponse _tokensFor(DemoAccount account) {
    final isDemo = account.id == DemoApi.userId;
    return jsonResponse(200, {
      'accessToken': isDemo ? DemoApi.accessToken : 'access-${account.id}',
      'refreshToken': isDemo ? DemoApi.refreshToken : 'refresh-${account.id}',
    });
  }

  ApiResponse _refresh(ApiRequest request) {
    final token = '${requestBody(request.body)['refreshToken'] ?? ''}';
    final userId = store.refreshToUser[token];
    if (userId == null) {
      return const ApiResponse(
        statusCode: 401,
        body: '{"error":"invalid refresh"}',
      );
    }
    if (userId == DemoApi.userId) {
      return jsonResponse(200, {
        'accessToken': DemoApi.accessRefreshed,
        'refreshToken': DemoApi.refreshToken,
      });
    }
    return jsonResponse(200, {
      'accessToken': 'access-$userId',
      'refreshToken': 'refresh-$userId',
    });
  }
}
