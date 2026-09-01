import 'package:app_push/app_push.dart';
import 'package:test/test.dart';

void main() {
  test('StubPushService delivers non-silent messages to handler', () {
    PushMessage? received;
    final service = StubPushService();
    service.setMessageHandler((message) => received = message);
    service.deliver({'path': '/home'});
    expect(received?.data['path'], '/home');
  });

  test('StubPushService skips silent payloads', () {
    var calls = 0;
    final service = StubPushService();
    service.setMessageHandler((_) => calls++);
    service.deliver({'path': '/x', 'silent': true});
    expect(calls, 0);
  });
}
