import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workout/data/workout_repository.dart';
import '../../../workout/domain/daily_stat.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';

/// Progress tab (Figma `ProgressTracker`).
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  String _chartTab = 'weight';

  static const Set<int> _streakDays = {1, 2, 3, 5, 6, 7, 8, 9, 10, 12};
  static const int _today = 12;
  static const int _daysInMonth = 30;
  static const int _startDay = 3;

  List<List<int?>> _weeks() {
    final weeks = <List<int?>>[];
    var week = <int?>[...List<int?>.filled(_startDay, null)];
    for (var d = 1; d <= _daysInMonth; d++) {
      week.add(d);
      if (week.length == 7) {
        weeks.add(week);
        week = <int?>[];
      }
    }
    if (week.isNotEmpty) {
      while (week.length < 7) {
        week.add(null);
      }
      weeks.add(week);
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _weeks();
    final dayLabels = 'progress_weekday_letters'.tr().split(',');
    final todayKey = _workoutRepository.dateKey();

    return StreamBuilder<List<DailyStat>>(
      stream: _workoutRepository.watchRecentStats(days: 30),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? const <DailyStat>[];
        final today = stats.where((e) => e.dateKey == todayKey).fold<DailyStat?>(
          null,
          (prev, e) => e,
        );
        final recent8 = (stats.length <= 8 ? stats : stats.sublist(stats.length - 8));
        final recent7 = (stats.length <= 7 ? stats : stats.sublist(stats.length - 7));
        final exerciseSpots = _spotsFromStats(recent8, (s) => s.completedExercises);
        final calorieSpots = _spotsFromStats(recent7, (s) => s.totalCalories);
        final chartMaxY = _maxY(exerciseSpots);
        final calMaxY = _maxY(calorieSpots);
        final totalCaloriesMonth = stats.fold<int>(0, (sum, s) => sum + s.totalCalories);
        final totalSessionsMonth = stats.fold<int>(0, (sum, s) => sum + s.sessionCount);

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
                  'progress_title'.tr(),
                  style: const TextStyle(
                    color: AppColors.textCream,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'progress_subtitle'.tr(),
                  style: const TextStyle(
                    color: AppColors.creamDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 104,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _statChip(
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFFF6B6B),
                  value: '${today?.totalCalories ?? 0}',
                  labelKey: 'progress_stat_calories',
                ),
                const SizedBox(width: 10),
                _statChip(
                  icon: Icons.emoji_events_outlined,
                  color: AppColors.accentGold,
                  value: '${today?.completedExercises ?? 0}',
                  labelKey: 'progress_stat_workouts',
                ),
                const SizedBox(width: 10),
                _statChip(
                  icon: Icons.calendar_today_outlined,
                  color: const Color(0xFF66BB6A),
                  value: '${today?.sessionCount ?? 0}',
                  labelKey: 'progress_stat_streak',
                ),
                const SizedBox(width: 10),
                _statChip(
                  icon: Icons.trending_down,
                  color: const Color(0xFF4FC3F7),
                  value: '${today?.totalMinutes ?? 0}m',
                  labelKey: 'progress_stat_lost',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: RoyalGlassPanel(
              variant: RoyalGlassVariant.gold,
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: RoyalGoldShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _chartTabButton('weight', 'progress_tab_weight'),
                          const SizedBox(width: 8),
                          _chartTabButton('calories', 'progress_tab_calories'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_chartTab == 'weight') ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$totalSessionsMonth ${'progress_stat_workouts'.tr()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.textCream,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${today?.completedExercises ?? 0} ${'progress_this_week'.tr()}',
                              style: TextStyle(
                                color: const Color(0xFF66BB6A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'progress_last_8_weeks'.tr(),
                          style: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 140,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: (exerciseSpots.length - 1).toDouble(),
                              minY: 0,
                              maxY: chartMaxY,
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    getTitlesWidget: (v, _) {
                                      final labels = _dayLabels(recent8, context);
                                      final i = v.toInt().clamp(0, labels.length - 1);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          labels[i],
                                          style: const TextStyle(
                                            color: AppColors.creamDim,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: exerciseSpots,
                                  isCurved: true,
                                  color: AppColors.accentGold,
                                  barWidth: 2.5,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.accentGold
                                            .withValues(alpha: 0.25),
                                        AppColors.accentGold
                                            .withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$totalCaloriesMonth',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.textCream,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'kcal ${'progress_this_week'.tr()}',
                              style: const TextStyle(
                                color: AppColors.creamDim,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'progress_daily_breakdown'.tr(),
                          style: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 140,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: (calorieSpots.length - 1).toDouble(),
                              minY: 0,
                              maxY: calMaxY,
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    getTitlesWidget: (v, _) {
                                      final labels = _dayLabels(recent7, context);
                                      final i = v.toInt().clamp(0, labels.length - 1);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          labels[i],
                                          style: const TextStyle(
                                            color: AppColors.creamDim,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: calorieSpots,
                                  isCurved: true,
                                  color: const Color(0xFFFF6B6B),
                                  barWidth: 2.5,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: RoyalGlassPanel(
              variant: RoyalGlassVariant.gold,
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: RoyalGoldShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _calNavBtn(Icons.chevron_left),
                          Text(
                            'progress_calendar_month'.tr(),
                            style: const TextStyle(
                              color: AppColors.textCream,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _calNavBtn(Icons.chevron_right),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: dayLabels
                            .map(
                              (d) => Expanded(
                                child: Text(
                                  d.trim(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.creamDim,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      ...weeks.map(
                        (wk) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: wk.map((day) {
                              if (day == null) {
                                return const Expanded(child: SizedBox(height: 38));
                              }
                              final isStreak = _streakDays.contains(day);
                              final isToday = day == _today;
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: Container(
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: isToday
                                          ? const LinearGradient(
                                              colors: [
                                                AppColors.accentGold,
                                                AppColors.goldLight,
                                              ],
                                            )
                                          : null,
                                      color: !isToday && isStreak
                                          ? AppColors.goldDim
                                          : (!isToday && !isStreak
                                              ? Colors.transparent
                                              : null),
                                      border: isStreak && !isToday
                                          ? Border.all(
                                              color: AppColors.goldBorder,
                                            )
                                          : isToday
                                              ? null
                                              : null,
                                      boxShadow: isToday
                                          ? const [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                  212,
                                                  175,
                                                  55,
                                                  0.4,
                                                ),
                                                blurRadius: 16,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isToday
                                            ? AppColors.emeraldDark
                                            : isStreak
                                                ? AppColors.accentGold
                                                : AppColors.creamDim,
                                        fontWeight: isToday
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.accentGold,
                                      AppColors.goldLight,
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'progress_legend_today'.tr(),
                                style: const TextStyle(
                                  color: AppColors.creamDim,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.goldDim,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.goldBorder,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'progress_legend_workout'.tr(),
                                style: const TextStyle(
                                  color: AppColors.creamDim,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      );
      },
    );
  }

  List<FlSpot> _spotsFromStats(
    List<DailyStat> stats,
    int Function(DailyStat stat) valueGetter,
  ) {
    if (stats.isEmpty) {
      return const <FlSpot>[FlSpot(0, 0), FlSpot(1, 0)];
    }
    return List<FlSpot>.generate(
      stats.length,
      (i) => FlSpot(i.toDouble(), valueGetter(stats[i]).toDouble()),
      growable: false,
    );
  }

  List<String> _dayLabels(List<DailyStat> stats, BuildContext context) {
    if (stats.isEmpty) return const <String>['-', '-'];
    return stats
        .map((s) => s.dateKey.split('-').skip(1).join('/'))
        .toList(growable: false);
  }

  double _maxY(List<FlSpot> spots) {
    final max = spots.fold<double>(0, (prev, s) => s.y > prev ? s.y : prev);
    return max <= 0 ? 10 : max + (max * 0.2);
  }

  Widget _chartTabButton(String key, String labelKey) {
    final on = _chartTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _chartTab = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: on ? AppColors.goldDim : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: on ? AppColors.goldBorder : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            labelKey.tr(),
            style: TextStyle(
              color: on ? AppColors.accentGold : AppColors.creamDim,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _statChip({
    required IconData icon,
    required Color color,
    required String value,
    required String labelKey,
  }) {
    return SizedBox(
      width: 92,
      child: RoyalGlassPanel(
        variant: RoyalGlassVariant.gold,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textCream,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              labelKey.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.creamDim,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calNavBtn(IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.goldDim,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.accentGold),
        ),
      ),
    );
  }
}
