import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/domain/user_profile.dart';
import '../../../workout/data/workout_repository.dart';
import '../../../workout/domain/daily_stat.dart';
import '../utils/home_activity_goals.dart';
import '../widgets/home_activity_rings.dart';

/// Full breakdown of today's rings vs reference goals + recent daily_stats + profile context.
class DailyGoalDetailPage extends StatefulWidget {
  const DailyGoalDetailPage({super.key});

  @override
  State<DailyGoalDetailPage> createState() => _DailyGoalDetailPageState();
}

class _DailyGoalDetailPageState extends State<DailyGoalDetailPage> {
  final WorkoutRepository _workout = WorkoutRepository();
  final ProfileRepository _profile = ProfileRepository();

  @override
  Widget build(BuildContext context) {
    final localeTag = context.locale.toLanguageTag();
    final numberFmt = NumberFormat.decimalPattern(localeTag);

    return Scaffold(
      appBar: AppBar(
        title: Text('home_daily_goal_detail_title'.tr()),
      ),
      body: RoyalTabScaffold(
        child: StreamBuilder<DailyStat>(
          stream: _workout.watchTodayStats(),
          builder: (context, snapToday) {
            final today = snapToday.data ??
                DailyStat(
                  dateKey: _workout.dateKey(),
                  totalMinutes: 0,
                  totalCalories: 0,
                  completedExercises: 0,
                  sessionCount: 0,
                  steps: 0,
                );
            return StreamBuilder<List<DailyStat>>(
              stream: _workout.watchRecentStats(days: 7),
              builder: (context, snapRecent) {
                return StreamBuilder<UserProfile?>(
                  stream: _profile.watchProfile(),
                  builder: (context, snapProf) {
                    final profile = snapProf.data;
                    final recent = snapRecent.data ?? const <DailyStat>[];
                    final outer = HomeActivityGoals.ringCalories(today);
                    final mid = HomeActivityGoals.ringMinutes(today);
                    final inner = HomeActivityGoals.ringSteps(today);
                    final centerPct =
                        (HomeActivityGoals.overallProgress(today) * 100).round();
                    final stepsDisplay = HomeActivityGoals.effectiveSteps(today);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (profile != null) ...[
                          RoyalGlassPanel(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'home_daily_goal_profile_section'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.accentGold,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  profile.name.trim().isEmpty
                                      ? '—'
                                      : profile.name,
                                  style: const TextStyle(
                                    color: AppColors.textCream,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'home_daily_goal_user_goal'.tr(
                                    namedArgs: {'goal': profile.goal},
                                  ),
                                  style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                                ),
                                if (profile.plan.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'home_daily_goal_user_plan'.tr(
                                      namedArgs: {'plan': profile.plan},
                                    ),
                                    style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                                  ),
                                ],
                                if (profile.bmi != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'home_daily_goal_bmi_hint'.tr(
                                      namedArgs: {'bmi': profile.bmi!.toStringAsFixed(1)},
                                    ),
                                    style: const TextStyle(color: AppColors.creamDim, fontSize: 11, height: 1.35),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        RoyalGlassPanel(
                          variant: RoyalGlassVariant.gold,
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              HomeActivityRings(
                                outerFrac: outer,
                                midFrac: mid,
                                innerFrac: inner,
                                centerPercent: centerPct,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'home_daily_goal_detail_subtitle'.tr(),
                                      style: const TextStyle(
                                        color: AppColors.creamDim,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _goalProgressLine(
                                      context,
                                      'home_stat_calories'.tr(),
                                      today.totalCalories,
                                      HomeActivityGoals.dailyCalorieGoal,
                                      const Color(0xFFFF6B6B),
                                    ),
                                    const SizedBox(height: 10),
                                    _goalProgressLine(
                                      context,
                                      'home_stat_exercise'.tr(),
                                      today.totalMinutes,
                                      HomeActivityGoals.dailyMinutesGoal,
                                      AppColors.accentGold,
                                      unit: 'min',
                                    ),
                                    const SizedBox(height: 10),
                                    _goalProgressLine(
                                      context,
                                      'home_stat_steps'.tr(),
                                      stepsDisplay,
                                      HomeActivityGoals.dailyStepsGoal,
                                      const Color(0xFF66BB6A),
                                      formatValue: (v) => numberFmt.format(v),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'home_daily_goal_sessions_hint'.tr(
                                        namedArgs: {
                                          'sessions': '${today.sessionCount}',
                                          'exercises': '${today.completedExercises}',
                                        },
                                      ),
                                      style: const TextStyle(color: AppColors.creamDim, fontSize: 11, height: 1.35),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'home_daily_goal_recent_title'.tr(),
                          style: const TextStyle(
                            color: AppColors.textCream,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (recent.isEmpty)
                          RoyalGlassPanel(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'home_daily_goal_no_history'.tr(),
                              style: const TextStyle(color: AppColors.creamDim, fontSize: 13),
                            ),
                          )
                        else
                          ...recent.reversed.map((d) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: RoyalGlassPanel(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        d.dateKey,
                                        style: const TextStyle(
                                          color: AppColors.textCream,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '${d.totalCalories} kcal · ${d.totalMinutes}m · ${numberFmt.format(HomeActivityGoals.effectiveSteps(d))}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _goalProgressLine(
    BuildContext context,
    String label,
    int current,
    int goal,
    Color color, {
    String unit = '',
    String Function(int)? formatValue,
  }) {
    final frac = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final valStr = formatValue != null ? formatValue(current) : '$current';
    final suffix = unit.isEmpty ? '' : ' $unit';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textCream, fontSize: 13),
              ),
            ),
            Flexible(
              child: Text(
                '$valStr$suffix / $goal$suffix',
                textAlign: TextAlign.end,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.12),
            color: color,
          ),
        ),
      ],
    );
  }
}
