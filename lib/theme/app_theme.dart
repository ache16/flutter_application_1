import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF6B5B95);
  static const Color secondaryColor = Color(0xFF88B3C8);
  static const Color accentColor = Color(0xFFFFB6B9);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE57373);
  
  // 背景色
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF16213E);
  
  // 文字色
  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFFB2B2B2);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceLight,
        background: backgroundLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onBackground: textPrimaryLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: _textTheme(Brightness.light),
      appBarTheme: _appBarTheme(Brightness.light),
      cardTheme: _cardTheme(Brightness.light),
      bottomNavigationBarTheme: _bottomNavTheme(Brightness.light),
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      floatingActionButtonTheme: _fabTheme(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceDark,
        background: backgroundDark,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: _appBarTheme(Brightness.dark),
      cardTheme: _cardTheme(Brightness.dark),
      bottomNavigationBarTheme: _bottomNavTheme(Brightness.dark),
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      floatingActionButtonTheme: _fabTheme(),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light 
        ? textPrimaryLight 
        : textPrimaryDark;
    
    return TextTheme(
      displayLarge: GoogleFonts.notoSans(color: color, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.notoSans(color: color, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.notoSans(color: color, fontSize: 24, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.notoSans(color: color, fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.notoSans(color: color, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.notoSans(color: color, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.notoSans(color: color, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.notoSans(color: color, fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.notoSans(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.notoSans(color: color, fontSize: 16),
      bodyMedium: GoogleFonts.notoSans(color: color, fontSize: 14),
      bodySmall: GoogleFonts.notoSans(color: color, fontSize: 12),
    );
  }

  static AppBarTheme _appBarTheme(Brightness brightness) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: brightness == Brightness.light 
          ? backgroundLight 
          : backgroundDark,
      foregroundColor: brightness == Brightness.light 
          ? textPrimaryLight 
          : textPrimaryDark,
    );
  }

  static CardThemeData _cardTheme(Brightness brightness) {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: brightness == Brightness.light 
          ? surfaceLight 
          : surfaceDark,
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme(Brightness brightness) {
    return BottomNavigationBarThemeData(
      backgroundColor: brightness == Brightness.light 
          ? surfaceLight 
          : surfaceDark,
      selectedItemColor: primaryColor,
      unselectedItemColor: brightness == Brightness.light 
          ? textSecondaryLight 
          : textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final borderColor = brightness == Brightness.light 
        ? Colors.grey.shade300 
        : Colors.grey.shade700;
    
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light 
          ? Colors.grey.shade50 
          : surfaceDark.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static FloatingActionButtonThemeData _fabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }
}
