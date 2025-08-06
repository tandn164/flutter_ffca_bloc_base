import 'package:flutter/material.dart';
import '../../generated/l10n/l10n.dart';
import '../widgets/loading_view.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
S get l10n {
  return S.of(navigatorKey.currentContext!)!;
}

final GlobalKey loadingKey = GlobalKey(debugLabel: "Loading");

void showLoading() {
  showDialog(
    context: navigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LoadingView(
        key: loadingKey,
      );
    },
  );
}

void hideLoading() {
  if (loadingKey.currentContext != null) {
    Navigator.of(navigatorKey.currentContext!).pop();
  }
}
