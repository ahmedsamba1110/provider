import 'package:flutter/material.dart';

extension AppColors on ColorScheme {

 
//
  static const Color greenColor = Colors.green;
  static const Color starRatingColor = Color(0xfff4be18);
  static const Color redColor = Colors.red;
  static Color whiteColors = Colors.white;
//theme colors

  static Color lightPrimaryColor = const Color(0xffF2F1F6);
  static Color lightSecondaryColor = const Color(0xffFFFFFF);
  static Color lightAccentColor = const Color(0xff0277FA);
  static Color lightSubHeadingColor1 = const Color(0xff343F53);

  static Color darkPrimaryColor = const Color(0xff1E1E2C);
  static Color darkSecondaryColor = const Color(0xff2A2C3E);
  static Color darkAccentColor = const Color(0xff56A4FB);
  static Color darkSubHeadingColor1 = const Color(0xDDF2F1F6);

  Color get primaryColor => brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor;
  Color get secondaryColor =>
      brightness == Brightness.light ? lightSecondaryColor : darkSecondaryColor;
  Color get accentColor => brightness == Brightness.light ? lightAccentColor : darkAccentColor;
  Color get lightGreyColor => blackColor.withValues(alpha: 0.5);
  Color get blackColor =>
      brightness == Brightness.light ? lightSubHeadingColor1 : darkSubHeadingColor1;

  Color get shimmerBaseColor => brightness == Brightness.light
      ? const Color.fromARGB(255, 225, 225, 225)
      : const Color.fromARGB(255, 150, 150, 150);
  Color get shimmerHighlightColor =>
      brightness == Brightness.light ? Colors.grey.shade100 : Colors.grey.shade300;
  Color get shimmerContentColor => brightness == Brightness.light
      ? Colors.white.withValues(alpha: 0.85)
      : Colors.white.withValues(alpha: 0.7);

  //splashScreen GradientColor
  static Color splashScreenGradientTopColor = const Color(0xff2050D2);
  static Color splashScreenGradientBottomColor = const Color(0xff143386);

}
