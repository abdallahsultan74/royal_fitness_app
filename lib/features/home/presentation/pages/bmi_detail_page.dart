import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/domain/user_profile.dart';
import '../utils/home_bmi_ui.dart';

class BmiDetailPage extends StatelessWidget {
  const BmiDetailPage({super.key, required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final p = profile;

    return Scaffold(
      appBar: AppBar(
        title: Text('home_bmi_detail_title'.tr()),
      ),
      body: RoyalTabScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (p == null)
              RoyalGlassPanel(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'home_bmi_detail_no_profile'.tr(),
                  style: const TextStyle(color: AppColors.creamDim, fontSize: 14),
                ),
              )
            else ...[
              RoyalGlassPanel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home_bmi_detail_identity'.tr(),
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.name.trim().isEmpty ? '—' : p.name,
                      style: const TextStyle(
                        color: AppColors.textCream,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'home_daily_goal_user_goal'.tr(namedArgs: {'goal': p.goal}),
                      style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                    ),
                    if (p.plan.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'home_daily_goal_user_plan'.tr(namedArgs: {'plan': p.plan}),
                        style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                      ),
                    ],
                    if (p.lastWeightLogAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'home_bmi_last_weight_log'.tr(
                          namedArgs: {
                            'date': MaterialLocalizations.of(context).formatShortDate(p.lastWeightLogAt!),
                          },
                        ),
                        style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RoyalGlassPanel(
                padding: const EdgeInsets.all(18),
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
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p.bmi != null ? p.bmi!.toStringAsFixed(1) : '--',
                          style: const TextStyle(
                            color: AppColors.textCream,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(102, 187, 106, 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            homeBmiStatusLabel(p.bmiStatus),
                            style: TextStyle(
                              color: _bmiBadgeColor(p.bmiStatus),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 14,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final barW = constraints.maxWidth;
                          final thumb = homeBmiMarkerFraction(p.bmi) * (barW - 6).clamp(0.0, barW - 6);
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 4,
                                left: 0,
                                right: 0,
                                child: Row(
                                  children: const [
                                    Expanded(child: ColoredBox(color: Color(0xFF4FC3F7), child: SizedBox(height: 6))),
                                    Expanded(child: ColoredBox(color: Color(0xFF66BB6A), child: SizedBox(height: 6))),
                                    Expanded(child: ColoredBox(color: Color(0xFFFFCA28), child: SizedBox(height: 6))),
                                    Expanded(child: ColoredBox(color: Color(0xFFFF7043), child: SizedBox(height: 6))),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: thumb,
                                top: 0,
                                child: Container(
                                  width: 6,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppColors.textCream,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppColors.primaryEmerald),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _metricRow('home_bmi_detail_height'.tr(), p.heightCm != null ? '${p.heightCm} cm' : '—'),
                    _metricRow('home_bmi_detail_current_weight'.tr(),
                        p.currentWeightKg != null ? '${p.currentWeightKg} kg' : '—'),
                    _metricRow('home_bmi_detail_target_weight'.tr(),
                        p.targetWeightKg != null ? '${p.targetWeightKg} kg' : '—'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RoyalGlassPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home_bmi_detail_ranges_title'.tr(),
                      style: const TextStyle(
                        color: AppColors.textCream,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'home_bmi_range'.tr(),
                      style: const TextStyle(color: AppColors.creamDim, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'home_bmi_detail_explain'.tr(),
                      style: const TextStyle(color: AppColors.creamDim, fontSize: 13, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _bmiBadgeColor(String? status) {
    final x = (status ?? '').toLowerCase();
    if (x == 'normal') return const Color(0xFF66BB6A);
    if (x == 'underweight') return const Color(0xFF4FC3F7);
    if (x == 'overweight') return const Color(0xFFFFCA28);
    if (x == 'obese') return const Color(0xFFFF7043);
    return const Color(0xFF66BB6A);
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.creamDim, fontSize: 13)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textCream,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
