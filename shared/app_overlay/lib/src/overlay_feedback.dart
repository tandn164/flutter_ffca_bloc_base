enum ToastType { success, error, warning, info }

abstract class OverlayFeedback {
  void showToast({
    required ToastType type,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? dedupeKey,
  });

  void pushLoading();
  void popLoading();
}
