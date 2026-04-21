import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/royal_feedback.dart';
import '../../../progress/data/progress_repository.dart';
import '../../../plans/data/my_plan_repository.dart';
import '../../../plans/presentation/pages/my_plan_details_page.dart';
import '../../domain/challenge_progress.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';
import 'challenge_details_page.dart';

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
  final MyPlanRepository _planRepository = MyPlanRepository();
  RealtimeChannel? _planAssignmentsChannel;
  late Future<List<MyActivePlan>> _packagePlansFuture;

  @override
  void initState() {
    super.initState();
    _subscribePlanAssignments();
    _packagePlansFuture = _planRepository.fetchMyPackagePlans();
  }

  void _subscribePlanAssignments() {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    _planAssignmentsChannel = Supabase.instance.client
        .channel('challenges-plan-assignments-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'plan_assignments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (_) {
            if (mounted) {
              setState(() {
                _packagePlansFuture = _planRepository.fetchMyPackagePlans();
              });
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    final ch = _planAssignmentsChannel;
    if (ch != null) {
      Supabase.instance.client.removeChannel(ch);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChallengeTemplate>>(
      future: _progressRepository.fetchChallengeTemplates(),
      builder: (context, templatesSnapshot) {
        final templates = templatesSnapshot.data ?? const <ChallengeTemplate>[];
        return FutureBuilder<MyActivePlan?>(
          future: _planRepository.fetchMyActivePlan(),
          builder: (context, planSnapshot) {
            final myPlan = planSnapshot.data;
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
                  if (myPlan != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: RoyalGlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () async {
                            await RoyalFeedback.tap(context);
                            if (!context.mounted) return;
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => MyPlanDetailsPage(plan: myPlan),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'my_plan_title'.tr(),
                                      style: const TextStyle(
                                        color: AppColors.textCream,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: AppColors.creamDim,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                myPlan.title,
                                style: const TextStyle(
                                  color: AppColors.accentGold,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if ((myPlan.description ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  myPlan.description ?? '',
                                  style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                children: [
                                  _meta(Icons.calendar_month, '${myPlan.durationWeeks} ${'weeks'.tr()}'),
                                  _meta(Icons.fitness_center, myPlan.level),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  FutureBuilder<List<MyActivePlan>>(
                    future: _packagePlansFuture,
                    builder: (context, plansSnap) {
                      final plans = plansSnap.data ?? const <MyActivePlan>[];
                      if (plans.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'my_plans_title'.tr(),
                              style: const TextStyle(
                                color: AppColors.creamDim,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...plans.map((p) {
                              final isActive = myPlan?.planId == p.planId;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: RoyalGlassPanel(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () async {
                                      await RoyalFeedback.tap(context);
                                      if (isActive) {
                                        if (!context.mounted) return;
                                        Navigator.of(context).push<void>(
                                          MaterialPageRoute<void>(
                                            builder: (_) => MyPlanDetailsPage(plan: myPlan!),
                                          ),
                                        );
                                        return;
                                      }
                                      try {
                                        await _planRepository.switchToPlan(p.planId);
                                        if (!mounted) return;
                                        setState(() {
                                          _packagePlansFuture = _planRepository.fetchMyPackagePlans();
                                        });
                                      } catch (_) {}
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.title,
                                                style: TextStyle(
                                                  color: isActive ? AppColors.accentGold : AppColors.textCream,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${p.durationWeeks} ${'weeks'.tr()} · ${p.level}',
                                                style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isActive)
                                          const Icon(Icons.check, color: AppColors.accentGold, size: 18)
                                        else
                                          const Icon(Icons.chevron_right, color: AppColors.creamDim, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
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
                              child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                final nav = Navigator.of(context);
                                nav.push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ChallengeDetailsPage(
                                      template: template,
                                      active: activeChallenge,
                                    ),
                                  ),
                                );
                                unawaited(RoyalFeedback.tap(context));
                              },
                              child: Stack(
                                children: [
                                if (isCurrent)
                                  const Positioned.fill(
                                    child: RoyalGoldShimmer(
                                      borderRadius: BorderRadius.all(Radius.circular(24)),
                                    ),
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          if (isCurrent)
                                            TextButton(
                                              onPressed: () => _confirmLeaveChallenge(context),
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(0xFFFF8A80),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                minimumSize: const Size(0, 0),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Text('challenge_leave'.tr()),
                                            ),
                                          TextButton(
                                            onPressed: isCurrent ? null : () => _startChallenge(template),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            child: Text(
                                              isCurrent ? 'challenge_status_active'.tr() : 'challenge_start'.tr(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isCurrent ? AppColors.creamDim : AppColors.accentGold,
                                              ),
                                            ),
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

  Future<void> _confirmLeaveChallenge(BuildContext dialogContext) async {
    final ok = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.emeraldDark,
        title: Text('challenge_leave_title'.tr(), style: const TextStyle(color: AppColors.textCream)),
        content: Text(
          'challenge_leave_confirm'.tr(),
          style: const TextStyle(color: AppColors.creamDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('dialog_cancel'.tr(), style: const TextStyle(color: AppColors.creamDim)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A80),
              foregroundColor: AppColors.emeraldDark,
            ),
            child: Text('challenge_leave'.tr()),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _progressRepository.abandonActiveChallenge();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('challenge_left'.tr())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _startChallenge(ChallengeTemplate template) async {
    await RoyalFeedback.tap(context);
    try {
      await _progressRepository.startChallenge(template.slug);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('challenge_started'.tr())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return;
    }
  }

  Future<void> _completeCurrentDay(ChallengeProgress challenge) async {
    await RoyalFeedback.tap(context);
    try {
      await _progressRepository.completeChallengeDay(challenge.currentDay);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('challenge_day_completed'.tr())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
