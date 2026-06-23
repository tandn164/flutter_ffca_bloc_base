# Asset Naming Convention Guide

## Directory Structure

```
assets/
├── icons/          # SVG icons only
├── images/         # PNG/JPG images  
└── fonts/          # TTF/OTF fonts
```

## Naming Conventions

### Icons (`assets/icons/`)

**Format**: `ic_<name>_<variant>.svg`

**Examples:**
- `ic_home.svg` - Basic home icon
- `ic_home_selected.svg` - Selected state variant
- `ic_profile.svg` - Profile icon
- `ic_eye.svg`, `ic_eye_slash.svg` - Toggle variants
- `ic_arrow_left.svg`, `ic_arrow_right.svg` - Directional icons

**Rules:**
- Use `ic_` prefix for all icons
- Use snake_case for naming
- Use descriptive names: `ic_notification` not `ic_bell`
- For variants use `_variant` suffix: `_selected`, `_disabled`, `_filled`
- For directional: `_up`, `_down`, `_left`, `_right`
- For states: `_active`, `_inactive`, `_pressed`

### Images (`assets/images/`)

**Format**: `<type>_<name>_<size>.ext`

**Examples:**
- `logo.png` - App logo (single asset)
- `img_banner_home.png` - Home screen banner
- `bg_splash.jpg` - Splash background
- `avatar_placeholder.png` - Default avatar

**Rules:**
- Use descriptive prefixes: `img_`, `bg_`, `logo_`, `avatar_`
- Include size variant if multiple: `_sm`, `_md`, `_lg`
- Use appropriate format: PNG for transparency, JPG for photos

### Fonts (`assets/fonts/`)

**Format**: `<FontFamily>-<Weight><Style>.ttf`

**Examples:**
- `Roboto-Regular.ttf`
- `Roboto-Bold.ttf`
- `Roboto-Italic.ttf`
- `OpenSans-SemiBoldItalic.ttf`

## Generated Asset Access

### Icons
```dart
// ✅ Generated (recommended)
SvgPicture.asset(Assets.icons_ic_home)
SvgPicture.asset(Assets.icons_ic_home_selected)

// ❌ Hard-coded (avoid)
SvgPicture.asset('assets/icons/ic_home.svg')
```

### Images
```dart
// ✅ Generated (recommended)  
Image.asset(Assets.images_logo)
Image.asset(Assets.images_img_banner_home)

// ❌ Hard-coded (avoid)
Image.asset('assets/images/logo.png')
```

## Asset Organization Best Practices

### 1. Semantic Grouping
Group related assets by functionality:
```
icons/
├── navigation/     # Bottom nav icons
│   ├── ic_home.svg
│   ├── ic_home_selected.svg
│   └── ic_profile.svg
├── actions/        # Action icons  
│   ├── ic_add.svg
│   └── ic_delete.svg
└── status/         # Status indicators
    ├── ic_success.svg
    └── ic_error.svg
```

### 2. Size Variants
For different screen densities:
```
images/
├── logo.png           # Default size
├── logo_sm.png        # Small variant
└── logo_lg.png        # Large variant
```

### 3. State Variants
For interactive elements:
```
icons/
├── ic_star.svg          # Default state
├── ic_star_filled.svg   # Active state
└── ic_star_half.svg     # Partial state
```

## flutter_gen Configuration

In `pubspec.yaml`:
```yaml
flutter_gen:
  output: lib/src/assets/
  
  assets:
    enabled: true
    outputs:
      style: snake-case        # Generate snake_case constants
      package_parameter_enabled: false
      
flutter:
  assets:
    - assets/icons/
    - assets/images/
```

## Integration with Design System

### Theme-Aware Icons
```dart
// Use theme-aware colors
SvgPicture.asset(
  Assets.icons_ic_home,
  colorFilter: ColorFilter.mode(
    context.appColors.primary,
    BlendMode.srcIn,
  ),
)
```

### Responsive Images
```dart
// Use spacing tokens for consistent sizing
Container(
  width: context.appSpacing.xxxl,
  height: context.appSpacing.xxxl,
  child: Image.asset(Assets.images_logo),
)
```

## Migration Checklist

When adding new assets:

- [ ] Follow naming convention (ic_, img_, bg_, etc.)
- [ ] Place in correct directory (icons/, images/, fonts/)
- [ ] Run `dart run build_runner build` to regenerate
- [ ] Use `Assets.xxx` constants instead of strings
- [ ] Verify assets work in both light/dark themes
- [ ] Add appropriate colorFilters for SVG icons
- [ ] Test on different screen sizes

## Common Mistakes to Avoid

❌ **Wrong:**
```dart
// Hard-coded strings
Image.asset('assets/images/logo.png')

// Inconsistent naming  
SvgPicture.asset(Assets.icons_homeIcon)  // camelCase

// Missing variants
SvgPicture.asset(Assets.icons_ic_button)  // Too generic
```

✅ **Correct:**
```dart
// Generated constants
Image.asset(Assets.images_logo)

// Consistent snake_case
SvgPicture.asset(Assets.icons_ic_home_selected)

// Descriptive variants
SvgPicture.asset(Assets.icons_ic_button_primary)
```

Following these conventions ensures consistent, maintainable, and type-safe asset management across the entire application.