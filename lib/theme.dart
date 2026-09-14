import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF1B1E27);
  static const Color panel = Color(0xFF252936);
  static const Color border = Color(0xFF353A47);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF9E9FA5);
  
  static const Color safeGreen = Color(0xFF00FF7F);
  static const Color dangerRed = Color(0xFFFF3366);
  static const Color stopOrange = Color(0xFFFF6600);
  static const Color infoBlue = Color(0xFF00FFFF);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: infoBlue,
      fontFamily: 'Roboto', 
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: primaryText),
        bodySmall: TextStyle(color: secondaryText),
        titleMedium: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
      ),
      colorScheme: const ColorScheme.dark(
        background: background,
        surface: panel,
        primary: infoBlue,
        secondary: safeGreen,
        error: dangerRed,
      ),
    );
  }
}
