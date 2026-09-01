import 'package:app_logging/app_logging.dart';
import 'package:flutter/widgets.dart';

class LogNavObserver extends NavigatorObserver {
  LogNavObserver(this.sink);

  final LogSink sink;

  void _log(String action, Route<dynamic>? route) {
    final name = route?.settings.name;
    final arguments = route?.settings.arguments;
    sink.add(
      LogEvent(
        kind: 'navigation',
        message: action,
        fields: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (arguments != null) 'hasArguments': 'true',
        },
      ),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('push', route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _log('replace', newRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('pop', previousRoute);
}
