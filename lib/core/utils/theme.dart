import 'package:flutter/material.dart';

import 'color_resource.dart';

class CustomTheme {
  static ThemeData mainTheme = ThemeData(
    // Default brightness and colors.
    brightness: Brightness.light,
    primaryColor: ColorResource.color0F0F0F,
    hintColor: Colors.cyan[600],

    // Default font family.
    fontFamily: 'Roboto',

    // Default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and etc.
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: ColorResource.color0F0F0F,
      ),
      bodySmall: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: ColorResource.color0F0F0F,
      ),
      bodyLarge: TextStyle(fontSize: 16.0, color: ColorResource.color0F0F0F),
      bodyMedium: TextStyle(fontSize: 16.0, color: ColorResource.color0F0F0F),
      labelLarge: TextStyle(
        color: ColorResource.colorF1F1F1,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 2,
      ),
    ),
  );
}
