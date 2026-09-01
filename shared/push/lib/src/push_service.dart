import 'push_message.dart';

enum PushPermissionStatus { notDetermined, denied, provisional, authorized }

class PushPresentationOptions {
  const PushPresentationOptions({
    this.alert = true,
    this.badge = true,
    this.sound = true,
  });

  final bool alert;
  final bool badge;
  final bool sound;
}

/// Push transport contract. Apps register a handler; this package does not navigate.
abstract class PushService {
  void setMessageHandler(void Function(PushMessage message)? handler);

  Future<void> initialize({
    PushPresentationOptions foregroundPresentation =
        const PushPresentationOptions(),
  });

  Future<PushPermissionStatus> requestPermission({
    PushPresentationOptions options = const PushPresentationOptions(),
  }) async =>
      PushPermissionStatus.notDetermined;

  Future<void> clearBadge() async {}

  Future<String?> getToken() async => null;
}
