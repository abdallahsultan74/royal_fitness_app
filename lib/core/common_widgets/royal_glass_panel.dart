import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Figma `glassCard` / `glassCardGold` from [figma/app/components/royal-theme.tsx].
class RoyalGlassPanel extends StatelessWidget {
  const RoyalGlassPanel({
    super.key,
    required this.child,
    this.variant = RoyalGlassVariant.standard,
    this.borderRadius = 24,
    this.padding,
  });

  final Widget child;
  final RoyalGlassVariant variant;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final isGold = variant == RoyalGlassVariant.gold;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glassOverlay,
                AppColors.obsidianOverlay,
              ],
            ),
            border: Border.all(
              color: isGold ? AppColors.goldBorder : AppColors.glassBorder,
            ),
            boxShadow: isGold
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(212, 175, 55, 0.06),
                      blurRadius: 30,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

enum RoyalGlassVariant { standard, gold }
