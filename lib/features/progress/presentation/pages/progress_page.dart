import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';
import '../../../challenges/domain/challenge_progress.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/domain/user_profile.dart';
import '../../data/progress_repository.dart';
import '../../domain/weight_log.dart';
import '../../../workout/data/workout_repository.dart';
import '../../../workout/domain/daily_stat.dart';
import 'daily_workout_log_page.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final ProgressRepository _progressRepository = ProgressRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final TextEditingController _weightController = TextEditingController();
  String _chartTab = 'weight';
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Future<List<DailyStat>>? _monthStatsFuture;
  Future<Set<int>>? _monthSessionDaysFuture;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _reloadMonthStats();
  }

  void _reloadMonthStats() {
    _monthStatsFuture = _workoutRepository.fetchMonthStats(
      year: _calendarMonth.year,
      month: _calendarMonth.month,
    );
    _monthSessionDaysFuture = _workoutRepository.fetchMonthSessionDays(
      year: _calendarMonth.year,
      month: _calendarMonth.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile>(
      stream: _profileRepository.watchProfile(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        return StreamBuilder<List<WeightLog>>(
          stream: _progressRepository.watchWeightLogs(limit: 90),
          builder: (context, weightSnapshot) {
            final weightLogs = weightSnapshot.data ?? const <WeightLog>[];
            return StreamBuilder<List<DailyStat>>(
              stream: _workoutRepository.watchRecentStats(days: 30),
              builder: (context, statSnapshot) {
                final stats = statSnapshot.data ?? const <DailyStat>[];
                return StreamBuilder<ChallengeProgress?>(
                  stream: _progressRepository.watchActiveChallenge(),
                  builder: (context, challengeSnapshot) {
                    final activeChallenge = challengeSnapshot.data;
                    return _buildBody(
                      context,
                      profile: profile,
                      weightLogs: weightLogs,
                      stats: stats,
                      activeChallenge: activeChallenge,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required UserProfile? profile,
    required List<WeightLog> weightLogs,
    required List<DailyStat> stats,
    required ChallengeProgress? activeChallenge,
  }) {
    final todayKey = _workoutRepository.dateKey();
    final today = stats.where((e) => e.dateKey == todayKey).fold<DailyStat?>(
          null,
          (prev, e) => e,
        );
    final totalCaloriesMonth = stats.fold<int>(0, (sum, s) => sum + s.totalCalories);
    final totalSessionsMonth = stats.fold<int>(0, (sum, s) => sum + s.sessionCount);
    // Prefer actual logs (timeline) over cached profile current_weight_kg.
    final currentWeight = weightLogs.isNotEmpty ? weightLogs.last.weightKg : profile?.currentWeightKg;
    final streak = _calculateStreak(stats);
    final bmiValue = profile?.bmi;
    final chartWeightLogs = weightLogs.length > 30
        ? weightLogs.sublist(weightLogs.length - 30)
        : weightLogs;
    final showWeeklyReminder = _needsWeeklyWeightReminder(profile, weightLogs);
    final chartSpots = _chartTab == 'weight'
        ? _spotsFromWeightLogs(chartWeightLogs)
        : _spotsFromStats(stats.length <= 7 ? stats : stats.sublist(stats.length - 7), (s) => s.totalCalories);
    final chartLabels = _chartTab == 'weight'
        ? _weightLabels(chartWeightLogs)
        : _dayLabels(stats.length <= 7 ? stats : stats.sublist(stats.length - 7));
    final chartMaxY = _maxY(chartSpots);
    final dayLabels = 'progress_weekday_letters'.tr().split(',');

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
                if (showWeeklyReminder) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(212, 175, 55, 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.45)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_repeat, color: AppColors.accentGold, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'progress_weekly_weight_reminder'.tr(),
                            style: const TextStyle(color: AppColors.textCream, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showLogWeightDialog(context, currentWeight),
                          child: Text(
                            'progress_log_weight'.tr(),
                            style: const TextStyle(color: AppColors.accentGold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  icon: Icons.monitor_weight_outlined,
                  color: const Color(0xFF4FC3F7),
                  value: currentWeight != null ? '${currentWeight.toStringAsFixed(1)}kg' : '--',
                  labelKey: 'progress_stat_weight',
                ),
                const SizedBox(width: 10),
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
                  icon: Icons.favorite_outline,
                  color: const Color(0xFF66BB6A),
                  value: bmiValue?.toStringAsFixed(1) ?? '--',
                  labelKey: 'progress_stat_bmi',
                ),
                const SizedBox(width: 10),
                _statChip(
                  icon: Icons.calendar_today_outlined,
                  color: const Color(0xFF81C784),
                  value: '$streak',
                  labelKey: 'progress_stat_streak',
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
                          children: [
                            Expanded(
                              child: Text(
                                '${'progress_latest_weight'.tr()}: ${currentWeight?.toStringAsFixed(1) ?? '--'}',
                                style: const TextStyle(
                                  color: AppColors.textCream,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showLogWeightDialog(context, currentWeight),
                              child: Text(
                                'progress_log_weight'.tr(),
                                style: const TextStyle(color: AppColors.accentGold),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'progress_weight_history'.tr(),
                          style: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 11,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '$totalCaloriesMonth ${'progress_month_total'.tr()}',
                          style: const TextStyle(
                            color: AppColors.textCream,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$totalSessionsMonth ${'progress_stat_workouts'.tr()}',
                          style: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: (chartSpots.length - 1).toDouble(),
                            minY: 0,
                            maxY: chartMaxY,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTitlesWidget: (value, _) {
                                    final index = value.toInt().clamp(0, chartLabels.length - 1);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        chartLabels[index],
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
                                spots: chartSpots,
                                isCurved: true,
                                color: _chartTab == 'weight'
                                    ? AppColors.accentGold
                                    : const Color(0xFFFF6B6B),
                                barWidth: 2.5,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      (_chartTab == 'weight'
                                              ? AppColors.accentGold
                                              : const Color(0xFFFF6B6B))
                                          .withValues(alpha: 0.18),
                                      (_chartTab == 'weight'
                                              ? AppColors.accentGold
                                              : const Color(0xFFFF6B6B))
                                          .withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_chartTab == 'weight') ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _inlineInfo(
                              '${'progress_height'.tr()}: ${profile?.heightCm?.toStringAsFixed(0) ?? '--'} cm',
                            ),
                            _inlineInfo(
                              '${'progress_target_weight'.tr()}: ${profile?.targetWeightKg?.toStringAsFixed(1) ?? '--'} kg',
                            ),
                            _inlineInfo(
                              'BMI: ${profile?.bmi?.toStringAsFixed(1) ?? '--'} ${_bmiStatusLabel(profile?.bmiStatus)}',
                            ),
                          ],
                        ),
                        if (weightLogs.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'progress_weight_log_list'.tr(),
                              style: const TextStyle(
                                color: AppColors.accentGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...weightLogs.reversed.take(20).map(
                            (log) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat.yMMMd().format(log.loggedAt),
                                    style: const TextStyle(
                                      color: AppColors.creamDim,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${log.weightKg.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                      color: AppColors.textCream,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (activeChallenge != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'progress_active_challenge'.tr(),
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activeChallenge.displayTitle(context.locale.languageCode),
                          style: const TextStyle(
                            color: AppColors.textCream,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'challenge_progress_day'.tr(args: [
                            '${activeChallenge.currentDay}',
                            '${activeChallenge.daysCount}',
                          ]),
                          style: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 6,
                            child: ColoredBox(
                              color: const Color.fromRGBO(212, 175, 55, 0.15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: (activeChallenge.progressPercent / 100).clamp(0, 1),
                                  child: const ColoredBox(color: AppColors.accentGold),
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
            ),
          FutureBuilder<List<DailyStat>>(
            future: _monthStatsFuture,
            builder: (context, monthSnap) {
              if (monthSnap.connectionState == ConnectionState.waiting &&
                  (monthSnap.data == null || monthSnap.data!.isEmpty)) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: CircularProgressIndicator(
                        color: AppColors.accentGold,
                      ),
                    ),
                  ),
                );
              }
              final monthStats = monthSnap.data ?? const <DailyStat>[];
              final monthDaysLocal = _buildCalendarDays(monthStats);
              return FutureBuilder<Set<int>>(
                future: _monthSessionDaysFuture,
                builder: (context, sessionDaysSnap) {
                  final sessionDays = sessionDaysSnap.data ?? const <int>{};
                  return Padding(
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
                                  _calNavBtn(Icons.chevron_left, () {
                                    setState(() {
                                      _calendarMonth = DateTime(
                                        _calendarMonth.year,
                                        _calendarMonth.month - 1,
                                      );
                                      _reloadMonthStats();
                                    });
                                  }),
                                  Text(
                                    DateFormat('MMMM yyyy', context.locale.languageCode)
                                        .format(_calendarMonth),
                                    style: const TextStyle(
                                      color: AppColors.textCream,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  _calNavBtn(Icons.chevron_right, () {
                                    setState(() {
                                      _calendarMonth = DateTime(
                                        _calendarMonth.year,
                                        _calendarMonth.month + 1,
                                      );
                                      _reloadMonthStats();
                                    });
                                  }),
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
                              ...monthDaysLocal.map(
                                (week) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: week.map((day) {
                                      if (day == null) {
                                        return const Expanded(child: SizedBox(height: 38));
                                      }
                                      final date = DateTime(
                                        _calendarMonth.year,
                                        _calendarMonth.month,
                                        day,
                                      );
                                      final now = DateTime.now();
                                      final isToday = now.year == date.year &&
                                          now.month == date.month &&
                                          now.day == date.day;
                                      final isWorkoutDay = sessionDays.contains(day);
                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(12),
                                            onTap: () {
                                              Navigator.of(context).push<void>(
                                                MaterialPageRoute<void>(
                                                  builder: (_) => DailyWorkoutLogPage(day: date),
                                                ),
                                              );
                                            },
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
                                                color: !isToday && isWorkoutDay
                                                    ? AppColors.goldDim
                                                    : Colors.transparent,
                                                border: isWorkoutDay && !isToday
                                                    ? Border.all(color: AppColors.goldBorder)
                                                    : null,
                                              ),
                                              child: Text(
                                                '$day',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isToday
                                                      ? AppColors.emeraldDark
                                                      : isWorkoutDay
                                                          ? AppColors.accentGold
                                                          : AppColors.creamDim,
                                                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showLogWeightDialog(BuildContext context, double? initialWeight) async {
    _weightController.text = initialWeight?.toStringAsFixed(1) ?? '';
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryEmerald,
          title: Text(
            'progress_log_weight'.tr(),
            style: const TextStyle(color: AppColors.textCream),
          ),
          content: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.textCream),
            decoration: InputDecoration(
              hintText: '70.5',
              hintStyle: const TextStyle(color: AppColors.creamDim),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.accentGold),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final weight = double.tryParse(_weightController.text.trim());
                if (weight == null || weight <= 0) return;
                await _progressRepository.logWeight(weight);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: Text(
                'progress_log_weight'.tr(),
                style: const TextStyle(color: AppColors.accentGold),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _needsWeeklyWeightReminder(UserProfile? profile, List<WeightLog> logs) {
    DateTime? newest;
    if (logs.isNotEmpty) {
      newest = logs.last.loggedAt;
    }
    final profileAt = profile?.lastWeightLogAt;
    if (profileAt != null) {
      if (newest == null || profileAt.isAfter(newest)) {
        newest = profileAt;
      }
    }
    if (newest == null) return true;
    return DateTime.now().difference(newest).inDays >= 7;
  }

  int _calculateStreak(List<DailyStat> stats) {
    if (stats.isEmpty) return 0;
    final sorted = [...stats]..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    var streak = 0;
    var expected = DateTime.now();
    for (final stat in sorted) {
      final date = DateTime.tryParse(stat.dateKey);
      if (date == null) continue;
      final normalized = DateTime(date.year, date.month, date.day);
      final expectedNormalized =
          DateTime(expected.year, expected.month, expected.day);
      if (normalized == expectedNormalized &&
          (stat.sessionCount > 0 || stat.completedExercises > 0 || stat.totalMinutes > 0)) {
        streak += 1;
        expected = expected.subtract(const Duration(days: 1));
      }
    }
    return streak;
  }

  List<List<int?>> _buildCalendarDays(List<DailyStat> stats) {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final leading = firstDay.weekday % 7;
    final weeks = <List<int?>>[];
    var week = <int?>[...List<int?>.filled(leading, null)];
    for (var day = 1; day <= daysInMonth; day++) {
      week.add(day);
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

  List<FlSpot> _spotsFromWeightLogs(List<WeightLog> logs) {
    if (logs.isEmpty) {
      return const <FlSpot>[FlSpot(0, 0), FlSpot(1, 0)];
    }
    return List<FlSpot>.generate(
      logs.length,
      (i) => FlSpot(i.toDouble(), logs[i].weightKg),
      growable: false,
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

  List<String> _weightLabels(List<WeightLog> logs) {
    if (logs.isEmpty) return const <String>['-', '-'];
    return logs
        .map((log) => DateFormat('M/d').format(log.loggedAt))
        .toList(growable: false);
  }

  List<String> _dayLabels(List<DailyStat> stats) {
    if (stats.isEmpty) return const <String>['-', '-'];
    return stats
        .map((s) => s.dateKey.split('-').skip(1).join('/'))
        .toList(growable: false);
  }

  double _maxY(List<FlSpot> spots) {
    final max = spots.fold<double>(0, (prev, s) => s.y > prev ? s.y : prev);
    return max <= 0 ? 10 : max + (max * 0.15);
  }

  String _bmiStatusLabel(String? status) {
    switch (status) {
      case 'underweight':
        return 'progress_bmi_status_underweight'.tr();
      case 'normal':
        return 'progress_bmi_status_normal'.tr();
      case 'overweight':
        return 'progress_bmi_status_overweight'.tr();
      case 'obese':
        return 'progress_bmi_status_obese'.tr();
      default:
        return '';
    }
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

  Widget _inlineInfo(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.creamDim,
        fontSize: 11,
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
      width: 98,
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

  Widget _calNavBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
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
