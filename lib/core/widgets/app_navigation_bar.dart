import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App Navigation Bar widget that can be reused across the app
/// Features:
/// - Customizable title
/// - Automatic back button (when not on first screen)
/// - Optional custom action button on the right
/// - Consistent styling
class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;
  final Widget? customBackButton;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  
  // Custom action button properties
  final String? actionText;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final Color? actionColor;
  final String? actionTooltip;
  final bool showAction;

  const AppNavigationBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.customBackButton,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.actionText,
    this.actionIcon,
    this.onActionPressed,
    this.actionColor,
    this.actionTooltip,
    this.showAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context),
      actions: showAction ? [_buildActionButton(context)] : null,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    // If custom back button is provided, use it
    if (customBackButton != null) {
      return customBackButton;
    }

    // If automatically implying leading and can pop, show back button
    if (automaticallyImplyLeading && Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20.r,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  Widget _buildActionButton(BuildContext context) {
    // If both icon and text are provided, show icon with text
    if (actionIcon != null && actionText != null) {
      return Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: TextButton.icon(
          onPressed: onActionPressed,
          icon: Icon(
            actionIcon,
            size: 18.r,
            color: actionColor ?? Theme.of(context).primaryColor,
          ),
          label: Text(
            actionText!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: actionColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    // If only icon is provided, show icon button
    if (actionIcon != null) {
      return IconButton(
        icon: Icon(
          actionIcon,
          size: 22.r,
          color: actionColor,
        ),
        onPressed: onActionPressed,
        tooltip: actionTooltip ?? '',
      );
    }

    // If only text is provided, show text button
    if (actionText != null) {
      return Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: TextButton(
          onPressed: onActionPressed,
          child: Text(
            actionText!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: actionColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// Pre-configured AppNavigationBar variants for common use cases
class AppNavigationBarVariants {
  /// Simple AppBar with just title
  static AppNavigationBar simple({
    required String title,
    bool centerTitle = true,
  }) {
    return AppNavigationBar(
      title: title,
      centerTitle: centerTitle,
    );
  }

  /// AppBar with save action
  static AppNavigationBar withSave({
    required String title,
    required VoidCallback onSave,
    bool centerTitle = true,
  }) {
    return AppNavigationBar(
      title: title,
      centerTitle: centerTitle,
      showAction: true,
      actionText: 'Save',
      onActionPressed: onSave,
      actionColor: Colors.blue,
    );
  }

  /// AppBar with edit action
  static AppNavigationBar withEdit({
    required String title,
    required VoidCallback onEdit,
    bool centerTitle = true,
  }) {
    return AppNavigationBar(
      title: title,
      centerTitle: centerTitle,
      showAction: true,
      actionIcon: Icons.edit,
      onActionPressed: onEdit,
      actionTooltip: 'Edit',
    );
  }

  /// AppBar with settings action
  static AppNavigationBar withSettings({
    required String title,
    required VoidCallback onSettings,
    bool centerTitle = true,
  }) {
    return AppNavigationBar(
      title: title,
      centerTitle: centerTitle,
      showAction: true,
      actionIcon: Icons.settings,
      onActionPressed: onSettings,
      actionTooltip: 'Settings',
    );
  }

  /// AppBar with logout action
  static AppNavigationBar withLogout({
    required String title,
    required VoidCallback onLogout,
    bool centerTitle = true,
  }) {
    return AppNavigationBar(
      title: title,
      centerTitle: centerTitle,
      showAction: true,
      actionIcon: Icons.logout,
      onActionPressed: onLogout,
      actionColor: Colors.red,
      actionTooltip: 'Logout',
    );
  }

  /// AppBar with custom icon and text
  static AppNavigationBar withCustomAction({
    required String title,
    required String actionText,
    required IconData actionIcon,
    required VoidCallback onActionPressed,
    Color? actionColor,
    bool centerTitle = true,
  }) {
    return AppNavigationBar(
      title: title,
      centerTitle: centerTitle,
      showAction: true,
      actionText: actionText,
      actionIcon: actionIcon,
      onActionPressed: onActionPressed,
      actionColor: actionColor,
    );
  }

  /// AppBar without back button (for root screens)
  static AppNavigationBar root({
    required String title,
    bool centerTitle = true,
    String? actionText,
    IconData? actionIcon,
    VoidCallback? onActionPressed,
    Color? actionColor,
  }) {
    return AppNavigationBar(
      title: title,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      showAction: actionText != null || actionIcon != null,
      actionText: actionText,
      actionIcon: actionIcon,
      onActionPressed: onActionPressed,
      actionColor: actionColor,
    );
  }
} 