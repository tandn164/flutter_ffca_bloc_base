import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/color_resource.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton(
      {super.key, required this.title, this.onTap, this.background, this.gradient});

  final String title;
  final Color? background;
  final Gradient? gradient;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (gradient != null) {
      return _buildGradientElevatedButton();
    } else {
      return _buildElevatedButton();
    }
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: background?.withOpacity(0.5) ??
            Colors.white38,
        backgroundColor: background ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      onPressed: onTap,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
              color: onTap != null
                  ? Colors.black
                  : Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildGradientElevatedButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
        ),
        onPressed: onTap,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                color: onTap != null
                    ? Colors.black
                    : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}
