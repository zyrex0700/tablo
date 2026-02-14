import 'package:flutter/material.dart';

class AppTheme {
  static const _radius = 15.0;
  static const _brandColor = Color(0xFF2B38D2);

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: _brandColor,
      secondary: _brandColor,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF0F172A),
      error: Color(0xFFDC2626),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'IRANYekan',
      colorScheme: colorScheme,
      primaryColor: _brandColor,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _brandColor,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _brandColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _brandColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }
}
