import 'package:size_config/size_config.dart';
import 'package:flutter/material.dart';

// Default application theme definitions
class AppTheme {
  AppTheme._();

  // Light theme configuration
  static ThemeData lightTheme = ThemeData(
    // Default font family
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    // Light theme color scheme
    colorScheme: const ColorScheme.light(
        primary: Color(0xFF635251),
        onPrimary: Colors.white,
        surface: Color(0xFFFAFCFF),
        onSurface: Color(0xDE495759),
        secondary: Color(0xFFFFFFFF),
        onSecondary: Colors.black,
        brightness: Brightness.light,
        tertiary: Color(0xDE495759),
        outline: Colors.white),
    // Text theme configurations
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: const Color(0xDE495759), fontSize: 16.sp),
      bodyMedium: const TextStyle(color: Color(0xDE495759)),
      bodySmall: const TextStyle(color: Color(0x6104294E)),
      titleMedium: const TextStyle(color: Color(0xDE495759)),
    ),
    // App bar theme configurations
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF635251),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  // Dark theme configuration
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
        primary: Color(0xFF795E98),
        surface: Color(0xFF121212),
        onSurface: Color(0xFFE1E1E1),
        secondary: Color(0xFF2C2C2C),
        onSecondary: Color(0xFFE1E1E1),
        tertiary: Color(0xFF9575CD),
        error: Color(0xFFCF6679),
        onError: Color(0xFF000000),
        outline: Color(0xFF3F3F3F)),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE1E1E1), fontSize: 16.sp),
      bodyMedium: const TextStyle(color: Color(0xFFE1E1E1)),
      bodySmall: const TextStyle(color: Color(0xFFB3B3B3)),
      titleLarge: const TextStyle(color: Color(0xFFE1E1E1)),
      titleMedium: const TextStyle(color: Color(0xFFE1E1E1)),
      titleSmall: const TextStyle(color: Color(0xFFB3B3B3)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFE1E1E1),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE1E1E1)),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF2C2C2C),
      elevation: 2,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFE1E1E1),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3F3F3F),
    ),
  );
}

// Soft pastel color theme variant
class SoftPastelTheme {
  SoftPastelTheme._();

  // Light variant of soft pastel theme
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    // Soft pastel light color scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF7DCEA0),
      onPrimary: Colors.white,
      surface: Color(0xFFF9FBF9),
      onSurface: Color(0xFF3D3D3D),
      secondary: Color(0xFFF7DC6F),
      onSecondary: Color(0xFF3D3D3D),
      tertiary: Color(0xFF85C1E9),
      outline: Color(0xFFD5DBDB),
    ),
    // Text styling for light theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF3D3D3D), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0x993D3D3D)),
      bodySmall: TextStyle(color: Color(0x613D3D3D)),
      titleMedium: TextStyle(color: Color(0xFF3D3D3D)),
    ),
    // App bar styling for light theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF7DCEA0),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  // Dark variant of soft pastel theme
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF074A23),
      onPrimary: Colors.white,
      surface: Color(0xFF121212),
      onSurface: Color(0xFFB2BABB),
      secondary: Color(0xFF7DCEA0),
      onSecondary: Colors.white,
      tertiary: Color(0xFFF7DC6F),
      outline: Color(0xFF424242),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFB2BABB), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      bodySmall: TextStyle(color: Color(0xFFFFFFFF)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}

// Modern earthy color theme variant
class ModernEarthyTheme {
  ModernEarthyTheme._();

  // Light variant of earthy theme
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    // Earthy light color scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6C4F3D),
      onPrimary: Colors.white,
      surface: Color(0xFFF4EDE4),
      onSurface: Color(0xFF3E2723),
      secondary: Color(0xFFB58B6C),
      onSecondary: Color(0xFF3E2723),
      tertiary: Color(0xFFD1B9A0),
      outline: Color(0xFFD7CCC8),
    ),
    // Text styling for light theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF3E2723), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0x993E2723)),
      bodySmall: TextStyle(color: Color(0x613E2723)),
    ),
    // App bar styling for light theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6C4F3D),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  // Dark variant of earthy theme
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8E6F54),
      onPrimary: Colors.white,
      surface: Color(0xFF1B1B1B),
      onSurface: Color(0xFFC2BEB8),
      secondary: Color(0xFFB58B6C),
      onSecondary: Colors.white,
      tertiary: Color(0xFFD7CCC8),
      outline: Color(0xFF4E4E4E),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFC2BEB8), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0x99C2BEB8)),
      bodySmall: TextStyle(color: Color(0x61C2BEB8)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}

// Bold vibrant color theme variant
class BoldVibrantTheme {
  BoldVibrantTheme._();

  // Light variant of vibrant theme
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    // Vibrant light color scheme
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF536DFE),
      onPrimary: Colors.white,
      surface: Color(0xFFF5F5F5),
      onSurface: Color(0xFF212121),
      secondary: Color(0xFFFF4081),
      onSecondary: Colors.white,
      tertiary: Color(0xFF00BCD4),
      outline: Color(0xFFB0BEC5),
    ),
    // Text styling for light theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF212121), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0x99212121)),
      bodySmall: TextStyle(color: Color(0x61212121)),
    ),
    // App bar styling for light theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF536DFE),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );

  // Dark variant of vibrant theme
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3D5AFE),
      onPrimary: Colors.white,
      surface: Color(0xFF121212),
      onSurface: Color(0xFFB0BEC5),
      secondary: Color(0xFFFF4081),
      onSecondary: Colors.white,
      tertiary: Color(0xFF00BCD4),
      outline: Color(0xFF37474F),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0x99B0BEC5)),
      bodySmall: TextStyle(color: Color(0x61B0BEC5)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}
