import 'package:flutter/material.dart';

class AppTheme {
  static final colors = AppColors();

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

class AppColors {
  final primary = const Color(0xFF6200EE);
  final secondary = const Color(0xFF03DAC6);
  final background = const Color(0xFFF5F5F5);
  final surface = Colors.white;
  final error = const Color(0xFFB00020);
  final onPrimary = Colors.white;
  final onSecondary = Colors.black;
  final onBackground = Colors.black;
  final onSurface = Colors.black;
  final onError = Colors.white;
}