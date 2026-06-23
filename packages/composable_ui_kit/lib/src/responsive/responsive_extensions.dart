import 'package:flutter/material.dart';
import 'device_size.dart';
import 'responsive_spacing.dart';

/// Responsive extensions for BuildContext
/// Provides flutter_screenutil replacement with breakpoint-aware scaling
extension ResponsiveExtensions on BuildContext {
  /// Get current device size category
  DeviceSize get deviceSize => ResponsiveUtils.getDeviceSizeFromContext(this);
  
  /// Check if current device is compact (phone portrait)
  bool get isCompact => deviceSize == DeviceSize.compact;
  
  /// Check if current device is medium (tablet portrait, phone landscape)  
  bool get isMedium => deviceSize == DeviceSize.medium;
  
  /// Check if current device is expanded (tablet landscape, desktop)
  bool get isExpanded => deviceSize == DeviceSize.expanded;
  
  /// Get responsive spacing helper
  ResponsiveSpacing get responsive {
    return Theme.of(this).extension<ResponsiveSpacing>() ??
           ResponsiveSpacing.fromContext(this);
  }
  
  /// Responsive spacing value (replaces .w/.h from flutter_screenutil)
  /// 
  /// Example:
  /// ```dart
  /// Container(
  ///   width: context.sp(100), // Scales based on device size
  ///   height: context.sp(50),
  /// )
  /// ```
  double sp(double value) => responsive.sp(value);
  
  /// Responsive font size (replaces .sp from flutter_screenutil)
  ///
  /// Example:
  /// ```dart
  /// Text(
  ///   'Hello',
  ///   style: TextStyle(fontSize: context.fontSize(16)), 
  /// )
  /// ```
  double fontSize(double value) => responsive.fontSize(value);

  /// Responsive width (replaces .w from flutter_screenutil)
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   width: context.width(200), // Responsive width
  ///   child: Text('Content'),
  /// )
  /// ```
  double width(double value) => responsive.width(value);

  /// Responsive height (replaces .h from flutter_screenutil)
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   height: context.height(100), // Responsive height
  ///   child: Text('Content'),
  /// )
  /// ```
  double height(double value) => responsive.height(value);

  /// Responsive size for square widgets (replaces .r from flutter_screenutil)
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   width: context.r(50),  // Square 50x50, responsive
  ///   height: context.r(50),
  ///   child: Icon(Icons.star),
  /// )
  /// ```
  double r(double value) => responsive.r(value);

  /// Responsive max width for containers
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   constraints: BoxConstraints(
  ///     maxWidth: context.maxWidth(400), // Responsive max width
  ///   ),
  ///   child: content,
  /// )
  /// ```
  double maxWidth(double value) => responsive.maxWidth(value);

  /// Responsive max height for containers  
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   constraints: BoxConstraints(
  ///     maxHeight: context.maxHeight(300), // Responsive max height
  ///   ),
  ///   child: content,
  /// )
  /// ```
  double maxHeight(double value) => responsive.maxHeight(value);

  /// Create responsive BoxConstraints
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   constraints: context.constraints(
  ///     minWidth: 100,
  ///     maxWidth: 400,
  ///     minHeight: 50,
  ///     maxHeight: 200,
  ///   ),
  ///   child: content,
  /// )
  /// ```
  BoxConstraints constraints({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth != null ? width(minWidth) : 0.0,
      maxWidth: maxWidth != null ? this.maxWidth(maxWidth) : double.infinity,
      minHeight: minHeight != null ? height(minHeight) : 0.0,
      maxHeight: maxHeight != null ? this.maxHeight(maxHeight) : double.infinity,
    );
  }

  /// Create responsive Size
  ///
  /// Example:
  /// ```dart
  /// CustomPaint(
  ///   size: context.sizeOf(width: 200, height: 100), // Responsive size
  ///   painter: MyPainter(),
  /// )
  /// ```
  Size sizeOf({required double width, required double height}) {
    return Size(this.width(width), this.height(height));
  }

  /// Create square Size (same width and height)
  ///
  /// Example:
  /// ```dart
  /// CustomPaint(
  ///   size: context.squareSize(100), // 100x100, responsive
  ///   painter: MyPainter(),
  /// )
  /// ```
  Size squareSize(double dimension) {
    final responsiveSize = r(dimension);
    return Size(responsiveSize, responsiveSize);
  }
  
  /// Create responsive gap (SizedBox) for spacing
  ///
  /// Example:
  /// ```dart
  /// Column(
  ///   children: [
  ///     Text('First'),
  ///     context.gap(16), // Responsive vertical spacing
  ///     Text('Second'),
  ///   ],
  /// )
  /// ```
  Widget gap(double value) => responsive.gap(value);
  
  /// Create horizontal gap
  ///
  /// Example:
  /// ```dart
  /// Row(
  ///   children: [
  ///     Text('Left'),
  ///     context.gapH(8), // Horizontal spacing
  ///     Text('Right'),
  ///   ],
  /// )
  /// ```
  Widget gapH(double width) => responsive.gapH(width);
  
  /// Create vertical gap
  ///
  /// Example:
  /// ```dart
  /// Column(
  ///   children: [
  ///     Text('Top'),
  ///     context.gapV(12), // Vertical spacing
  ///     Text('Bottom'),
  ///   ],
  /// )
  /// ```
  Widget gapV(double height) => responsive.gapV(height);
  
  /// Get responsive padding
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   padding: context.paddingAll(16), // All sides
  ///   child: Text('Content'),
  /// )
  /// 
  /// Container(
  ///   padding: context.paddingSymmetric(horizontal: 20, vertical: 12),
  ///   child: Text('Content'),
  /// )
  /// ```
  EdgeInsets paddingAll(double value) => responsive.padding(all: value);
  
  EdgeInsets paddingSymmetric({double? horizontal, double? vertical}) {
    return responsive.padding(horizontal: horizontal, vertical: vertical);
  }
  
  EdgeInsets paddingOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return responsive.padding(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
  
  /// Get responsive margin
  EdgeInsets marginAll(double value) => responsive.margin(all: value);
  
  EdgeInsets marginSymmetric({double? horizontal, double? vertical}) {
    return responsive.margin(horizontal: horizontal, vertical: vertical);
  }
  
  EdgeInsets marginOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return responsive.margin(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
}

/// Screen size utility extensions
extension ScreenSizeExtensions on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;
  
  /// Get screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;
  
  /// Get screen size
  Size get screenSize => MediaQuery.sizeOf(this);
  
  /// Check if screen is in landscape orientation
  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;
  
  /// Check if screen is in portrait orientation
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
}