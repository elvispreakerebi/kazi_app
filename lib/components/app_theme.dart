import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF155689); // Primary blue
  static const Color secondary = Color(0xFFF4F4F5); // Light gray
  static const Color destructive = Color(0xFFDC2626); // Red
  static const Color outline = Color(0xFFE4E4E7); // Outline
  static const Color textDark = Color(0xFF18181B); // Main dark text
  static const Color white = Colors.white;
  static const Color foreground = Color(0xFF18181B);
  static const Color popoverForeground = Color(0xFF09090B);
  static const Color baseMuted = Color(0xFFF4F4F5);

  // Border radii
  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0;
  static const double radiusDefault = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;

  // Box shadows
  static const List<BoxShadow> shadowNone = [];
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ), // very subtle
  ];
  static const List<BoxShadow> shadowBase = [
    BoxShadow(color: Color(0x19000000), blurRadius: 4, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> shadowXl = [
    BoxShadow(color: Color(0x44000000), blurRadius: 24, offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> shadow2Xl = [
    BoxShadow(color: Color(0x55000000), blurRadius: 32, offset: Offset(0, 16)),
  ];
}
