import 'package:app_overlay/app_overlay.dart';
import 'package:flutter/widgets.dart';

void showFeatureToast(
  BuildContext context, {
  required ToastType type,
  required String message,
}) {
  OverlayScope.of(context).showToast(type: type, message: message);
}

void Function(bool busy) busyFeedback(BuildContext context) {
  return (busy) {
    final overlay = OverlayScope.of(context);
    if (busy) {
      overlay.pushLoading();
    } else {
      overlay.popLoading();
    }
  };
}
