import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF8E3A1F);
  static const Color secondary = Color(0xFFFDF9F0);
  static const Color tertiary = Color(0xFFD97B51);
  static const Color neutral = Color(0xFF2C2826);

  /// Secondary text on light surfaces (meets ~4.5:1 on [secondary] / white for body sizes).
  static const Color mutedOnLight = Color(0xFF4A3F3A);

  /// Hints / placeholders on peach-tinted inputs (stronger than low-alpha brown).
  static const Color hintOnLight = Color(0xFF6B5E59);
}
