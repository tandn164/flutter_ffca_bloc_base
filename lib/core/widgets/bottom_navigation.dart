import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_assets.dart';
import '../utils/color_resource.dart';
import '../utils/widget_util.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  static final height = 60.h;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          color: Colors.black,
          child: SafeArea(
            child: SizedBox(
              height: height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomNavigationItem(
                        svgName: AppAssets.icHome,
                        svgNameSelected: AppAssets.icHome,
                        title: l10n.home,
                        active: currentIndex == 0,
                        onTap: () => onItemSelected(0),
                      ),
                    ),
                    Expanded(
                      child: _BottomNavigationItem(
                        svgName: AppAssets.icProfile,
                        svgNameSelected: AppAssets.icProfileSelected,
                        title: l10n.profile,
                        active: currentIndex == 4,
                        onTap: () => onItemSelected(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    Key? key,
    this.iconData,
    this.svgName,
    this.svgNameSelected,
    this.title,
    this.active = false,
    this.onTap,
  })  : assert(iconData != null || svgName != null),
        super(key: key);

  final IconData? iconData;
  final String? svgName;
  final String? svgNameSelected;
  final String? title;
  final bool active;
  final VoidCallback? onTap;

  bool hasTitle() {
    return title != null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconData != null)
            Icon(
              iconData,
              color: active ? ColorResource.colorF1F1F1 : Colors.white,
            )
          else
            SvgPicture.asset(
              active ? svgNameSelected! : svgName!,
              width: hasTitle() ? 20.w : 35.w,
              height: hasTitle() ? 20.w : 35.w,
            ),
          hasTitle() ? Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Text(title!,
              style: TextStyle(
                  fontSize: 11.sp, color: active ? ColorResource.colorF1F1F1 : Colors.white,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400
              ),),
          ) : Container(),
        ],
      ),
    );
  }
}
