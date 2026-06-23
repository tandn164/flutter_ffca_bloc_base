import 'package:flutter/material.dart';

/// Device size categories based on Material 3 breakpoints
enum DeviceSize {
  /// Compact screens (< 600dp width)
  /// Typical: Phones in portrait, small tablets in portrait
  compact,
  
  /// Medium screens (600-840dp width) 
  /// Typical: Tablets in portrait, phones in landscape
  medium,
  
  /// Expanded screens (> 840dp width)
  /// Typical: Tablets in landscape, desktop, large displays
  expanded,
}

/// Responsive configuration for breakpoint-based layouts
class ResponsiveConfig {
  const ResponsiveConfig({
    this.compactBreakpoint = 600.0,
    this.mediumBreakpoint = 840.0,
    this.scaleFactor = 1.0,
    this.enableScaling = true,
  });

  /// Breakpoint for compact -> medium transition (default: 600dp)
  final double compactBreakpoint;
  
  /// Breakpoint for medium -> expanded transition (default: 840dp)
  final double mediumBreakpoint;
  
  /// Base scale factor for responsive scaling
  final double scaleFactor;
  
  /// Enable/disable responsive scaling
  final bool enableScaling;

  /// Default configuration following Material 3 guidelines
  static const material3 = ResponsiveConfig();
  
  /// Compact-only configuration (disable responsive scaling)
  static const compactOnly = ResponsiveConfig(enableScaling: false);
}

/// Responsive utilities for device size detection
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Get device size category based on screen width
  static DeviceSize getDeviceSize(
    double screenWidth, [
    ResponsiveConfig config = ResponsiveConfig.material3,
  ]) {
    if (screenWidth < config.compactBreakpoint) {
      return DeviceSize.compact;
    } else if (screenWidth < config.mediumBreakpoint) {
      return DeviceSize.medium;
    } else {
      return DeviceSize.expanded;
    }
  }

  /// Get device size from MediaQuery
  static DeviceSize getDeviceSizeFromContext(
    BuildContext context, [
    ResponsiveConfig config = ResponsiveConfig.material3,
  ]) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return getDeviceSize(screenWidth, config);
  }

  /// Check if device is compact size
  static bool isCompact(BuildContext context) {
    return getDeviceSizeFromContext(context) == DeviceSize.compact;
  }

  /// Check if device is medium size
  static bool isMedium(BuildContext context) {
    return getDeviceSizeFromContext(context) == DeviceSize.medium;
  }

  /// Check if device is expanded size
  static bool isExpanded(BuildContext context) {
    return getDeviceSizeFromContext(context) == DeviceSize.expanded;
  }

  /// Get responsive scale factor based on device size
  static double getScaleFactor(
    DeviceSize deviceSize, [
    ResponsiveConfig config = ResponsiveConfig.material3,
  ]) {
    if (!config.enableScaling) return 1.0;
    
    return switch (deviceSize) {
      DeviceSize.compact => 1.0 * config.scaleFactor,
      DeviceSize.medium => 1.1 * config.scaleFactor,
      DeviceSize.expanded => 1.2 * config.scaleFactor,
    };
  }

  /// Get responsive font scale factor
  static double getFontScale(DeviceSize deviceSize) {
    return switch (deviceSize) {
      DeviceSize.compact => 1.0,
      DeviceSize.medium => 1.0,    // Keep same font size for readability
      DeviceSize.expanded => 1.1,  // Slightly larger for desktop viewing distance
    };
  }

  /// Get responsive padding scale factor
  static double getPaddingScale(DeviceSize deviceSize) {
    return switch (deviceSize) {
      DeviceSize.compact => 1.0,
      DeviceSize.medium => 1.2,    // More breathing room on tablets
      DeviceSize.expanded => 1.4,  // Even more space on desktop
    };
  }
}