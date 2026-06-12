import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/constants.dart';
import '../utils/widget_util.dart';
import '../../screens/authentication/presentation/authentication/blocs/authentication_bloc.dart';
import '../../screens/authentication/presentation/authentication/models/auth_status.dart';
import '../../screens/global/presentation/blocs/global/global_bloc.dart';

class AppStateManager {
  static void handleGlobalStateChanges(BuildContext context, GlobalState state) {
    if (state.splashDisplayed) {
      context.read<AuthenticationBloc>().add(CheckAuthenticateEvent());
    }
  }

  static void handleAuthenticationStateChange(BuildContext context, AuthenticationState state) {
    switch (state.authStatus) {
      case AuthStatus.user:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushReplacementNamed(MAIN_ROUTE);
        });
        break;
      case AuthStatus.guest:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushReplacementNamed(AUTH_ROUTE);
        });
        break;
      default:
        break;
    }
  }

  static void handleTokenExpiration(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        LOGIN_ROUTE,
        (route) => false,
      );
    });
  }

  static void handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
