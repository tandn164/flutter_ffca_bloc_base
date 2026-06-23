import 'package:flutter/material.dart';
import 'device_size.dart';

/// Builder function for device-specific layouts
typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  DeviceSize deviceSize,
);

/// Builder for compact screens (phones)
typedef CompactBuilder = Widget Function(BuildContext context);

/// Builder for medium screens (small tablets)
typedef MediumBuilder = Widget Function(BuildContext context);

/// Builder for expanded screens (large tablets, desktop)
typedef ExpandedBuilder = Widget Function(BuildContext context);

/// Responsive builder widget that rebuilds on screen size changes
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.config = ResponsiveConfig.material3,
  });

  /// Builder function that receives device size
  final ResponsiveWidgetBuilder builder;
  
  /// Responsive configuration
  final ResponsiveConfig config;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceSize = ResponsiveUtils.getDeviceSize(
          constraints.maxWidth,
          config,
        );
        return builder(context, deviceSize);
      },
    );
  }
}

/// Responsive layout widget with separate builders for each breakpoint
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.config = ResponsiveConfig.material3,
  });

  /// Builder for compact screens (required)
  final CompactBuilder compact;
  
  /// Builder for medium screens (optional, falls back to compact)
  final MediumBuilder? medium;
  
  /// Builder for expanded screens (optional, falls back to medium or compact)
  final ExpandedBuilder? expanded;
  
  /// Responsive configuration
  final ResponsiveConfig config;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      config: config,
      builder: (context, deviceSize) {
        return switch (deviceSize) {
          DeviceSize.compact => compact(context),
          DeviceSize.medium => medium?.call(context) ?? compact(context),
          DeviceSize.expanded => expanded?.call(context) ?? 
                                 medium?.call(context) ?? 
                                 compact(context),
        };
      },
    );
  }
}

/// Conditional responsive widget that shows different content per breakpoint
class ResponsiveVisibility extends StatelessWidget {
  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOn = const {DeviceSize.compact, DeviceSize.medium, DeviceSize.expanded},
    this.hiddenOn = const {},
    this.config = ResponsiveConfig.material3,
  });

  /// Child widget to show/hide
  final Widget child;
  
  /// Device sizes where this widget should be visible
  final Set<DeviceSize> visibleOn;
  
  /// Device sizes where this widget should be hidden
  final Set<DeviceSize> hiddenOn;
  
  /// Responsive configuration
  final ResponsiveConfig config;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      config: config,
      builder: (context, deviceSize) {
        final isVisible = visibleOn.contains(deviceSize) && 
                         !hiddenOn.contains(deviceSize);
        
        if (isVisible) {
          return child;
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Responsive padding widget that scales based on device size
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.config = ResponsiveConfig.material3,
  });

  /// Child widget
  final Widget child;
  
  /// Base padding (will be scaled based on device size)
  final EdgeInsets padding;
  
  /// Responsive configuration
  final ResponsiveConfig config;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      config: config,
      builder: (context, deviceSize) {
        final scale = ResponsiveUtils.getPaddingScale(deviceSize);
        
        return Padding(
          padding: EdgeInsets.only(
            left: padding.left * scale,
            top: padding.top * scale,
            right: padding.right * scale,
            bottom: padding.bottom * scale,
          ),
          child: child,
        );
      },
    );
  }
}

/// Responsive container with max width constraints for better content flow
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidthCompact = 400.0,
    this.maxWidthMedium = 600.0,
    this.maxWidthExpanded = 1200.0,
    this.config = ResponsiveConfig.material3,
  });

  /// Child widget
  final Widget child;
  
  /// Max width for compact screens
  final double maxWidthCompact;
  
  /// Max width for medium screens  
  final double maxWidthMedium;
  
  /// Max width for expanded screens
  final double maxWidthExpanded;
  
  /// Responsive configuration
  final ResponsiveConfig config;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      config: config,
      builder: (context, deviceSize) {
        final maxWidth = switch (deviceSize) {
          DeviceSize.compact => maxWidthCompact,
          DeviceSize.medium => maxWidthMedium,
          DeviceSize.expanded => maxWidthExpanded,
        };
        
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}