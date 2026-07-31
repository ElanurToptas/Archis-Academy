import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 142, 56, 139);

  static const Color startButtonBg = Color.fromRGBO(230, 200, 227, 1);
  
  static const Color avatarBg = Color.fromARGB(255, 245, 232, 245);

  static ThemeData get lightTheme {

    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );


    final colorScheme = baseScheme.copyWith(
      primary: primaryColor,
      primaryContainer: startButtonBg,
      onPrimaryContainer: primaryColor,
      secondaryContainer: avatarBg,
      onSecondaryContainer: primaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      
    );
  }
}