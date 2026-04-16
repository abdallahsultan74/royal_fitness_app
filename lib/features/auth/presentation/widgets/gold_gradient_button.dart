import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'royal_gold_shimmer.dart';

/// Figma `GoldButton` in [figma/app/components/auth-screens.tsx]: 135deg gradient,
/// `rounded-2xl` (16px), py-4, shimmer overlay, letterSpacing 1, text `C.emeraldDark`.
class GoldGradientButton extends StatelessWidget {
  const GoldGradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool disabled;

  static final BorderRadius _radius = BorderRadius.circular(16);

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = disabled ? null : onPressed;

    return ClipRRect(
      borderRadius: _radius,
      child: IntrinsicHeight(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _radius,
                  gradient: disabled
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.accentGold, AppColors.goldLight],
                        ),
                  color: disabled
                      ? const Color.fromRGBO(212, 175, 55, 0.15)
                      : null,
                  boxShadow: disabled
                      ? null
                      : const [
                          BoxShadow(
                            color: AppColors.goldGlow,
                            blurRadius: 32,
                            offset: Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.goldShimmerSoft,
                            blurRadius: 60,
                            offset: Offset.zero,
                          ),
                        ],
                ),
              ),
            ),
            if (!disabled)
              Positioned.fill(
                child: RoyalGoldShimmer(borderRadius: _radius),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: _radius,
                onTap: effectiveOnPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: disabled
                                ? AppColors.textCream.withValues(alpha: 0.3)
                                : AppColors.emeraldDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
