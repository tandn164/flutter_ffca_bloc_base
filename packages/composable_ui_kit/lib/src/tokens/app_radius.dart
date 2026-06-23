import 'package:flutter/material.dart';

/// Design token border radius using ThemeExtension
@immutable
class AppRadius extends ThemeExtension<AppRadius> {
  const AppRadius({
    required this.none,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.full,
  });

  final double none;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double full;

  /// Standard radius scale
  static const standard = AppRadius(
    none: 0.0,     // 0dp - sharp corners
    xs: 2.0,       // 2dp - slight rounding
    sm: 4.0,       // 4dp - small rounding
    md: 8.0,       // 8dp - medium rounding  
    lg: 12.0,      // 12dp - large rounding
    xl: 16.0,      // 16dp - extra large rounding
    full: 999.0,   // Fully rounded (pill shape)
  );

  /// Material 3 radius scale
  static const material3 = AppRadius(
    none: 0.0,     // 0dp
    xs: 4.0,       // 4dp
    sm: 8.0,       // 8dp
    md: 12.0,      // 12dp
    lg: 16.0,      // 16dp
    xl: 28.0,      // 28dp
    full: 999.0,   // Fully rounded
  );

  /// Border radius getters for convenience
  BorderRadius get noneRadius => BorderRadius.circular(none);
  BorderRadius get xsRadius => BorderRadius.circular(xs);
  BorderRadius get smRadius => BorderRadius.circular(sm);
  BorderRadius get mdRadius => BorderRadius.circular(md);
  BorderRadius get lgRadius => BorderRadius.circular(lg);
  BorderRadius get xlRadius => BorderRadius.circular(xl);
  BorderRadius get fullRadius => BorderRadius.circular(full);

  @override
  ThemeExtension<AppRadius> copyWith({
    double? none,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? full,
  }) {
    return AppRadius(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  @override
  ThemeExtension<AppRadius> lerp(
    ThemeExtension<AppRadius>? other,
    double t,
  ) {
    if (other is! AppRadius) {
      return this;
    }

    return AppRadius(
      none: _lerpDouble(none, other.none, t) ?? none,
      xs: _lerpDouble(xs, other.xs, t) ?? xs,
      sm: _lerpDouble(sm, other.sm, t) ?? sm,
      md: _lerpDouble(md, other.md, t) ?? md,
      lg: _lerpDouble(lg, other.lg, t) ?? lg,
      xl: _lerpDouble(xl, other.xl, t) ?? xl,
      full: _lerpDouble(full, other.full, t) ?? full,
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