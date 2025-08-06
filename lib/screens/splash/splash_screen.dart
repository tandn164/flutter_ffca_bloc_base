import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../authentication/presentation/authentication/models/auth_status.dart';
import '../global/presentation/blocs/global/global_bloc.dart';
import '../../core/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _minSplashDuration = Duration(milliseconds: 2000);
  static const Duration _maxSplashDuration = Duration(milliseconds: 5000);

  late final DateTime _splashStartTime;

  @override
  void initState() {
    super.initState();
    _splashStartTime = DateTime.now();

    // Get device info and check authentication status
    context.read<GlobalBloc>().add(GetDeviceInfoEvent());
    context.read<GlobalBloc>().add(CheckAuthenticateEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<GlobalBloc, GlobalState>(
        listenWhen: (previous, current) =>
            previous.authStatus != current.authStatus,
        listener: _handleGlobalStateChanges,
        child: _buildSplashContent(),
      ),
    );
  }

  Widget _buildSplashContent() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo or branding
            Icon(
              Icons.flutter_dash,
              size: 80.w,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),

            // App name or title
            Text(
              'Flutter BLoC Base',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40.h),

            // Loading indicator
            BlocBuilder<GlobalBloc, GlobalState>(
              buildWhen: (previous, current) =>
                  previous.authStatus != current.authStatus,
              builder: (context, state) {
                return Column(
                  children: [
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _getLoadingText(state.authStatus),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLoadingText(AuthStatus authStatus) {
    switch (authStatus) {
      case AuthStatus.user:
        return 'Welcome back!';
      case AuthStatus.guest:
        return 'Setting up...';
      case AuthStatus.initial:
        return 'Loading ...';
    }
  }

  void _handleGlobalStateChanges(BuildContext context, GlobalState state) {
    // Only navigate when auth status is determined
    if (state.authStatus != AuthStatus.initial) {
      _navigateToNextScreen(state.authStatus);
    }
  }

  Future<void> _navigateToNextScreen(AuthStatus authStatus) async {
    // Ensure minimum splash duration for better UX
    final elapsedTime = DateTime.now().difference(_splashStartTime);
    if (elapsedTime < _minSplashDuration) {
      await Future.delayed(_minSplashDuration - elapsedTime);
    }

    // Prevent navigation if widget is disposed
    if (!mounted) return;

    // Navigate based on authentication status
    switch (authStatus) {
      case AuthStatus.user:
        _navigateToHome();
        break;
      case AuthStatus.guest:
        _navigateToAuthentication();
        break;
      case AuthStatus.initial:
        // If still checking after max duration, assume unauthenticated
        await Future.delayed(_maxSplashDuration - DateTime.now().difference(_splashStartTime));
        if (mounted) _navigateToAuthentication();
        break;
    }
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      MAIN_ROUTE,
      (route) => false,
    );
  }

  void _navigateToAuthentication() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AUTH_ROUTE,
      (route) => false,
    );
  }
}
