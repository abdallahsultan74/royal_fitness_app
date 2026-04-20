import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/domain/user_profile.dart';

class HealthReportsPage extends StatefulWidget {
  const HealthReportsPage({super.key});

  @override
  State<HealthReportsPage> createState() => _HealthReportsPageState();
}

class _HealthReportsPageState extends State<HealthReportsPage> {
  final _profileRepo = ProfileRepository();

  Future<List<Map<String, dynamic>>> _fetchDailyStats(int days) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return const [];
    final from = DateTime.now().toUtc().subtract(Duration(days: days - 1));
    final fromKey =
        '${from.year.toString().padLeft(4, '0')}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
    final rows = await Supabase.instance.client
        .from('daily_stats')
        .select('date_key,total_minutes,total_calories,session_count,steps')
        .eq('user_id', uid)
        .gte('date_key', fromKey)
        .order('date_key', ascending: true);
    return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final localeTag = context.locale.toLanguageTag();
    final nf = NumberFormat.decimalPattern(localeTag);

    return StreamBuilder<UserProfile>(
      stream: _profileRepo.watchProfile(),
      builder: (context, snap) {
        final p = snap.data;
        final bmi = p?.bmi;
        final bmiText = bmi != null ? bmi.toStringAsFixed(1) : '--';
        final weightText =
            p?.currentWeightKg != null ? p!.currentWeightKg!.toStringAsFixed(1) : '--';
        final targetText =
            p?.targetWeightKg != null ? p!.targetWeightKg!.toStringAsFixed(1) : '--';

        return RoyalTabScaffold(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.accentGold,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop<void>(),
                    ),
                    Expanded(
                      child: Text(
                        'settings_health_data'.tr(),
                        style: const TextStyle(
                          color: AppColors.textCream,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'health_reports_subtitle'.tr(),
                  style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _miniCard(
                        label: 'progress_stat_bmi'.tr(),
                        value: bmiText,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniCard(
                        label: 'health_reports_weight'.tr(),
                        value: '$weightText kg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniCard(
                        label: 'health_reports_target'.tr(),
                        value: '$targetText kg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchDailyStats(14),
                  builder: (context, statsSnap) {
                    if (statsSnap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.accentGold),
                        ),
                      );
                    }
                    final rows = statsSnap.data ?? const [];
                    final points = <FlSpot>[];
                    for (var i = 0; i < rows.length; i++) {
                      final m = rows[i];
                      final min = (m['total_minutes'] as num? ?? 0).toDouble();
                      points.add(FlSpot(i.toDouble(), min));
                    }

                    final totalMinutes = rows.fold<int>(
                      0,
                      (acc, r) => acc + (r['total_minutes'] as num? ?? 0).toInt(),
                    );
                    final totalCalories = rows.fold<int>(
                      0,
                      (acc, r) => acc + (r['total_calories'] as num? ?? 0).toInt(),
                    );
                    final totalSessions = rows.fold<int>(
                      0,
                      (acc, r) => acc + (r['session_count'] as num? ?? 0).toInt(),
                    );
                    final totalSteps = rows.fold<int>(
                      0,
                      (acc, r) => acc + (r['steps'] as num? ?? 0).toInt(),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionTitle('health_reports_activity_14d'.tr()),
                        const SizedBox(height: 10),
                        _totalsRow(
                          minutes: nf.format(totalMinutes),
                          calories: nf.format(totalCalories),
                          sessions: nf.format(totalSessions),
                          steps: nf.format(totalSteps),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                            color: const Color.fromRGBO(0, 0, 0, 0.15),
                          ),
                          child: SizedBox(
                            height: 180,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: points,
                                    isCurved: true,
                                    color: AppColors.accentGold,
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color.fromRGBO(212, 175, 55, 0.12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _sectionTitle('health_reports_reports'.tr()),
                        const SizedBox(height: 10),
                        _reportTile(
                          icon: Icons.insights,
                          title: 'health_reports_weekly_summary'.tr(),
                          subtitle: 'health_reports_weekly_summary_desc'.tr(),
                        ),
                        _reportTile(
                          icon: Icons.favorite_outline,
                          title: 'health_reports_bmi_trends'.tr(),
                          subtitle: 'health_reports_bmi_trends_desc'.tr(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.creamDim,
        fontSize: 11,
        letterSpacing: 1,
      ),
    );
  }

  Widget _miniCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        color: const Color.fromRGBO(0, 0, 0, 0.15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.creamDim, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textCream,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalsRow({
    required String minutes,
    required String calories,
    required String sessions,
    required String steps,
  }) {
    Widget cell(String label, String value, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
            color: const Color.fromRGBO(0, 0, 0, 0.15),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.accentGold),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: AppColors.creamDim, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(color: AppColors.textCream, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        cell('home_stat_exercise'.tr(), minutes, Icons.timer_outlined),
        const SizedBox(width: 10),
        cell('home_stat_calories'.tr(), calories, Icons.local_fire_department),
        const SizedBox(width: 10),
        cell('health_reports_sessions'.tr(), sessions, Icons.fitness_center),
        const SizedBox(width: 10),
        cell('home_stat_steps'.tr(), steps, Icons.bolt),
      ],
    );
  }

  Widget _reportTile({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          color: const Color.fromRGBO(0, 0, 0, 0.15),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(icon, size: 18, color: AppColors.accentGold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: AppColors.textCream, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.creamDim, fontSize: 11, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

