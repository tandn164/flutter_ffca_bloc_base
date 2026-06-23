import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';
import '../responsive/responsive_spacing.dart';

/// Convenient extensions to access design tokens from BuildContext
extension ThemeExtensions on BuildContext {
  /// Access app colors design tokens
  AppColors get appColors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
  
  /// Access app spacing design tokens
  AppSpacing get appSpacing => Theme.of(this).extension<AppSpacing>() ?? AppSpacing.standard;
  
  /// Access app radius design tokens
  AppRadius get appRadius => Theme.of(this).extension<AppRadius>() ?? AppRadius.standard;
  
  /// Access app typography design tokens
  AppTypography get appTypography => Theme.of(this).extension<AppTypography>() ?? AppTypography.material3;
}

/// Theme data factory with design token extensions
class AppTheme {
  AppTheme._();
  
  /// Create light theme with design tokens
  static ThemeData light([BuildContext? context]) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Roboto',
      extensions: [
        AppColors.light,
        AppSpacing.standard,
        AppRadius.standard,
        AppTypography.material3,
        if (context != null) ResponsiveSpacing.fromContext(context),
      ],
    );
  }
  
  /// Create dark theme with design tokens
  static ThemeData dark([BuildContext? context]) {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'Roboto',
      extensions: [
        AppColors.dark,
        AppSpacing.standard,
        AppRadius.standard,
        AppTypography.material3,
        if (context != null) ResponsiveSpacing.fromContext(context),
      ],
    );
  }
  
  /// Create compact theme for dense layouts
  static ThemeData compact([BuildContext? context]) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Roboto',
      extensions: [
        AppColors.light,
        AppSpacing.compact,
        AppRadius.standard,
        AppTypography.material3,
        if (context != null) ResponsiveSpacing.fromContext(context),
      ],
    );
  }
}