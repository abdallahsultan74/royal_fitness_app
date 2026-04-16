import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bottom navigation aligned with [figma/app/components/bottom-nav.tsx].
class RoyalBottomNav extends StatelessWidget {
  const RoyalBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const List<_TabSpec> _tabs = [
    _TabSpec(Icons.home_outlined, Icons.home, 'nav_home'),
    _TabSpec(Icons.fitness_center_outlined, Icons.fitness_center, 'nav_workouts'),
    _TabSpec(Icons.emoji_events_outlined, Icons.emoji_events, 'nav_challenges'),
    _TabSpec(Icons.trending_up, Icons.trending_up, 'nav_progress'),
    _TabSpec(Icons.settings_outlined, Icons.settings, 'nav_settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final inactive = AppColors.textCream.withValues(alpha: 0.4);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(1, 26, 16, 0.88),
                Color.fromRGBO(1, 26, 16, 0.96),
              ],
            ),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottom > 0 ? bottom : 8),
            child: SizedBox(
              height: 72,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_tabs.length, (i) {
                      final tab = _tabs[i];
                      final active = i == currentIndex;
                      return _NavItem(
                        label: tab.labelKey.tr(),
                        active: active,
                        inactiveColor: inactive,
                        icon: active ? tab.iconActive : tab.iconInactive,
                        onTap: () => onSelect(i),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.iconInactive, this.iconActive, this.labelKey);

  final IconData iconInactive;
  final IconData iconActive;
  final String labelKey;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.inactiveColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color inactiveColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accentGold : inactiveColor;

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.accentGold.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (active)
              Container(
                width: 24,
                height: 3,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.goldGlow,
                      blurRadius: 12,
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 7),
            Container(
              width: 40,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.goldDim : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 21,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: active ? 0.5 : 0,
                color: color.withValues(alpha: active ? 1 : 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
