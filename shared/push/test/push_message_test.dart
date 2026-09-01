import 'package:app_push/app_push.dart';
import 'package:test/test.dart';

void main() {
  test('PushMessage.fromPayload copies data and reads title/body', () {
    final message = PushMessage.fromPayload({
      'title': 'Hi',
      'body': 'There',
      'path': '/home',
    });
    expect(message.title, 'Hi');
    expect(message.body, 'There');
    expect(message.data['path'], '/home');
    expect(message.silent, isFalse);
  });

  test('isSilentPayload detects bool and string true', () {
    expect(isSilentPayload({'silent': true, 'path': '/x'}), isTrue);
    expect(isSilentPayload({'silent': 'true', 'path': '/x'}), isTrue);
    expect(isSilentPayload({'path': '/x'}), isFalse);
  });
}
