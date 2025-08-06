import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/color_resource.dart';
import '../../../../../core/utils/constants.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({
    super.key,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  Color get _backgroundColor => backgroundColor ?? ColorResource.color0F0F0F;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _buildAuthenticationContent(context),
      ),
    );
  }

  Widget _buildAuthenticationContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Top spacing for close button
          SizedBox(height: 60.h),
          
          // Logo and branding section
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60.w),
                  ),
                  child: Icon(
                    Icons.flutter_dash,
                    size: 60.w,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // App name
                Text(
                  'Flutter BLoC Base',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Subtitle
                Text(
                  'Welcome! Please choose an option to continue',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Buttons section
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Login Button
                _buildActionButton(
                  context: context,
                  title: 'Login',
                  subtitle: 'Sign in to your account',
                  icon: Icons.login,
                  onTap: () => _navigateToLogin(context),
                  isPrimary: true,
                ),
                
                SizedBox(height: 16.h),
                
                // Register Button
                _buildActionButton(
                  context: context,
                  title: 'Register',
                  subtitle: 'Create a new account',
                  icon: Icons.person_add,
                  onTap: () => _navigateToRegister(context),
                  isPrimary: false,
                ),

                SizedBox(height: 16.h),

                // Optional: Guest/Skip option
                TextButton(
                  onPressed: () => _continueAsGuest(context),
                  child: Text(
                    'Continue as Guest',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: 72.h,
      decoration: BoxDecoration(
        color: isPrimary 
            ? Colors.white 
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: isPrimary 
            ? null 
            : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isPrimary 
                        ? _backgroundColor.withOpacity(0.1)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary ? _backgroundColor : Colors.white,
                    size: 20.w,
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Text content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isPrimary ? _backgroundColor : Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isPrimary 
                              ? _backgroundColor.withOpacity(0.7)
                              : Colors.white.withOpacity(0.7),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: isPrimary 
                      ? _backgroundColor.withOpacity(0.7)
                      : Colors.white.withOpacity(0.7),
                  size: 16.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, LOGIN_ROUTE);
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, REGISTER_ROUTE);
  }

  void _continueAsGuest(BuildContext context) {
    // Navigate to main app as guest
    Navigator.pushNamedAndRemoveUntil(
      context,
      MAIN_ROUTE,
      (route) => false,
    );
  }
}
