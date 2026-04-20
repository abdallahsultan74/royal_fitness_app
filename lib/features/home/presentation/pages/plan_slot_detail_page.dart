import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../plans/data/home_plan_json_slots.dart';
import '../../../workout/presentation/pages/active_exercise_page.dart';

class PlanSlotDetailPage extends StatelessWidget {
  const PlanSlotDetailPage({
    super.key,
    required this.slot,
    this.planTitle,
    this.onOpenWorkoutsTab,
  });

  final HomeTodayPlanSlot slot;
  final String? planTitle;

  /// Prefer passing from [HomePage] so shell tab switch uses a context under [MainShellScope].
  final VoidCallback? onOpenWorkoutsTab;

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final title = slot.displayTitle(lang);
    final body = slot.displayDescription(lang);
    final planLine = (planTitle ?? '').trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      body: RoyalTabScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (planLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  planLine,
                  style: const TextStyle(color: AppColors.accentGold, fontSize: 12),
                ),
              ),
            RoyalGlassPanel(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        slot.done ? Icons.check_circle : Icons.schedule,
                        color: slot.done ? const Color(0xFF66BB6A) : AppColors.accentGold,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          slot.timeLabel.isEmpty ? '—' : slot.timeLabel,
                          style: const TextStyle(
                            color: AppColors.textCream,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      body,
                      style: const TextStyle(color: AppColors.creamDim, fontSize: 14, height: 1.4),
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    Text(
                      'home_plan_slot_detail_hint'.tr(),
                      style: const TextStyle(color: AppColors.creamDim, fontSize: 13, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => ActiveExercisePage(
                      exercises: slot.exercises,
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: AppColors.emeraldDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text('home_plan_slot_start_workout'.tr()),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                final cb = onOpenWorkoutsTab;
                if (cb != null) {
                  cb();
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text('home_plan_slot_open_workouts_tab'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
