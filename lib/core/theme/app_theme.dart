import 'package:flutter/material.dart';

class AppTheme {
  static const Color maroon = Color(0xFF800000);
  static const Color darkMaroon = Color(0xFF5D0E11);
  static const Color cream = Colors.white;
  static const Color lightCream = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: maroon,
        primary: maroon,
        secondary: darkMaroon,
        surface: cream,
      ),
      scaffoldBackgroundColor: lightCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: maroon,
        foregroundColor: cream,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: maroon,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: maroon,
        foregroundColor: cream,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: maroon.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: darkMaroon,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: Colors.black87),
      ),
    );
  }
}
