 import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssets {
  AppAssets._();

  // Base
  static const String baseImg = 'assets/images';
  static const String baseIcon = 'assets/icons';
  static const String baseLottie = 'assets/lottie';

  // Icons
  static const String icHome = '$baseIcon/ic_home.svg';
  static const String icHomeSelected = '$baseIcon/ic_home_selected.svg';
  static const String icProfile = '$baseIcon/ic_profile.svg';
  static const String icProfileSelected = '$baseIcon/ic_profile_selected.svg';
  static const String icLogout = '$baseIcon/ic_logout.svg';
  static const String icEye = '$baseIcon/ic_eye.svg';
  static const String icEyeSlash = '$baseIcon/ic_eye_slash.svg';

  // Image
  static const String icLogo = '$baseImg/logo.png';

  // Animation
  static const String animationLogo = '$baseLottie/logo.json';

  static Future precacheAssets() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    List svgsPaths = (json.decode(manifestJson).keys.where((String key) =>
                key.startsWith(baseIcon) && key.endsWith('.svg'))
            as Iterable)
        .toList();

    for (var svgPath in svgsPaths as List<String>) {
      var loader = SvgAssetLoader(svgPath);
      await svg.cache
          .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }
  }
}
