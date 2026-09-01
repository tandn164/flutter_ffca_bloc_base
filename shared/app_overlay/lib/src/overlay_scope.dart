import 'package:flutter/widgets.dart';

import 'overlay_controller.dart';

class OverlayScope extends InheritedWidget {
  const OverlayScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final OverlayController controller;

  static OverlayController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OverlayScope>();
    if (scope == null) {
      throw FlutterError.fromParts([
        ErrorSummary('OverlayScope.of() has no OverlayHost ancestor.'),
        ErrorHint('Wrap MaterialApp.router with OverlayHost in App.builder.'),
      ]);
    }
    return scope.controller;
  }

  @override
  bool updateShouldNotify(OverlayScope oldWidget) =>
      controller != oldWidget.controller;
}
