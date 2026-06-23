import 'package:flutter/material.dart';

/// Design token spacing using ThemeExtension
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  /// Standard spacing scale (4dp base unit)
  static const standard = AppSpacing(
    xs: 4.0,    // 4dp
    sm: 8.0,    // 8dp  
    md: 16.0,   // 16dp
    lg: 24.0,   // 24dp
    xl: 32.0,   // 32dp
    xxl: 48.0,  // 48dp
    xxxl: 64.0, // 64dp
  );

  /// Compact spacing for dense layouts
  static const compact = AppSpacing(
    xs: 2.0,    // 2dp
    sm: 4.0,    // 4dp
    md: 8.0,    // 8dp
    lg: 12.0,   // 12dp
    xl: 16.0,   // 16dp
    xxl: 24.0,  // 24dp
    xxxl: 32.0, // 32dp
  );

  @override
  ThemeExtension<AppSpacing> copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  @override
  ThemeExtension<AppSpacing> lerp(
    ThemeExtension<AppSpacing>? other,
    double t,
  ) {
    if (other is! AppSpacing) {
      return this;
    }

    return AppSpacing(
      xs: _lerpDouble(xs, other.xs, t)!,
      sm: _lerpDouble(sm, other.sm, t)!,
      md: _lerpDouble(md, other.md, t)!,
      lg: _lerpDouble(lg, other.lg, t)!,
      xl: _lerpDouble(xl, other.xl, t)!,
      xxl: _lerpDouble(xxl, other.xxl, t)!,
      xxxl: _lerpDouble(xxxl, other.xxxl, t)!,
    );
  }
}

/// Helper function for double interpolation
double? _lerpDouble(double? a, double? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}