import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../progress/data/progress_repository.dart';
import '../../domain/challenge_progress.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';

const String _kChallengeBannerImg =
    'https://images.unsplash.com/photo-1561532325-7d5231a2dede?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';

/// Challenges tab (Figma `ChallengesScreen`).
class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final ProgressRepository _progressRepository = ProgressRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChallengeTemplate>>(
      future: _progressRepository.fetchChallengeTemplates(),
      builder: (context, templatesSnapshot) {
        final templates = templatesSnapshot.data ?? const <ChallengeTemplate>[];
        return StreamBuilder<ChallengeProgress?>(
          stream: _progressRepository.watchActiveChallenge(),
          builder: (context, challengeSnapshot) {
            final activeChallenge = challengeSnapshot.data;
            return RoyalTabScaffold(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
                        height: activeChallenge != null ? 220 : 200,
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
                              padding: const EdgeInsets.all(16),
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
                                        activeChallenge != null
                                            ? 'challenges_active_label'.tr()
                                            : 'challenge_no_active'.tr(),
                                        style: const TextStyle(
                                          color: AppColors.accentGold,
                                          fontSize: 11,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    activeChallenge?.displayTitle(context.locale.languageCode) ??
                                        'challenges_banner_title'.tr(),
                                    style: const TextStyle(
                                      color: AppColors.textCream,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    activeChallenge != null
                                        ? 'challenge_progress_day'.tr(args: [
                                            '${activeChallenge.currentDay}',
                                            '${activeChallenge.daysCount}',
                                          ])
                                        : 'challenge_choose_level'.tr(),
                                    style: const TextStyle(
                                      color: AppColors.creamDim,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(999),
                                          child: SizedBox(
                                            height: 6,
                                            child: ColoredBox(
                                              color: const Color.fromRGBO(212, 175, 55, 0.15),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: FractionallySizedBox(
                                                  widthFactor: ((activeChallenge?.progressPercent ?? 0) / 100).clamp(0, 1),
                                                  child: const DecoratedBox(
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
                                      Text(
                                        '${(activeChallenge?.progressPercent ?? 0).toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: AppColors.accentGold,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (activeChallenge != null) ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: AlignmentDirectional.centerStart,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _completeCurrentDay(activeChallenge),
                                        icon: const Icon(Icons.check_circle_outline),
                                        label: Text('challenge_mark_today_done'.tr()),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          minimumSize: const Size(0, 34),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      children: templates.map((template) {
                        final isCurrent = activeChallenge?.slug == template.slug;
                        final progress = isCurrent ? activeChallenge!.progressPercent.toInt() : 0;
                        final progressFactor = (progress / 100).clamp(0.0, 1.0);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RoyalGlassPanel(
                            variant: isCurrent
                                ? RoyalGlassVariant.gold
                                : RoyalGlassVariant.standard,
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              children: [
                                if (isCurrent)
                                  const Positioned.fill(
                                    child: RoyalGoldShimmer(
                                      borderRadius: BorderRadius.all(Radius.circular(24)),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? AppColors.goldDim
                                            : const Color.fromRGBO(255, 255, 255, 0.05),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isCurrent
                                              ? AppColors.goldBorder
                                              : AppColors.glassBorder,
                                        ),
                                      ),
                                      child: Icon(
                                        isCurrent ? Icons.emoji_events : Icons.star_outline,
                                        size: 22,
                                        color: isCurrent
                                            ? AppColors.accentGold
                                            : AppColors.creamDim,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            template.displayTitle(context.locale.languageCode),
                                            style: const TextStyle(
                                              color: AppColors.textCream,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            template.displayDescription(context.locale.languageCode),
                                            style: const TextStyle(
                                              color: AppColors.creamDim,
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 4,
                                            children: [
                                              _meta(Icons.schedule, '${template.daysCount} ${'challenges_days'.tr()}'),
                                              _meta(Icons.fitness_center, _levelLabel(template.level)),
                                            ],
                                          ),
                                          if (isCurrent) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(999),
                                                    child: SizedBox(
                                                      height: 4,
                                                      child: ColoredBox(
                                                        color: const Color.fromRGBO(212, 175, 55, 0.12),
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: FractionallySizedBox(
                                                            widthFactor: progressFactor,
                                                            child: const ColoredBox(
                                                              color: AppColors.accentGold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '$progress%',
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
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 130),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: AlignmentDirectional.centerEnd,
                                        child: TextButton(
                                          onPressed: isCurrent ? null : () => _startChallenge(template),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          child: Text(
                                            isCurrent ? 'Active' : 'challenge_start'.tr(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isCurrent ? AppColors.creamDim : AppColors.accentGold,
                                            ),
                                          ),
                                        ),
                                      ),
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _meta(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: AppColors.creamDim),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.creamDim,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'advanced':
        return 'challenge_level_advanced'.tr();
      case 'intermediate':
        return 'challenge_level_intermediate'.tr();
      default:
        return 'challenge_level_beginner'.tr();
    }
  }

  Future<void> _startChallenge(ChallengeTemplate template) async {
    await _progressRepository.startChallenge(template.slug);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(template.displayTitle(context.locale.languageCode))),
    );
  }

  Future<void> _completeCurrentDay(ChallengeProgress challenge) async {
    await _progressRepository.completeChallengeDay(challenge.currentDay);
  }
}
