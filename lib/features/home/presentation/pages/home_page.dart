import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';
import '../../../shell/presentation/main_shell.dart';
import '../../../workout/presentation/pages/active_exercise_page.dart';
import '../../presentation/widgets/home_activity_rings.dart';

const String _kChallengeImg =
    'https://images.unsplash.com/photo-1561532325-7d5231a2dede?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';

/// Figma `HomeScreen` — main tab.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return RoyalTabScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home_greeting'.tr(),
                        style: const TextStyle(
                          color: AppColors.creamDim,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'home_welcome_champion'.tr(),
                        style: const TextStyle(
                          color: AppColors.textCream,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    child: RoyalGlassPanel(
                      borderRadius: 16,
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: Icon(
                                Icons.workspace_premium,
                                size: 20,
                                color: AppColors.accentGold,
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryEmerald,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RoyalGlassPanel(
              variant: RoyalGlassVariant.gold,
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: RoyalGoldShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const HomeActivityRings(),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _statRow(
                              context,
                              Icons.local_fire_department,
                              'home_stat_calories'.tr(),
                              '420',
                              'kcal',
                              const Color(0xFFFF6B6B),
                            ),
                            const SizedBox(height: 16),
                            _statRow(
                              context,
                              Icons.timer_outlined,
                              'home_stat_exercise'.tr(),
                              '45',
                              'min',
                              AppColors.accentGold,
                            ),
                            const SizedBox(height: 16),
                            _statRow(
                              context,
                              Icons.bolt,
                              'home_stat_steps'.tr(),
                              '7,842',
                              '',
                              const Color(0xFF66BB6A),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: RoyalGlassPanel(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'home_bmi_label'.tr(),
                          style: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '22.5',
                              style: TextStyle(
                                color: AppColors.textCream,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(102, 187, 106, 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'home_bmi_normal'.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF66BB6A),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: SizedBox(
                            width: 100,
                            height: 12,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 3,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    children: const [
                                      Expanded(
                                        child: ColoredBox(
                                          color: Color(0xFF4FC3F7),
                                          child: SizedBox(height: 6),
                                        ),
                                      ),
                                      Expanded(
                                        child: ColoredBox(
                                          color: Color(0xFF66BB6A),
                                          child: SizedBox(height: 6),
                                        ),
                                      ),
                                      Expanded(
                                        child: ColoredBox(
                                          color: Color(0xFFFFCA28),
                                          child: SizedBox(height: 6),
                                        ),
                                      ),
                                      Expanded(
                                        child: ColoredBox(
                                          color: Color(0xFFFF7043),
                                          child: SizedBox(height: 6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 37,
                                  top: 0,
                                  child: Container(
                                    width: 6,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.textCream,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.primaryEmerald,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            0.3,
                                          ),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'home_bmi_range'.tr(),
                          textAlign: TextAlign.end,
                          maxLines: 3,
                          softWrap: true,
                          style: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 9,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: _kChallengeImg,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.obsidian),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.obsidian),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                          end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                          colors: const [
                            Color.fromRGBO(1, 26, 16, 0.95),
                            Color.fromRGBO(1, 26, 16, 0.4),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 0.7],
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: RoyalGoldShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 14,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'home_royal_challenge'.tr(),
                                style: const TextStyle(
                                  color: AppColors.accentGold,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'home_challenge_title'.tr(),
                            style: const TextStyle(
                              color: AppColors.textCream,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'home_challenge_day'.tr(),
                            style: const TextStyle(
                              color: AppColors.creamDim,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: const SizedBox(
                                    height: 5,
                                    child: ColoredBox(
                                      color: Color.fromRGBO(212, 175, 55, 0.15),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.4,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.accentGold,
                                                  AppColors.goldLight,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '40%',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'home_quick_start'.tr(),
                  style: const TextStyle(
                    color: AppColors.textCream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => MainShellScope.goToTab(context, 1),
                  icon: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.accentGold,
                  ),
                  label: Text(
                    'home_see_all'.tr(),
                    style: const TextStyle(color: AppColors.accentGold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 148,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              children: [
                _quickCard(context, '💪', 'home_quick_full_body', '20', '150'),
                _quickCard(context, '🏋️', 'home_quick_upper', '15', '120'),
                _quickCard(context, '🔥', 'home_quick_core', '10', '90'),
                _quickCard(context, '🦵', 'home_quick_legs', '25', '200'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'home_todays_plan'.tr(),
              style: const TextStyle(
                color: AppColors.textCream,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                _planRow(
                  context,
                  'home_plan_stretch',
                  '7:00 AM',
                  done: true,
                ),
                const SizedBox(height: 8),
                _planRow(
                  context,
                  'home_plan_hiit',
                  '10:00 AM',
                  done: true,
                ),
                const SizedBox(height: 8),
                _planRow(
                  context,
                  'home_plan_yoga',
                  '6:00 PM',
                  done: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(
    BuildContext context,
    String emoji,
    String titleKey,
    String minutes,
    String cal,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const ActiveExercisePage(),
              ),
            );
          },
          child: SizedBox(
            width: 145,
            child: RoyalGlassPanel(
              variant: RoyalGlassVariant.gold,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: RoyalGoldShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 6),
                      Text(
                        titleKey.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textCream,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 10, color: AppColors.creamDim),
                          Text(
                            '${minutes}m',
                            style: const TextStyle(
                              color: AppColors.creamDim,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.local_fire_department,
                            size: 10,
                            color: AppColors.creamDim,
                          ),
                          Text(
                            cal,
                            style: const TextStyle(
                              color: AppColors.creamDim,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _statRow(
    BuildContext context,
    IconData icon,
    String label,
    String val,
    String unit,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    val,
                    style: const TextStyle(
                      color: AppColors.textCream,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        color: AppColors.creamDim,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.creamDim,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _planRow(
    BuildContext context,
    String titleKey,
    String time, {
    required bool done,
  }) {
    return RoyalGlassPanel(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done
                  ? const Color.fromRGBO(102, 187, 106, 0.12)
                  : AppColors.goldDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: done
                    ? const Color.fromRGBO(102, 187, 106, 0.25)
                    : AppColors.goldBorder,
              ),
            ),
            child: done
                ? const Icon(Icons.check, color: Color(0xFF66BB6A), size: 22)
                : const Icon(Icons.timer, color: AppColors.accentGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKey.tr(),
                  style: TextStyle(
                    color: done ? AppColors.creamDim : AppColors.textCream,
                    fontSize: 14,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.creamDim,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.goldBorder, size: 20),
        ],
      ),
    );
  }
}
