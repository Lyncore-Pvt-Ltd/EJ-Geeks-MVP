import 'package:auto_flow/core/theme/app_pallete.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPallete.backgroundColorLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColorLight,
      foregroundColor: Colors.black,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPallete.backgroundColorLight,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.black,
      iconColor: Colors.black,
      selectedColor: AppPallete.nebulousWhite,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    extensions: const [AutoFlowTokens.light],
  );
  static final darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPallete.backgroundColorDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColorDark,
      foregroundColor: AppPallete.cascadingWhite,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppPallete.greyColor),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPallete.tricornBlack,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppPallete.cascadingWhite,
      iconColor: AppPallete.cascadingWhite,
      selectedColor: AppPallete.warmOnyx,
    ),
    iconTheme: const IconThemeData(color: AppPallete.cascadingWhite),
    extensions: const [AutoFlowTokens.dark],
  );
}
