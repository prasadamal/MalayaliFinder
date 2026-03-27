import 'package:flutter/material.dart';

/// Brand colours for MalayaliFinder.
class AppColors {
  AppColors._();

  // Kerala flag-inspired palette
  static const Color primary = Color(0xFF1B5E20); // Deep Kerala green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF003300);

  static const Color accent = Color(0xFFFF6F00); // Warm saffron/orange
  static const Color accentLight = Color(0xFFFFB300);

  static const Color radar = Color(0xFF00E676); // Radar green
  static const Color radarGlow = Color(0x4400E676);
  static const Color radarRing = Color(0x2200E676);

  static const Color background = Color(0xFF0A1628); // Deep night blue
  static const Color surface = Color(0xFF122140);
  static const Color cardBackground = Color(0xFF1A2F55);

  static const Color textPrimary = Color(0xFFE8F5E9);
  static const Color textSecondary = Color(0xFF90A4AE);
  static const Color textAccent = Color(0xFF69F0AE);

  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFD600);
  static const Color error = Color(0xFFFF1744);
  static const Color info = Color(0xFF0091EA);

  static const Color divider = Color(0xFF263238);

  // Gradient for radar background
  static const List<Color> radarGradient = [
    Color(0xFF0A1628),
    Color(0xFF0D2137),
    Color(0xFF0A1628),
  ];

  // Gradient for cards
  static const List<Color> cardGradient = [
    Color(0xFF1A2F55),
    Color(0xFF122140),
  ];
}
