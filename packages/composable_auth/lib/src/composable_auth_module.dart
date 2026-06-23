import 'package:composable_core/composable_core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_config.dart';
import 'auth_service.dart';

class ComposableAuthModule implements ComposableCoreModule {
  ComposableAuthModule({
    required this.config,
    required this.onLogin,
    required this.onLogout,
    required this.onRefreshToken,
    this.onSessionExpired,
    this.isEnabled = true,
  });

  final AuthConfig config;
  final LoginCallback onLogin;
  final LogoutCallback onLogout;
  final TokenRefreshCallback onRefreshToken;
  final SessionExpiredCallback? onSessionExpired;
  
  @override
  final bool isEnabled;

  @override
  String get id => 'composable_auth';

  @override
  Future<void> register(GetIt sl) async {
    if (!isEnabled) return;
    
    // Register AuthConfig
    sl.registerLazySingleton<AuthConfig>(() => config);

    // Register AuthService
    sl.registerLazySingleton<AuthService>(
      () => AuthService(
        config: sl<AuthConfig>(),
        sharedPreferences: sl<SharedPreferences>(),
        onLogin: onLogin,
        onLogout: onLogout,
        onRefreshToken: onRefreshToken,
        onSessionExpired: onSessionExpired,
      ),
    );
  }

  @override
  Future<void> bootstrap(GetIt sl) async {
    if (!isEnabled) return;
    
    final authService = sl<AuthService>();
    await authService.initialize();
  }
}