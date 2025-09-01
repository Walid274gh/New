import 'package:flutter/material.dart';

class AppColors {
  // Primary Gradient Colors
  static const Color primaryStart = Color(0xFFFCCBF0);
  static const Color primaryMiddle1 = Color(0xFFFF5A57);
  static const Color primaryMiddle2 = Color(0xFFE02F75);
  static const Color primaryEnd = Color(0xFF6700A3);
  
  // Secondary Colors
  static const Color secondaryDark = Color(0xFF050C38);
  static const Color secondaryLight = Color(0xFF1B2062);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryStart,
      primaryMiddle1,
      primaryMiddle2,
      primaryEnd,
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      secondaryDark,
      secondaryLight,
    ],
  );
}