import 'package:api_client/api_client.dart';

import 'demo_api.dart';

class DemoAccount {
  DemoAccount({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
  });

  final String id;
  final String email;
  String password;
  String name;
}

class DemoTodo {
  DemoTodo({
    required this.id,
    required this.userId,
    required this.title,
    this.done = false,
  });

  final String id;
  final String userId;
  String title;
  bool done;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
      };
}

class FakeDemoStore {
  FakeDemoStore() {
    reset();
  }

  int todoSequence = 0;
  int userSequence = 0;
  final accounts = <String, DemoAccount>{};
  final todos = <DemoTodo>[];
  final accessToUser = <String, String>{};
  final refreshToUser = <String, String>{};

  void reset() {
    accounts
      ..clear()
      ..[DemoApi.userId] = DemoAccount(
        id: DemoApi.userId,
        email: DemoApi.email,
        password: DemoApi.password,
        name: DemoApi.name,
      );
    accessToUser
      ..clear()
      ..[DemoApi.accessToken] = DemoApi.userId
      ..[DemoApi.accessRefreshed] = DemoApi.userId;
    refreshToUser
      ..clear()
      ..[DemoApi.refreshToken] = DemoApi.userId;
    todoSequence = 0;
    userSequence = 0;
    todos
      ..clear()
      ..addAll([
        for (var i = 0; i < seedTitles.length; i++)
          DemoTodo(
            id: '${++todoSequence}',
            userId: DemoApi.userId,
            title: seedTitles[i],
            done: i == 1 || i == 4,
          ),
      ]);
  }

  DemoAccount? accountFor(ApiRequest request) {
    final auth = request.headers['Authorization'] ?? '';
    const prefix = 'Bearer ';
    if (!auth.startsWith(prefix)) return null;
    final userId = accessToUser[auth.substring(prefix.length)];
    if (userId == null) return null;
    return accounts[userId];
  }

  static const seedTitles = [
    'Review design tokens',
    'Write release notes',
    'Approve PR #128',
    'Weekly standup',
    'Send invoice #8821',
    'Reply to spec comments',
    'Ship staging deploy',
    'QA sign-off',
    'Polish onboarding copy',
    'Check API quota',
    'Fix mobile layout',
    'Sample push payload',
    'Drain offline outbox',
    'Confirm session refresh',
    'Tune cache TTL',
    'Skeleton first load',
    'Form validation pass',
    'Deep link /checkout',
    'Crop profile photo',
    'Freeze l10n strings',
    'Cut Fastlane beta',
    'Crash-free 99.8%',
    'Tablet rail nav',
    'Load more page 3',
  ];
}
