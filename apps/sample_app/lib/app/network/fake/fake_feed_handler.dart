import 'package:api_client/api_client.dart';
import 'package:feed_data/feed_data.dart';

import 'demo_api.dart';
import 'fake_api_handler.dart';
import 'fake_api_helpers.dart';
import 'fake_demo_store.dart';

class FakeFeedHandler implements FakeApiHandler {
  FakeFeedHandler(this.store);

  final FakeDemoStore store;

  @override
  ApiResponse? handle(ApiRequest request) {
    final method = request.method.toUpperCase();
    if (request.path == FeedApi.feedPath) {
      if (method == 'GET') return _feed(request);
      if (method == 'POST') return _createTodo(request);
      return null;
    }

    final itemId = _itemId(request.path);
    if (itemId == null) return null;
    if (method == 'PATCH') return _updateTodo(request, itemId);
    if (method == 'DELETE') return _deleteTodo(request, itemId);
    return null;
  }

  String? _itemId(String path) {
    const prefix = '${FeedApi.feedPath}/';
    if (!path.startsWith(prefix)) return null;
    final id = path.substring(prefix.length);
    if (id.isEmpty || id.contains('/')) return null;
    return id;
  }

  List<DemoTodo> _todosFor(ApiRequest request) {
    final account =
        store.accountFor(request) ?? store.accounts[DemoApi.userId]!;
    return [
      for (final todo in store.todos)
        if (todo.userId == account.id) todo,
    ];
  }

  ApiResponse _feed(ApiRequest request) {
    final owned = _todosFor(request);
    final page = intQuery(request, 'page', 1).clamp(1, 9999);
    final limit = intQuery(
      request,
      'limit',
      DemoApi.feedPageSize,
    ).clamp(1, 50);
    final start = (page - 1) * limit;
    final items = [
      for (var i = start; i < start + limit && i < owned.length; i++)
        owned[i].toJson(),
    ];
    return jsonResponse(200, {
      'items': items,
      'page': page,
      'limit': limit,
      'hasMore': start + items.length < owned.length,
    });
  }

  ApiResponse _createTodo(ApiRequest request) {
    final account = store.accountFor(request);
    if (account == null) return _unauthorized();
    final title = '${requestBody(request.body)['title'] ?? ''}'.trim();
    if (title.isEmpty) {
      return const ApiResponse(
        statusCode: 400,
        body: '{"error":"title required"}',
      );
    }
    final todo = DemoTodo(
      id: '${++store.todoSequence}',
      userId: account.id,
      title: title,
    );
    store.todos.insert(0, todo);
    return jsonResponse(201, todo.toJson());
  }

  ApiResponse _updateTodo(ApiRequest request, String id) {
    final account = store.accountFor(request);
    if (account == null) return _unauthorized();
    final todo = store.todos.cast<DemoTodo?>().firstWhere(
          (candidate) => candidate!.id == id && candidate.userId == account.id,
          orElse: () => null,
        );
    if (todo == null) return _notFound();
    final body = requestBody(request.body);
    if (body.containsKey('title')) {
      final title = '${body['title']}'.trim();
      if (title.isEmpty) {
        return const ApiResponse(
          statusCode: 400,
          body: '{"error":"title required"}',
        );
      }
      todo.title = title;
    }
    if (body.containsKey('done')) {
      final raw = body['done'];
      todo.done = raw == true || raw == 'true';
    }
    return jsonResponse(200, todo.toJson());
  }

  ApiResponse _deleteTodo(ApiRequest request, String id) {
    final account = store.accountFor(request);
    if (account == null) return _unauthorized();
    final index = store.todos.indexWhere(
      (todo) => todo.id == id && todo.userId == account.id,
    );
    if (index < 0) return _notFound();
    final removed = store.todos.removeAt(index);
    return jsonResponse(200, removed.toJson());
  }

  ApiResponse _unauthorized() {
    return const ApiResponse(
      statusCode: 401,
      body: '{"error":"unauthorized"}',
    );
  }

  ApiResponse _notFound() {
    return const ApiResponse(
      statusCode: 404,
      body: '{"error":"not found"}',
    );
  }
}
