import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logging/logging.dart';

import 'core/utils/app_assets.dart';
import 'core/utils/constants.dart';
import 'core/utils/router.dart' as router;
import 'core/utils/theme.dart';
import 'core/utils/widget_util.dart';
import 'generated/l10n/l10n.dart';
import 'injection_container.dart' as di;
import 'screens/global/presentation/blocs/global/global_bloc.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up logging before initializing dependencies
  _setupLogging();
  
  try {
    // Initialize dependency injection
    await di.init();
    
    // Precache assets for better performance
    await AppAssets.precacheAssets();
    
    // Configure system UI
    _configureSystemUI();
    
    runApp(const CleanArchitectureWithBloc());
  } catch (error, stackTrace) {
    // Log initialization errors
    debugPrint('App initialization failed: $error');
    debugPrint('Stack trace: $stackTrace');
    
    // Run app with error state or fallback
    runApp(const ErrorApp());
  }
}

void _configureSystemUI() {
  // Configure Android-specific UI
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.bottom],
    );
  }
  
  // Configure status bar
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<GlobalBloc>()
              ..add(InitialLocaleEvent()),
          ),
          // Add other BLoCs here as needed
        ],
        child: BlocConsumer<GlobalBloc, GlobalState>(
          listenWhen: (previous, current) => 
              previous.authStatus != current.authStatus,
          listener: _handleGlobalStateChanges,
          builder: (context, state) => _buildMaterialApp(state),
        ),
      ),
    );
  }

  void _handleGlobalStateChanges(BuildContext context, GlobalState state) {
    // Handle authentication status changes
    // Add navigation logic or other side effects here
  }

  Widget _buildMaterialApp(GlobalState globalState) {
    return MaterialApp(
      title: 'Flutter BLoC Base',
      theme: CustomTheme.mainTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
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
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Please restart the application'),
            ],
          ),
        ),
      ),
    );
  }
}
