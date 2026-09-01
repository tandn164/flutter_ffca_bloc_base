import 'package:api_client/api_client.dart';
import 'package:app_overlay/app_overlay.dart';
import 'package:app_session/app_session.dart';
import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/fake/demo_api.dart';
import '../network/fake/fake_api_handler.dart';
import '../network/fake/fake_auth_handler.dart';
import '../network/fake/fake_demo_store.dart';
import 'feature_feedback.dart';

AuthApi createAuthApiService() => AuthApi.create();

FakeApiHandler createAuthFakeHandler(FakeDemoStore store) {
  return FakeAuthHandler(store);
}

Set<String> get authHandshakePaths => {
      AuthApi.loginPath,
      AuthApi.signupPath,
      AuthApi.refreshPath,
    };

void registerAuthDependencies(GetIt sl) {
  final preferences = sl<SharedPreferences>();
  sl
    ..registerSingleton<TokenVault>(
      PrefsTokenVault(preferences.getString, preferences.setString),
    )
    ..registerSingleton<Session>(
      AuthSession(
        vault: sl<TokenVault>(),
        refresher: ApiTokenRefresher(sl<ApiTransport>()),
        guestAllowed: sl<AppConfig>().guestAllowed,
      ),
    )
    ..registerLazySingleton<AuthApi>(
      () => sl<ChopperClient>().getService<AuthApi>(),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthApi>()),
    )
    ..registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignupUseCase(sl<AuthRepository>()));
}

List<RouteBase> createAuthRoutes(GetIt sl) {
  return [
    GoRoute(
      path: '/login',
      builder: (context, _) => LoginPage(
        createBloc: () => LoginBloc(
          login: sl<LoginUseCase>(),
          onAuthenticated: (tokens) => sl<Session>().signIn(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          ),
        ),
        demoEmail: DemoApi.email,
        demoPassword: DemoApi.password,
        onSignup: () => context.go('/signup'),
        onForgotPassword: () => context.go('/forgot'),
        onNotice: _onAuthNotice,
        onBusy: busyFeedback(context),
      ),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, _) => SignupPage(
        createBloc: () => SignupBloc(
          signup: sl<SignupUseCase>(),
          onAuthenticated: (tokens) => sl<Session>().signIn(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          ),
        ),
        onLogin: () => context.go('/login'),
        onNotice: _onAuthNotice,
        onBusy: busyFeedback(context),
      ),
    ),
    GoRoute(
      path: '/forgot',
      builder: (context, _) => ForgotPage(
        onBackToLogin: () => context.go('/login'),
      ),
    ),
  ];
}

void _onAuthNotice(BuildContext context, AuthNotice notice) {
  showFeatureToast(
    context,
    type: notice.kind == AuthNoticeKind.error
        ? ToastType.error
        : ToastType.success,
    message: notice.message,
  );
}
