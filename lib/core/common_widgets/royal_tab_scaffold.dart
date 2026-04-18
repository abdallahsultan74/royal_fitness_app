import 'package:flutter/material.dart';

import '../layout/royal_shell_metrics.dart';
import '../theme/app_colors.dart';
import 'royal_geometric_background.dart';

/// Shared screen chrome for main tabs (Figma screens: gradient + `GeometricBg` + `pb-24`).
class RoyalTabScaffold extends StatelessWidget {
  const RoyalTabScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryEmerald,
                AppColors.emeraldDark,
              ],
            ),
          ),
        ),
        const Positioned.fill(child: RoyalGeometricBackground()),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: RoyalShellMetrics.tabScrollBottomPadding(context),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
