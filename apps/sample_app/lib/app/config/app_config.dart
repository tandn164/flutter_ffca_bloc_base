import 'package:app_overlay/app_overlay.dart';

export 'package:app_overlay/app_overlay.dart' show NoInternetMode, PageConfig;

class AppConfig {
  const AppConfig({
    this.defaultNoInternet = NoInternetMode.banner,
    this.flavor = 'dev',
  });

  final NoInternetMode defaultNoInternet;
  final String flavor;
}
