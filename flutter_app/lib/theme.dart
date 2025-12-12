import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color accent = Color(0xFF00B894);
  static final TextTheme textTheme = TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(fontSize: 14),
  );

  static ThemeData get lightTheme => ThemeData(
    primaryColor: primary,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accent),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
