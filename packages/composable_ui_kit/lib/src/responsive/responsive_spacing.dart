import 'package:flutter/material.dart';
import 'device_size.dart';

/// Responsive spacing extension to replace flutter_screenutil
/// Provides breakpoint-aware spacing instead of blind scaling
@immutable
class ResponsiveSpacing extends ThemeExtension<ResponsiveSpacing> {
  const ResponsiveSpacing({
    required this.deviceSize,
    required this.baseSpacing,
    required this.config,
  });

  final DeviceSize deviceSize;
  final double baseSpacing;
  final ResponsiveConfig config;

  /// Create responsive spacing for current device size
  factory ResponsiveSpacing.fromContext(
    BuildContext context, [
    ResponsiveConfig config = ResponsiveConfig.material3,
  ]) {
    final deviceSize = ResponsiveUtils.getDeviceSizeFromContext(context, config);
    return ResponsiveSpacing(
      deviceSize: deviceSize,
      baseSpacing: 16.0, // Base 16dp unit
      config: config,
    );
  }

  /// Get responsive spacing value (replaces .w/.h from screenutil)
  double sp(double value) {
    if (!config.enableScaling) return value;
    
    final scale = ResponsiveUtils.getPaddingScale(deviceSize);
    return value * scale;
  }

  /// Get responsive font size (replaces .sp from screenutil) 
  double fontSize(double value) {
    if (!config.enableScaling) return value;
    
    final scale = ResponsiveUtils.getFontScale(deviceSize);
    return value * scale;
  }

  /// Get responsive width (replaces .w from screenutil)
  double width(double value) {
    if (!config.enableScaling) return value;
    
    final scale = ResponsiveUtils.getScaleFactor(deviceSize, config);
    return value * scale;
  }

  /// Get responsive height (replaces .h from screenutil)
  double height(double value) {
    if (!config.enableScaling) return value;
    
    final scale = ResponsiveUtils.getScaleFactor(deviceSize, config);
    return value * scale;
  }

  /// Get responsive size (square) - replaces .r from screenutil
  double r(double value) {
    if (!config.enableScaling) return value;
    
    final scale = ResponsiveUtils.getScaleFactor(deviceSize, config);
    return value * scale;
  }

  /// Get responsive max width for containers
  double maxWidth(double value) {
    if (!config.enableScaling) return value;
    
    // For max width, we use a more conservative scaling
    final scale = switch (deviceSize) {
      DeviceSize.compact => 1.0,
      DeviceSize.medium => 1.3,
      DeviceSize.expanded => 1.6,
    };
    return value * scale;
  }

  /// Get responsive max height for containers
  double maxHeight(double value) {
    if (!config.enableScaling) return value;
    
    // For max height, we use a more conservative scaling
    final scale = switch (deviceSize) {
      DeviceSize.compact => 1.0,
      DeviceSize.medium => 1.2,
      DeviceSize.expanded => 1.4,
    };
    return value * scale;
  }

  /// Create responsive gap (SizedBox) for spacing
  Widget gap(double value) {
    return SizedBox(
      width: sp(value),
      height: sp(value),
    );
  }

  /// Create horizontal gap
  Widget gapH(double width) {
    return SizedBox(width: sp(width));
  }

  /// Create vertical gap
  Widget gapV(double height) {
    return SizedBox(height: sp(height));
  }

  /// Get responsive padding (replaces manual EdgeInsets scaling)
  EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: sp(left ?? horizontal ?? all ?? 0),
      top: sp(top ?? vertical ?? all ?? 0),
      right: sp(right ?? horizontal ?? all ?? 0),
      bottom: sp(bottom ?? vertical ?? all ?? 0),
    );
  }

  /// Get responsive margin
  EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return padding(
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  @override
  ThemeExtension<ResponsiveSpacing> copyWith({
    DeviceSize? deviceSize,
    double? baseSpacing,
    ResponsiveConfig? config,
  }) {
    return ResponsiveSpacing(
      deviceSize: deviceSize ?? this.deviceSize,
      baseSpacing: baseSpacing ?? this.baseSpacing,
      config: config ?? this.config,
    );
  }

  @override
  ThemeExtension<ResponsiveSpacing> lerp(
    ThemeExtension<ResponsiveSpacing>? other,
    double t,
  ) {
    if (other is! ResponsiveSpacing) return this;
    
    // Device size doesn't interpolate, use the target's size
    return copyWith(
      baseSpacing: lerpDouble(baseSpacing, other.baseSpacing, t),
    );
  }
}

/// Helper function for double interpolation
double? lerpDouble(double? a, double? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}