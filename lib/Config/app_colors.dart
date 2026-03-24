import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Brand palette (from your UI)
  static const Color primary = Color(0xFF6B4F3B); // #6B4F3B
  static const Color secondary = Color(0xFF2F6D4F); // #2F6D4F
  static const Color background = Color(0xFFFAF6F0); // #FAF6F0
  static const Color text = Color(0xFF3E2C23); // #3E2C23

  /// Common UI helpers (optional but useful)
  static const Color surface = Colors.white;
  static const Color bordor = Colors.black;

  static const Color danger = Colors.redAccent;
  static const Color success = secondary;
}