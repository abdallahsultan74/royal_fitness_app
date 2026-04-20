import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/royal_feedback.dart';
import '../../../home/presentation/pages/plan_slot_detail_page.dart';
import '../../../plans/data/home_plan_json_slots.dart';
import '../../../plans/data/my_plan_repository.dart';
import '../../../workout/data/workout_repository.dart';
import '../../../workout/domain/workout_session.dart';
import '../../../workout/domain/workout_session_item.dart';

class DailyWorkoutLogPage extends StatefulWidget {
  const DailyWorkoutLogPage({super.key, required this.day});

  final DateTime day;

  @override
  State<DailyWorkoutLogPage> createState() => _DailyWorkoutLogPageState();
}

class _DailyWorkoutLogPageState extends State<DailyWorkoutLogPage> {
  final WorkoutRepository _repo = WorkoutRepository();
  final MyPlanRepository _planRepo = MyPlanRepository();

  bool _loading = true;
  String? _error;
  List<WorkoutSession> _sessions = const [];
  final Map<String, List<WorkoutSessionItem>> _itemsBySession = {};
  MyActivePlan? _plan;
  List<HomeTodayPlanSlot> _planSlots = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Load assigned plan (if any). Current plan json is slot-based (not per-date),
      // so we show the same slots for any selected day while the assignment is active.
      final plan = await _planRepo.fetchMyActivePlan();
      final slots = parseHomePlanSlotsFromJson(plan?.jsonPlan ?? const <String, dynamic>{});

      final sessions = await _repo.fetchDaySessions(day: widget.day);
      final itemsBy = <String, List<WorkoutSessionItem>>{};
      for (final s in sessions) {
        itemsBy[s.id] = await _repo.fetchSessionItems(sessionId: s.id);
      }
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _planSlots = slots;
        _sessions = sessions;
        _itemsBySession
          ..clear()
          ..addAll(itemsBy);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final title = DateFormat.yMMMMd(lang).format(widget.day);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: RoyalTabScaffold(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.accentGold),
                  ),
                )
              else if (_error != null)
                RoyalGlassPanel(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_planSlots.isNotEmpty) ...[
                      Text(
                        'progress_plan_for_day'.tr(),
                        style: const TextStyle(
                          color: AppColors.textCream,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _planSlots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final slot = _planSlots[i];
                          return RoyalGlassPanel(
                            padding: const EdgeInsets.all(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () async {
                                await RoyalFeedback.tap(context);
                                if (!context.mounted) return;
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PlanSlotDetailPage(
                                      slot: slot,
                                      planTitle: _plan?.title,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: slot.done
                                          ? const Color.fromRGBO(102, 187, 106, 0.12)
                                          : AppColors.goldDim,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.glassBorder),
                                    ),
                                    child: Icon(
                                      slot.done ? Icons.check : Icons.timer,
                                      size: 18,
                                      color: slot.done ? const Color(0xFF66BB6A) : AppColors.accentGold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot.displayTitle(lang),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textCream,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          slot.timeLabel.trim().isEmpty ? '—' : slot.timeLabel.trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, size: 18, color: AppColors.creamDim),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      'progress_workout_log_for_day'.tr(),
                      style: const TextStyle(
                        color: AppColors.textCream,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_sessions.isEmpty)
                      RoyalGlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'progress_no_workout_logs'.tr(),
                          style: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final s = _sessions[i];
                          final items = _itemsBySession[s.id] ?? const [];
                          return _sessionCard(context, s, items);
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessionCard(
    BuildContext context,
    WorkoutSession s,
    List<WorkoutSessionItem> items,
  ) {
    final lang = context.locale.languageCode;
    final start = DateFormat.Hm(lang).format(s.startedAt.toLocal());
    final durMin = (s.durationSec / 60).round();
    final header = '$start • $durMin min • ${s.calories} kcal';
    final totalDone = items.where((e) => e.done).length;

    return RoyalGlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            header,
            style: const TextStyle(
              color: AppColors.accentGold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _pill(Icons.fitness_center, '${s.exerciseCount}'),
              const SizedBox(width: 10),
              _pill(Icons.check_circle_outline, '$totalDone'),
              const Spacer(),
              Text(
                s.completed ? 'progress_session_completed'.tr() : 'progress_session_incomplete'.tr(),
                style: TextStyle(
                  color: s.completed ? const Color(0xFF66BB6A) : AppColors.creamDim,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...items.map((it) {
              final name = (lang == 'ar' && it.exerciseNameAr.trim().isNotEmpty)
                  ? it.exerciseNameAr.trim()
                  : it.exerciseName.trim();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      it.done ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16,
                      color: it.done ? const Color(0xFF66BB6A) : AppColors.creamDim,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textCream, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${it.minutes}m',
                      style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.goldDim,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentGold),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textCream,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

