/// Provider-independent push payload. Apps interpret [data] for navigation.
class PushMessage {
  const PushMessage({
    required this.data,
    this.title,
    this.body,
    this.silent = false,
  });

  final Map<String, dynamic> data;
  final String? title;
  final String? body;
  final bool silent;

  factory PushMessage.fromPayload(Map<String, dynamic> payload) {
    return PushMessage(
      data: Map<String, dynamic>.from(payload),
      title: payload['title'] as String?,
      body: payload['body'] as String?,
      silent: isSilentPayload(payload),
    );
  }
}

/// Generic silent/data-message classification (provider-independent flag).
bool isSilentPayload(Map<String, dynamic> payload) {
  final silent = payload['silent'];
  return silent == true || silent == 'true';
}
