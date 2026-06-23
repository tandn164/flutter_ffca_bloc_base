import 'package:flutter/material.dart';
import 'device_size.dart';
import 'responsive_extensions.dart';

/// Responsive SizedBox that scales based on device size
class ResponsiveSizedBox extends StatelessWidget {
  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  /// Responsive width (will be scaled based on device)
  final double? width;
  
  /// Responsive height (will be scaled based on device)
  final double? height;
  
  /// Optional child widget
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width != null ? context.width(width!) : null,
      height: height != null ? context.height(height!) : null,
      child: child,
    );
  }
}

/// Responsive Box with automatic scaling for dimensions  
class ResponsiveBox extends StatelessWidget {
  const ResponsiveBox({
    super.key,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.padding,
    this.margin,
    this.decoration,
    this.constraints,
    this.child,
  });

  /// Responsive width
  final double? width;
  
  /// Responsive height
  final double? height;
  
  /// Responsive minimum width
  final double? minWidth;
  
  /// Responsive maximum width  
  final double? maxWidth;
  
  /// Responsive minimum height
  final double? minHeight;
  
  /// Responsive maximum height
  final double? maxHeight;
  
  /// Responsive padding (will be scaled)
  final EdgeInsets? padding;
  
  /// Responsive margin (will be scaled)
  final EdgeInsets? margin;
  
  /// Container decoration (unchanged)
  final Decoration? decoration;
  
  /// Additional constraints (will override width/height constraints)
  final BoxConstraints? constraints;
  
  /// Child widget
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    BoxConstraints? finalConstraints;
    
    if (constraints != null) {
      finalConstraints = constraints;
    } else if (minWidth != null || maxWidth != null || minHeight != null || maxHeight != null) {
      finalConstraints = context.constraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );
    }

    return Container(
      width: width != null ? context.width(width!) : null,
      height: height != null ? context.height(height!) : null,
      padding: padding != null ? _scaleEdgeInsets(context, padding!) : null,
      margin: margin != null ? _scaleEdgeInsets(context, margin!) : null,
      constraints: finalConstraints,
      decoration: decoration,
      child: child,
    );
  }

  EdgeInsets _scaleEdgeInsets(BuildContext context, EdgeInsets insets) {
    return EdgeInsets.only(
      left: context.sp(insets.left),
      top: context.sp(insets.top),
      right: context.sp(insets.right),
      bottom: context.sp(insets.bottom),
    );
  }
}

/// Responsive positioned widget for Stack
class ResponsivePositioned extends StatelessWidget {
  const ResponsivePositioned({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    required this.child,
  });

  /// Responsive left position
  final double? left;
  
  /// Responsive top position
  final double? top;
  
  /// Responsive right position  
  final double? right;
  
  /// Responsive bottom position
  final double? bottom;
  
  /// Responsive width
  final double? width;
  
  /// Responsive height
  final double? height;
  
  /// Child widget
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left != null ? context.width(left!) : null,
      top: top != null ? context.height(top!) : null,
      right: right != null ? context.width(right!) : null,
      bottom: bottom != null ? context.height(bottom!) : null,
      width: width != null ? context.width(width!) : null,
      height: height != null ? context.height(height!) : null,
      child: child,
    );
  }
}

/// Responsive aspect ratio that scales based on device
class ResponsiveAspectRatio extends StatelessWidget {
  const ResponsiveAspectRatio({
    super.key,
    required this.aspectRatio,
    this.scaleWithDevice = true,
    required this.child,
  });

  /// Base aspect ratio
  final double aspectRatio;
  
  /// Whether to adjust aspect ratio based on device size
  final bool scaleWithDevice;
  
  /// Child widget
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double finalAspectRatio = aspectRatio;
    
    if (scaleWithDevice) {
      // Adjust aspect ratio slightly for different devices
      finalAspectRatio = switch (context.deviceSize) {
        DeviceSize.compact => aspectRatio,
        DeviceSize.medium => aspectRatio * 1.1,    // Slightly wider on tablets
        DeviceSize.expanded => aspectRatio * 1.2,  // Even wider on desktop
      };
    }

    return AspectRatio(
      aspectRatio: finalAspectRatio,
      child: child,
    );
  }
}

/// Responsive flexible that adjusts flex based on device size
class ResponsiveFlex extends StatelessWidget {
  const ResponsiveFlex({
    super.key,
    this.compactFlex = 1,
    this.mediumFlex,
    this.expandedFlex,
    required this.child,
  });

  /// Flex value for compact devices
  final int compactFlex;
  
  /// Flex value for medium devices (defaults to compactFlex)
  final int? mediumFlex;
  
  /// Flex value for expanded devices (defaults to mediumFlex or compactFlex)
  final int? expandedFlex;
  
  /// Child widget
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final flex = switch (context.deviceSize) {
      DeviceSize.compact => compactFlex,
      DeviceSize.medium => mediumFlex ?? compactFlex,
      DeviceSize.expanded => expandedFlex ?? mediumFlex ?? compactFlex,
    };

    return Flexible(
      flex: flex,
      child: child,
    );
  }
}

/// Responsive expanded that adjusts flex based on device size
class ResponsiveExpanded extends StatelessWidget {
  const ResponsiveExpanded({
    super.key,
    this.compactFlex = 1,
    this.mediumFlex,
    this.expandedFlex,
    required this.child,
  });

  /// Flex value for compact devices
  final int compactFlex;
  
  /// Flex value for medium devices (defaults to compactFlex)
  final int? mediumFlex;
  
  /// Flex value for expanded devices (defaults to mediumFlex or compactFlex)
  final int? expandedFlex;
  
  /// Child widget
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final flex = switch (context.deviceSize) {
      DeviceSize.compact => compactFlex,
      DeviceSize.medium => mediumFlex ?? compactFlex,
      DeviceSize.expanded => expandedFlex ?? mediumFlex ?? compactFlex,
    };

    return Expanded(
      flex: flex,
      child: child,
    );
  }
}