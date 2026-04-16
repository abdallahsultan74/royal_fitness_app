import 'package:flutter/material.dart';

/// Royal Fitness brand palette — emerald, gold, cream on deep green.
/// Extended tokens match [Figma Make] royal-theme.tsx (`C`).
abstract final class AppColors {
  static const Color primaryEmerald = Color(0xFF013220);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF012217);
  static const Color textCream = Color(0xFFF5EAD4);

  /// Bottom of login screen vertical gradient (`#001a10`).
  static const Color emeraldDark = Color(0xFF001A10);

  /// Gold highlight for gradients (`#e6c65c`).
  static const Color goldLight = Color(0xFFE6C65C);

  static const Color obsidian = Color(0xFF0D1117);

  static const Color goldBorder = Color.fromRGBO(212, 175, 55, 0.25);
  static const Color creamDim = Color.fromRGBO(245, 234, 212, 0.55);
  static const Color glassBorder = Color.fromRGBO(212, 175, 55, 0.18);
  static const Color glassOverlay = Color.fromRGBO(1, 50, 32, 0.45);
  static const Color obsidianOverlay = Color.fromRGBO(13, 17, 23, 0.5);
  static const Color goldGlow = Color.fromRGBO(212, 175, 55, 0.35);
  static const Color goldShimmerSoft = Color.fromRGBO(212, 175, 55, 0.1);

  /// Figma `C.goldDim` — subtle gold wash.
  static const Color goldDim = Color.fromRGBO(212, 175, 55, 0.12);
}
