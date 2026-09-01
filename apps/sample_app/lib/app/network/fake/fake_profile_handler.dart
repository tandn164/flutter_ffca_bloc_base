import 'package:api_client/api_client.dart';
import 'package:profile_data/profile_data.dart';

import 'fake_api_handler.dart';
import 'fake_api_helpers.dart';
import 'fake_demo_store.dart';

class FakeProfileHandler implements FakeApiHandler {
  FakeProfileHandler(this.store);

  final FakeDemoStore store;

  @override
  ApiResponse? handle(ApiRequest request) {
    if (request.path != ProfileApi.mePath) return null;
    final method = request.method.toUpperCase();
    if (method == 'GET') return _me(request);
    if (method == 'PATCH') return _updateMe(request);
    return null;
  }

  ApiResponse _me(ApiRequest request) {
    final account = store.accountFor(request);
    if (account == null) {
      return const ApiResponse(
        statusCode: 401,
        body: '{"error":"unauthorized"}',
      );
    }
    return _profile(account);
  }

  ApiResponse _updateMe(ApiRequest request) {
    final account = store.accountFor(request);
    if (account == null) {
      return const ApiResponse(
        statusCode: 401,
        body: '{"error":"unauthorized"}',
      );
    }
    final name = '${requestBody(request.body)['name'] ?? ''}'.trim();
    if (name.isEmpty) {
      return const ApiResponse(
        statusCode: 400,
        body: '{"error":"name required"}',
      );
    }
    account.name = name;
    return _profile(account);
  }

  ApiResponse _profile(DemoAccount account) {
    return jsonResponse(200, {
      'id': account.id,
      'name': account.name,
      'email': account.email,
    });
  }
}
