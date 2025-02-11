import 'package:flutter/material.dart';

import 'generalImports.dart';

enum AppTheme { dark, light }

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.light: ThemeData(

    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightPrimaryColor,
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimaryColor,
    secondaryHeaderColor: AppColors.lightSubHeadingColor1,
    fontFamily: 'Lexend',
    // primarySwatch: AppColors.primarySwatchLightColor,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightAccentColor,
      selectionHandleColor: AppColors.lightAccentColor,
      selectionColor: AppColors.lightSecondaryColor,
    ),
  ),
  AppTheme.dark: ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimaryColor,
    secondaryHeaderColor: AppColors.darkSubHeadingColor1,
    scaffoldBackgroundColor: AppColors.darkPrimaryColor,
    // primarySwatch: AppColors.primarySwatchDarkColor,
    fontFamily: 'Lexend',
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkAccentColor,
      selectionHandleColor: AppColors.darkAccentColor,
      selectionColor: AppColors.darkSecondaryColor,
    ),
  )
};
