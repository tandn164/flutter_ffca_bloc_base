import 'package:flutter/widgets.dart';

typedef LoadingContentBuilder = Widget Function(BuildContext context);

abstract class LoadingHandle {
  bool get isClosed;
  void close();
}
