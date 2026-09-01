import 'push_message.dart';
import 'push_service.dart';

/// App-agnostic stub until a real provider (e.g. FCM) implements [PushService].
class StubPushService implements PushService {
  StubPushService();

  void Function(PushMessage message)? _handler;

  @override
  void setMessageHandler(void Function(PushMessage message)? handler) {
    _handler = handler;
  }

  @override
  Future<void> initialize({
    PushPresentationOptions foregroundPresentation =
        const PushPresentationOptions(),
  }) async {}

  @override
  Future<PushPermissionStatus> requestPermission({
    PushPresentationOptions options = const PushPresentationOptions(),
  }) async =>
      PushPermissionStatus.authorized;

  @override
  Future<void> clearBadge() async {}

  @override
  Future<String?> getToken() async => null;

  /// Delivers a raw provider payload (stub/tests). Skips silent messages.
  void deliver(Map<String, dynamic> payload) {
    final message = PushMessage.fromPayload(payload);
    if (message.silent) return;
    _handler?.call(message);
  }
}
