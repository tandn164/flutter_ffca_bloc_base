import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logging/logging.dart';

import 'package:composable_network/composable_network.dart';
import 'package:composable_auth/composable_auth.dart' as auth;

import 'package:composable_core/composable_core.dart';

import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/config/composable_runtime_config.dart';
import 'generated/composable_core/di_registrars.g.dart';
import 'core/utils/app_assets.dart';
import 'core/utils/constants.dart';
import 'core/utils/router.dart' as router;
import 'package:composable_ui_kit/composable_ui_kit.dart';
import 'core/utils/widget_util.dart';
import 'core/widgets/app_bloc_provider.dart';
import 'generated/l10n/l10n.dart';
import 'injection_container.dart' as di;
import 'screens/global/presentation/blocs/global/global_bloc.dart';
import 'screens/authentication/data/datasources/authentication_datasource.dart';

auth.ComposableAuthModule _createAuthModule() {
  return auth.ComposableAuthModule(
    config: const auth.AuthConfig(
      mode: auth.AuthMode.authRequired,
      refreshBeforeExpiry: Duration(minutes: 5),
      maxRetryAttempts: 3,
      retryDelay: Duration(seconds: 2),
    ),
    onLogin: (email, password) async {
      final dataSource = di.sl<AuthenticationDataSource>();
      final response = await dataSource.login(email, password);
      
      if (response.data != null && response.data!.accessToken != null) {
        return {
          'access_token': response.data!.accessToken,
          'refresh_token': response.data!.refreshToken,
          'user': {
            'email': email,
            'isVerified': response.data!.isVerified ?? false,
          },
        };
      }
      return null;
    },
    onLogout: (token) async {
      final dataSource = di.sl<AuthenticationDataSource>();
      await dataSource.logout();
    },
    onRefreshToken: (refreshToken) async {
      // TODO: Implement refresh token API call
      // For now, return null to trigger session expiry
      return null;
    },
    onSessionExpired: () {
      // TODO: Handle session expiry (navigate to login, show toast)
      debugPrint('Session expired - user needs to login again');
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupLogging();
  
  try {
    await Environment.init();

    final composableConfig = await ComposableCoreRuntimeConfig.load();
    await ComposableCoreBootstrap.initialize(
      config: composableConfig,
      moduleDescriptors: ComposableCoreModuleRegistrars.descriptors,
      modules: [
        const ComposableNetworkModule(),
        _createAuthModule(),
      ],
      registerAppDependencies: (_) => di.init(),
    );

    
    if (Environment.debugMode) {
      debugPrint('=== Environment Configuration ===');
      debugPrint(Environment.environmentInfo);
      debugPrint('=== ComposableCore Config ===');
      debugPrint('app: ${composableConfig.appName} (${composableConfig.flavor})');
    }
    
    await AppAssets.precacheAssets();
    
    _configureSystemUI();
    
    runApp(const CleanArchitectureWithBloc());
  } catch (error, stackTrace) {
    debugPrint('App initialization failed: $error');
    debugPrint('Stack trace: $stackTrace');
    
    runApp(const ErrorApp());
  }
}


void _configureSystemUI() {
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.bottom],
    );
  }
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  );
}

void _setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

class CleanArchitectureWithBloc extends StatelessWidget {
  const CleanArchitectureWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) => _buildApp(),
    );
  }

  Widget _buildApp() {
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 0.8,
      maxScaleFactor: 1.2,
      child: AppBlocProvider(
        child: Builder(
          builder: (context) {
            final globalState = context.watch<GlobalBloc>().state;
            return _buildMaterialApp(globalState);
          },
        ),
      ),
    );
  }

  Widget _buildMaterialApp(GlobalState globalState) {
    return MaterialApp(
      title: AppConfig.app.displayName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: AppConfig.debug.showDebugBanner,
      onGenerateRoute: router.Router.generateRoute,
      initialRoute: SPLASH_ROUTE,
      navigatorKey: navigatorKey,
      
      // Localization configuration
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      locale: globalState.locale,
      
      // Performance optimizations
      builder: (context, widget) {
        // Ensure text scale factor doesn't break UI
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: widget!,
        );
      },
    );
  }
}

/// Fallback error app when initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      theme: ThemeData.dark(),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appInitError,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(l10n.appRestartMessage),
            ],
          ),
        ),
      ),
    );
  }
}
