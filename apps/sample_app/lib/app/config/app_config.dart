import 'package:app_overlay/app_overlay.dart';

export 'package:app_overlay/app_overlay.dart' show NoInternetMode, PageConfig;

enum AuthGate { guestAllowed, authRequired }

class AppConfig {
  const AppConfig({
    this.guestAllowed = true,
    this.defaultNoInternet = NoInternetMode.banner,
    this.apiBaseUrl = '',
    this.flavor = 'dev',
  });

  /// App-wide default. Individual routes still set [AuthGate].
  final bool guestAllowed;
  final NoInternetMode defaultNoInternet;
  final String apiBaseUrl;

  /// From `--dart-define=FLAVOR=`. Matches Android productFlavors / iOS schemes.
  final String flavor;
}
