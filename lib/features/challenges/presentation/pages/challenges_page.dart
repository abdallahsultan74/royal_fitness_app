import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';

const String _kChallengeBannerImg =
    'https://images.unsplash.com/photo-1561532325-7d5231a2dede?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';

class _ChallengeRow {
  const _ChallengeRow({
    required this.titleKey,
    required this.days,
    required this.progress,
    required this.participants,
    required this.active,
    this.locked = false,
  });

  final String titleKey;
  final int days;
  final int progress;
  final String participants;
  final bool active;
  final bool locked;
}

const List<_ChallengeRow> _kRows = [
  _ChallengeRow(
    titleKey: 'challenge_row_transform',
    days: 30,
    progress: 40,
    participants: '12.5k',
    active: true,
  ),
  _ChallengeRow(
    titleKey: 'challenge_row_plank',
    days: 14,
    progress: 72,
    participants: '8.3k',
    active: true,
  ),
  _ChallengeRow(
    titleKey: 'challenge_row_cardio',
    days: 21,
    progress: 0,
    participants: '15.1k',
    active: false,
  ),
  _ChallengeRow(
    titleKey: 'challenge_row_flex',
    days: 28,
    progress: 0,
    participants: '6.7k',
    active: false,
    locked: true,
  ),
];

/// Challenges tab (Figma `ChallengesScreen`).
class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoyalTabScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'challenges_title'.tr(),
                  style: const TextStyle(
                    color: AppColors.textCream,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'challenges_subtitle'.tr(),
                  style: const TextStyle(
                    color: AppColors.creamDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 190,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _kChallengeBannerImg,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.obsidian),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.obsidian),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(1, 26, 16, 0.5),
                            Color.fromRGBO(1, 26, 16, 0.95),
                          ],
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: RoyalGoldShimmer(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium,
                                size: 16,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'challenges_active_label'.tr(),
                                style: const TextStyle(
                                  color: AppColors.accentGold,
                                  fontSize: 11,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'challenges_banner_title'.tr(),
                            style: const TextStyle(
                              color: AppColors.textCream,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 11,
                                color: AppColors.creamDim,
                              ),
                              Text(
                                'challenges_banner_day'.tr(),
                                style: const TextStyle(
                                  color: AppColors.creamDim,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.people_outline,
                                size: 11,
                                color: AppColors.creamDim,
                              ),
                              Text(
                                ' 12.5k',
                                style: const TextStyle(
                                  color: AppColors.creamDim,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: const SizedBox(
                                    height: 6,
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
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(
                                                    212,
                                                    175,
                                                    55,
                                                    0.4,
                                                  ),
                                                  blurRadius: 10,
                                                ),
                                              ],
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'challenges_leaderboard'.tr(),
                  style: const TextStyle(
                    color: AppColors.textCream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.accentGold,
                  ),
                  label: Text(
                    'challenges_view_all'.tr(),
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _leaderCard(rank: '🥇', name: 'Ahmed', pts: '2,450', gold: true),
                const SizedBox(width: 12),
                _leaderCard(rank: '🥈', name: 'Sara', pts: '2,180', gold: false),
                const SizedBox(width: 12),
                _leaderCard(rank: '🥉', name: 'Omar', pts: '1,950', gold: false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'challenges_all'.tr(),
              style: const TextStyle(
                color: AppColors.textCream,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: _kRows.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RoyalGlassPanel(
                    variant: c.active && !c.locked
                        ? RoyalGlassVariant.gold
                        : RoyalGlassVariant.standard,
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        if (c.active && !c.locked)
                          const Positioned.fill(
                            child: RoyalGoldShimmer(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                            ),
                          ),
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.locked
                                    ? const Color.fromRGBO(255, 255, 255, 0.05)
                                    : c.active
                                        ? AppColors.goldDim
                                        : const Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            0.05,
                                          ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: c.active && !c.locked
                                      ? AppColors.goldBorder
                                      : AppColors.glassBorder,
                                ),
                              ),
                              child: c.locked
                                  ? const Icon(
                                      Icons.lock_outline,
                                      size: 20,
                                      color: AppColors.creamDim,
                                    )
                                  : c.active
                                      ? const Icon(
                                          Icons.emoji_events,
                                          size: 22,
                                          color: AppColors.accentGold,
                                        )
                                      : const Icon(
                                          Icons.star_outline,
                                          size: 22,
                                          color: AppColors.creamDim,
                                        ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.titleKey.tr(),
                                    style: TextStyle(
                                      color: c.locked
                                          ? AppColors.creamDim
                                          : AppColors.textCream,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 10,
                                        color: AppColors.creamDim,
                                      ),
                                      Text(
                                        ' ${c.days} ${'challenges_days'.tr()}',
                                        style: const TextStyle(
                                          color: AppColors.creamDim,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.people_outline,
                                        size: 10,
                                        color: AppColors.creamDim,
                                      ),
                                      Text(
                                        ' ${c.participants}',
                                        style: const TextStyle(
                                          color: AppColors.creamDim,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (c.active &&
                                      !c.locked &&
                                      c.progress > 0) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            child: SizedBox(
                                              height: 4,
                                              child: ColoredBox(
                                                color: const Color.fromRGBO(
                                                  212,
                                                  175,
                                                  55,
                                                  0.12,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: FractionallySizedBox(
                                                    widthFactor:
                                                        c.progress / 100,
                                                    child: const ColoredBox(
                                                      color:
                                                          AppColors.accentGold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${c.progress}%',
                                          style: const TextStyle(
                                            color: AppColors.accentGold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: c.locked
                                  ? AppColors.creamDim
                                  : AppColors.goldBorder,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _leaderCard({
    required String rank,
    required String name,
    required String pts,
    required bool gold,
  }) {
    return Expanded(
      child: RoyalGlassPanel(
        variant: gold ? RoyalGlassVariant.gold : RoyalGlassVariant.standard,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Stack(
          children: [
            if (gold)
              const Positioned.fill(
                child: RoyalGoldShimmer(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
              ),
            Column(
              children: [
                Text(rank, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    color: gold ? AppColors.accentGold : AppColors.textCream,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$pts pts',
                  style: const TextStyle(
                    color: AppColors.creamDim,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
