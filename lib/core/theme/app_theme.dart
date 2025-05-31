import 'package:flutter/material.dart';

class AppTheme {
  static final colors = _AppColors();

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.primary,
      background: colors.background,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: colors.primary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.secondary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
    ),
  );

  // Colors
  static const Color charcoalBlack = Color(0xFF36454F);
  static const Color primaryColor = Color(0xFF4A90E2); // Example primary color
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: charcoalBlack,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: charcoalBlack,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: charcoalBlack),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: charcoalBlack, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
    );
  }
}

class _AppColors {
  final primary = const Color(0xFF2196F3);
  final secondary = const Color(0xFF757575);
  final background = const Color(0xFFF5F5F5);
  final error = const Color(0xFFD32F2F);
  final success = const Color(0xFF4CAF50);
}