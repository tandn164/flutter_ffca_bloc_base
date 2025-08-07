import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../screens/global/presentation/blocs/global/global_bloc.dart';
import '../utils/widget_util.dart';

/// Language switcher widget that allows users to change app locale
class LanguageSwitcher extends StatelessWidget {
  final bool showLabel;
  final bool isDropdown;
  
  const LanguageSwitcher({
    super.key,
    this.showLabel = true,
    this.isDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, GlobalState>(
      buildWhen: (previous, current) => previous.locale != current.locale,
      builder: (context, state) {
        if (isDropdown) {
          return _buildDropdown(context, state);
        } else {
          return _buildToggleButtons(context, state);
        }
      },
    );
  }

  Widget _buildDropdown(BuildContext context, GlobalState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: state.locale,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 16.w,
          ),
          dropdownColor: Colors.grey[800],
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          items: _buildDropdownItems(),
          onChanged: (locale) {
            if (locale != null) {
              _changeLocale(context, locale);
            }
          },
        ),
      ),
    );
  }

  Widget _buildToggleButtons(BuildContext context, GlobalState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageButton(
            context: context,
            locale: const Locale('en'),
            label: 'EN',
            isSelected: state.locale?.languageCode == 'en',
          ),
          _buildLanguageButton(
            context: context,
            locale: const Locale('ja'),
            label: 'JA',
            isSelected: state.locale?.languageCode == 'ja',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required BuildContext context,
    required Locale locale,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _changeLocale(context, locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<Locale>> _buildDropdownItems() {
    return [
      DropdownMenuItem(
        value: const Locale('en'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🇺🇸', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            const Text('English'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: const Locale('ja'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🇯🇵', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            const Text('日本語'),
          ],
        ),
      ),
    ];
  }

  void _changeLocale(BuildContext context, Locale locale) {
    context.read<GlobalBloc>().add(ChangeLocaleEvent(locale: locale));
    
    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Language changed to ${locale.languageCode.toUpperCase()}',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

/// Compact language switcher for app bars
class CompactLanguageSwitcher extends StatelessWidget {
  const CompactLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, GlobalState>(
      buildWhen: (previous, current) => previous.locale != current.locale,
      builder: (context, state) {
        return IconButton(
          onPressed: () => _showLanguageBottomSheet(context),
          icon: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              state.locale?.languageCode.toUpperCase() ?? "",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                l10n.selectLanguage,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Language options
            _buildLanguageOption(
              context: context,
              locale: const Locale('en'),
              title: 'English',
              subtitle: 'United States',
              flag: '🇺🇸',
            ),
            _buildLanguageOption(
              context: context,
              locale: const Locale('ja'),
              title: '日本語',
              subtitle: 'Japan',
              flag: '🇯🇵',
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required String title,
    required String subtitle,
    required String flag,
  }) {
    return BlocBuilder<GlobalBloc, GlobalState>(
      builder: (context, state) {
        final isSelected = state.locale?.languageCode == locale.languageCode;
        
        return ListTile(
          leading: Text(flag, style: TextStyle(fontSize: 24.sp)),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 24.w,
                )
              : null,
          onTap: () {
            context.read<GlobalBloc>().add(ChangeLocaleEvent(locale: locale));
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
} 