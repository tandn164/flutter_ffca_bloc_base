import 'package:flutter/material.dart';
import 'package:flutter_bloc_base/screens/authentication/presentation/authentication/pages/authentication_screen.dart';
import 'package:flutter_bloc_base/screens/authentication/presentation/login_with_email/page/login_with_mail_screen.dart';
import 'package:flutter_bloc_base/screens/authentication/presentation/register_with_email/page/register_with_email_screen.dart';
import 'package:flutter_bloc_base/screens/splash/splash_screen.dart';
import 'package:flutter_bloc_base/screens/tabbar/tabbar.dart';
// Removed notification debug screen - moved to composable_auth package
import 'constants.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Generating route for: ${settings.name}');
    switch (settings.name) {
      case SPLASH_ROUTE:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SplashScreen());
      case MAIN_ROUTE:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const MainTabBar());
      case AUTH_ROUTE:
        return MaterialPageRoute(builder: (_) => const AuthenticationScreen());
      case LOGIN_ROUTE:
        return MaterialPageRoute(builder: (_) => const LoginWithEmailScreen());
      case REGISTER_ROUTE:
        return MaterialPageRoute(builder: (_) => const RegisterWithEmailScreen());
      // Note: Removed NOTIFICATION_DEBUG_ROUTE - notification moved to composable_auth package
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
