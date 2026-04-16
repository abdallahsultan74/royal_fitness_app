import 'package:flutter/material.dart';

/// Bottom spacing for tab scroll content above [RoyalBottomNav] (Figma `pb-24` + nav height).
abstract final class RoyalShellMetrics {
  static double tabScrollBottomPadding(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    return 72 + (safe > 0 ? safe : 8) + 16;
  }
}
