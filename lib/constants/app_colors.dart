import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryPurple = Color(0xFF9D4EDD);
  static const Color secondaryPurple = Color(0xFF7209B7);
  
  // Background Colors
  static const Color darkNavy = Color(0xFF0A0E21);
  static const Color darkBlue = Color(0xFF1A1A2E);
  static const Color mediumBlue = Color(0xFF16213E);
  
  // Accent Colors
  static const Color accentOrange = Colors.orange;
  static const Color accentGreen = Colors.green;
  static const Color accentRed = Colors.red;
  
  // Text Colors
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Colors.white70;
  static const Color textWhite54 = Colors.white54;
  static const Color textWhite38 = Colors.white38;
  
  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryPurple, secondaryPurple],
  );
  
  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkNavy,
      darkBlue,
      mediumBlue.withOpacity(0.8),
    ],
  );
  
  static LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkBlue,
      mediumBlue.withOpacity(0.8),
    ],
  );
  
  static LinearGradient purpleGradientWithOpacity(double opacity) {
    return LinearGradient(
      colors: [
        primaryPurple.withOpacity(opacity),
        secondaryPurple.withOpacity(opacity),
      ],
    );
  }
}

