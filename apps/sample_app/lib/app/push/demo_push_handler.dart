import 'package:app_navigation/app_navigation.dart';
import 'package:app_push/app_push.dart';

/// Demo app: interpret [PushMessage] data as GoRouter locations.
class DemoPushHandler {
  const DemoPushHandler({required this.navigate});

  final void Function(String location) navigate;

  void handle(PushMessage message) {
    final location = locationFromPayload(message.data);
    if (location != null) navigate(location);
  }
}

/// Convenience for stub/tests: raw payload → app deep-link → navigate.
void openDemoPush(
    void Function(String location) go, Map<String, dynamic> payload) {
  final message = PushMessage.fromPayload(payload);
  if (message.silent) return;
  DemoPushHandler(navigate: go).handle(message);
}
