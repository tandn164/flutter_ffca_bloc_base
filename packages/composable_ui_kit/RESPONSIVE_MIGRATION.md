# Migration Guide: flutter_screenutil → Responsive System

## Overview

This guide helps migrate from `flutter_screenutil` blind scaling to breakpoint-based responsive design following Material 3 guidelines.

## Key Differences

| flutter_screenutil | Composable Responsive |
|-------------------|---------------------|
| ❌ Blind scaling based on design size (390×844) | ✅ Breakpoint-aware scaling |
| ❌ Same UI on all devices (just scaled) | ✅ Different layouts per device category |
| ❌ Magic numbers everywhere (`.w`, `.h`, `.sp`) | ✅ Semantic responsive methods |
| ❌ Poor tablet/desktop experience | ✅ Optimized for all screen sizes |

## Breakpoint System

### Material 3 Breakpoints

- **Compact**: < 600dp (Phone portrait)
- **Medium**: 600-840dp (Tablet portrait, phone landscape)  
- **Expanded**: > 840dp (Tablet landscape, desktop)

### Device Size Detection

```dart
// Check current device size
context.deviceSize           // DeviceSize.compact/medium/expanded
context.isCompact           // bool
context.isMedium            // bool  
context.isExpanded          // bool
```

## Migration Examples

### 1. Width & Height

```dart
// ❌ Before (flutter_screenutil)
Container(
  width: 200.w,
  height: 100.h,
  child: Text('Content'),
)

// ✅ After (responsive)  
Container(
  width: context.width(200),
  height: context.height(100),
  child: Text('Content'),
)

// Or use ResponsiveBox
ResponsiveBox(
  width: 200,
  height: 100,
  child: Text('Content'),
)
```

### 2. Max Width & Max Height

```dart
// ❌ Before (flutter_screenutil)
Container(
  constraints: BoxConstraints(
    maxWidth: 400.w,
    maxHeight: 300.h,
  ),
  child: content,
)

// ✅ After (responsive)
Container(
  constraints: context.constraints(
    maxWidth: 400,
    maxHeight: 300,
  ),
  child: content,
)

// Or use ResponsiveBox
ResponsiveBox(
  maxWidth: 400,
  maxHeight: 300,
  child: content,
)
```

### 3. Square Sizes

```dart
// ❌ Before (flutter_screenutil)
Container(
  width: 50.r,
  height: 50.r,
  child: Icon(Icons.star),
)

// ✅ After (responsive)
Container(
  width: context.r(50),
  height: context.r(50),
  child: Icon(Icons.star),
)

// Or use ResponsiveSizedBox
ResponsiveSizedBox(
  width: 50,
  height: 50,
  child: Icon(Icons.star),
)
```

### 4. Basic Spacing

```dart
// ❌ Before (flutter_screenutil)
Container(
  padding: EdgeInsets.all(16.w),
  child: Text('Content'),
)

// ✅ After (responsive)
Container(
  padding: context.paddingAll(16),
  child: Text('Content'),
)

// Or use ResponsiveBox
ResponsiveBox(
  padding: EdgeInsets.all(16),
  child: Text('Content'),
)
```

### 5. Font Sizes

```dart
// ❌ Before (flutter_screenutil)
Text(
  'Hello World',
  style: TextStyle(fontSize: 18.sp),
)

// ✅ After (responsive)
Text(
  'Hello World',
  style: TextStyle(fontSize: context.fontSize(18)),
)
```

### 6. Positioned Widgets

```dart
// ❌ Before (flutter_screenutil)
Positioned(
  left: 20.w,
  top: 30.h,
  width: 100.w,
  height: 50.h,
  child: widget,
)

// ✅ After (responsive)
ResponsivePositioned(
  left: 20,
  top: 30,
  width: 100,
  height: 50,
  child: widget,
)
```

### 7. Responsive Gaps

```dart
// ❌ Before (manual SizedBox)
Column(
  children: [
    Text('First'),
    SizedBox(height: 16.h),
    Text('Second'),
  ],
)

// ✅ After (responsive gap)
Column(
  children: [
    Text('First'),
    context.gapV(16),        // Vertical gap
    Text('Second'),
  ],
)

// ✅ Row spacing
Row(
  children: [
    Text('Left'),
    context.gapH(8),         // Horizontal gap
    Text('Right'),
  ],
)
```

## Responsive Layouts

### 1. Device-Specific Layouts

```dart
// ✅ Different layouts per device size
ResponsiveLayout(
  compact: (context) => _buildPhoneLayout(),
  medium: (context) => _buildTabletLayout(),
  expanded: (context) => _buildDesktopLayout(),
)
```

### 2. Responsive Builder

```dart
// ✅ Custom responsive logic
ResponsiveBuilder(
  builder: (context, deviceSize) {
    switch (deviceSize) {
      case DeviceSize.compact:
        return SingleChildScrollView(child: content);
      case DeviceSize.medium:
        return Row(children: [sidebar, content]);
      case DeviceSize.expanded:
        return Row(children: [sidebar, content, rightPanel]);
    }
  },
)
```

### 3. Conditional Visibility

```dart
// ✅ Show/hide based on screen size
ResponsiveVisibility(
  visibleOn: {DeviceSize.medium, DeviceSize.expanded},
  child: SideNavigationBar(),
)

ResponsiveVisibility(
  visibleOn: {DeviceSize.compact},
  child: BottomNavigationBar(),
)
```

## Advanced Migration Patterns

### 1. Responsive Container

```dart
// ✅ Max width constraints for better content flow
ResponsiveContainer(
  maxWidthCompact: 400,
  maxWidthMedium: 600,
  maxWidthExpanded: 1200,
  child: content,
)
```

### 2. Responsive Padding

```dart
// ✅ Automatic padding scaling
ResponsivePadding(
  padding: EdgeInsets.all(16),  // Scales based on device
  child: content,
)
```

### 3. Context Extensions Usage

```dart
// ✅ All available responsive extensions
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(200),                    // Responsive width
      padding: context.paddingSymmetric(        // Responsive padding
        horizontal: 20, 
        vertical: 16,
      ),
      margin: context.marginAll(12),            // Responsive margin
      child: Column(
        children: [
          Text(
            'Title', 
            style: TextStyle(fontSize: context.fontSize(24)),
          ),
          context.gapV(16),                     // Responsive vertical gap
          Text(
            'Subtitle',
            style: TextStyle(fontSize: context.fontSize(16)),
          ),
        ],
      ),
    );
  }
}
```

## Step-by-Step Migration

### Step 1: Replace Basic Scaling

```dart
// Find & replace patterns:
# For actual dimensions:
.w          → context.width()     # For widths
.h          → context.height()    # For heights  
.r          → context.r()         # For square sizes
.sp         → context.fontSize()  # For font sizes

# For spacing (padding/margin):
.w          → context.sp()        # For spacing values
.h          → context.sp()        # For spacing values
```

### Step 2: Replace SizedBox Spacing

```dart
// Replace manual spacing:
SizedBox(height: x.h)    → context.gapV(x)
SizedBox(width: x.w)     → context.gapH(x)
SizedBox.square(x.r)     → context.gap(x)
```

### Step 3: Replace EdgeInsets

```dart
// Replace manual padding/margin:
EdgeInsets.all(x.w)                    → context.paddingAll(x)
EdgeInsets.symmetric(horizontal: x.w)  → context.paddingSymmetric(horizontal: x)
EdgeInsets.only(left: x.w, top: y.h)  → context.paddingOnly(left: x, top: y)
```

### Step 4: Add Device-Specific Layouts

```dart
// Add responsive layouts where appropriate:
// - Navigation (bottom nav → side nav on tablets)
// - Content layout (single column → multi-column)
// - Input forms (stacked → side-by-side)
// - Image galleries (grid column count)
```

## Configuration Options

### Custom Breakpoints

```dart
const customConfig = ResponsiveConfig(
  compactBreakpoint: 480.0,    // Custom phone→tablet threshold
  mediumBreakpoint: 960.0,     // Custom tablet→desktop threshold  
  scaleFactor: 1.1,            // Global scale multiplier
  enableScaling: true,         // Enable/disable responsive scaling
);

ResponsiveBuilder(
  config: customConfig,
  builder: (context, deviceSize) => content,
)
```

### Disable Responsive Scaling

```dart
// For apps that want fixed layouts
const ResponsiveConfig.compactOnly  // Disables scaling
```

## Testing Responsive Layouts

### 1. Device Preview

Use Flutter Inspector's device preview to test different screen sizes:
- iPhone 13 (390×844) - Compact
- iPad Air (820×1180) - Medium  
- Desktop (1440×900) - Expanded

### 2. Responsive Testing Widget

```dart
class ResponsiveTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Device: ${context.deviceSize}'),
          Text('Width: ${context.screenWidth}'),
          Text('Compact: ${context.isCompact}'),
          Text('Medium: ${context.isMedium}'),
          Text('Expanded: ${context.isExpanded}'),
          
          Container(
            width: context.sp(100),
            height: context.sp(50),
            color: Colors.blue,
            child: Text('Responsive Box'),
          ),
        ],
      ),
    );
  }
}
```

## Benefits After Migration

✅ **Better UX**: Optimized layouts for each device category  
✅ **Maintainable**: Semantic responsive methods instead of magic numbers  
✅ **Future-proof**: Breakpoint system scales to new device sizes  
✅ **Performance**: No unnecessary rebuilds on orientation change  
✅ **Design System**: Consistent with Material 3 guidelines  

## Common Pitfalls

❌ **Don't**: Use responsive scaling for everything  
✅ **Do**: Use responsive layouts for major UI differences  

❌ **Don't**: Scale text too aggressively on large screens  
✅ **Do**: Keep text readable across all devices  

❌ **Don't**: Ignore landscape orientation  
✅ **Do**: Test both portrait and landscape modes  

❌ **Don't**: Assume tablet = big phone  
✅ **Do**: Design tablet-specific interactions