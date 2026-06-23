# Composable UI Kit

Design tokens, theme extensions, and type-safe assets for consistent UI development.

## Features

- **Design Tokens**: Consistent colors, spacing, radius, and typography
- **Responsive System**: Breakpoint-based layouts following Material 3 guidelines
- **ThemeExtension**: Material 3 compatible theme system
- **Type-Safe Assets**: Generated asset constants with flutter_gen
- **Context Extensions**: Easy access to design tokens via `context.appColors`
- **Multiple Themes**: Light, dark, and compact theme variants
- **Migration Ready**: Drop-in replacement for `flutter_screenutil`

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  composable_ui_kit:
    path: ../packages/composable_ui_kit
```

## Usage

### 1. Setup Theme

```dart
import 'package:composable_ui_kit/composable_ui_kit.dart';

MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  home: MyHomePage(),
)
```

### 2. Use Design Tokens

```dart
import 'package:composable_ui_kit/composable_ui_kit.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.appSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: context.appRadius.lgRadius,
      ),
      child: Text(
        'Hello World',
        style: context.appTypography.titleLarge.copyWith(
          color: context.appColors.onSurface,
        ),
      ),
    );
  }
}
```

### 3. Type-Safe Assets

```dart
import 'package:composable_ui_kit/composable_ui_kit.dart';

// Generated constants
Image.asset(Assets.images_logo)
SvgPicture.asset(Assets.icons_ic_home)

// Old way (avoid)
// Image.asset('assets/images/logo.png')  ❌
```

### 4. Responsive Design

```dart
import 'package:composable_ui_kit/composable_ui_kit.dart';

// Device size detection
context.deviceSize     // DeviceSize.compact/medium/expanded
context.isCompact      // Phone portrait
context.isMedium       // Tablet portrait, phone landscape
context.isExpanded     // Tablet landscape, desktop

// Responsive spacing (replaces flutter_screenutil)
Container(
  width: context.sp(100),              // Responsive width
  padding: context.paddingAll(16),     // Responsive padding
  child: Column(
    children: [
      Text('Title', style: TextStyle(
        fontSize: context.fontSize(24), // Responsive font size
      )),
      context.gapV(16),                // Responsive vertical gap
      Text('Content'),
    ],
  ),
)

// Responsive layouts
ResponsiveLayout(
  compact: (context) => _buildPhoneLayout(),
  medium: (context) => _buildTabletLayout(), 
  expanded: (context) => _buildDesktopLayout(),
)

// Conditional visibility
ResponsiveVisibility(
  visibleOn: {DeviceSize.medium, DeviceSize.expanded},
  child: SideNavigationBar(),
)
```

### 5. Design Token Access

```dart
// Colors
context.appColors.primary
context.appColors.surface
context.appColors.error

// Spacing
context.appSpacing.xs    // 4dp
context.appSpacing.md    // 16dp
context.appSpacing.xl    // 32dp

// Radius
context.appRadius.sm     // 4dp radius
context.appRadius.lgRadius  // BorderRadius.circular(12)

// Typography
context.appTypography.headlineLarge
context.appTypography.bodyMedium
```

## Design Token Scales

### Responsive System
- **Material 3 breakpoints**: < 600dp (compact), 600-840dp (medium), > 840dp (expanded)
- **Intelligent scaling**: Different scale factors per device category
- **flutter_screenutil replacement**: Drop-in replacement with better UX
- **Layout switching**: Different layouts per breakpoint instead of blind scaling

### Colors
- **Light/Dark variants** for automatic theme switching
- **Semantic colors**: primary, surface, error, etc.
- **Material 3 compatible** color roles

### Spacing
- **Standard scale**: 4dp base unit (4, 8, 16, 24, 32, 48, 64)
- **Compact scale**: 2dp base unit for dense layouts
- **Consistent margins/paddings** across the app

### Radius  
- **Standard scale**: 0, 2, 4, 8, 12, 16, full
- **Material 3 scale**: 0, 4, 8, 12, 16, 28, full
- **BorderRadius helpers** for quick usage

### Typography
- **Material 3 scale**: displayLarge, headlineMedium, bodyLarge, etc.
- **Consistent text sizing** and spacing
- **Font weight and letter spacing** included

## Customization

### Custom Theme Variants

```dart
static ThemeData customTheme() {
  return ThemeData(
    brightness: Brightness.light,
    extensions: const [
      AppColors.light,
      AppSpacing.compact,  // Dense layout
      AppRadius.material3, // M3 radius scale
      AppTypography.material3,
    ],
  );
}
```

### Override Design Tokens

```dart
// Custom colors
const myColors = AppColors(
  primary: Color(0xFF6750A4),
  onPrimary: Color(0xFFFFFFFF),
  // ... other colors
);

// Custom spacing
const mySpacing = AppSpacing(
  xs: 2.0,
  sm: 6.0,
  md: 12.0,
  // ... other spacing
);
```

## Migration from flutter_screenutil

For existing projects using `flutter_screenutil`, see the [Responsive Migration Guide](RESPONSIVE_MIGRATION.md) for step-by-step instructions on migrating to the breakpoint-based system.

**Quick Migration:**
- `.w/.h` → `context.sp()`
- `.sp` → `context.fontSize()`  
- Manual `SizedBox` → `context.gap()`
- Manual `EdgeInsets` → `context.paddingAll()`

## Asset Management

### Adding Assets

1. Follow [Asset Naming Guide](ASSET_NAMING_GUIDE.md) for consistent naming
2. Place assets in `assets/icons/` or `assets/images/`
3. Run `dart run build_runner build` to generate type-safe constants
4. Use generated `Assets.icons_xxx` or `Assets.images_xxx` constants

### Supported Formats
- **Icons**: SVG files (`flutter_svg`)  
- **Images**: PNG, JPG files
- **Fonts**: TTF, OTF files (configure in pubspec.yaml)

## Implementation in Other Projects

To use this pattern in non-ComposableCore projects:

1. **Copy design token classes** (AppColors, AppSpacing, etc.)
2. **Setup ThemeExtension** in your ThemeData
3. **Use context extensions** for easy access
4. **Setup flutter_gen** for type-safe assets
5. **Follow consistent naming** conventions

The design token system is framework-agnostic and can be adapted to any Flutter project structure.

## Best Practices

1. **Use design tokens** instead of hard-coded values
2. **Access via context** extensions (e.g., `context.appColors.primary`)
3. **Use responsive methods** (`context.sp()`, `context.gapV()`) instead of manual scaling
4. **Design for all breakpoints** - test on phones, tablets, and desktop
5. **Prefer semantic colors** over specific hex values
6. **Use generated assets** instead of string paths
7. **Follow spacing scale** for consistent layouts
8. **Test both light and dark themes** in your UI
9. **Use ResponsiveLayout** for significantly different layouts per device size
10. **Avoid over-scaling text** on large screens - readability first