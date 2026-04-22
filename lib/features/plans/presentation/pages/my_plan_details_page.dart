import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/build_config.dart';
import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/royal_feedback.dart';
import '../../../home/presentation/pages/plan_slot_detail_page.dart';
import '../../data/home_plan_json_slots.dart';
import '../../data/my_plan_repository.dart';

class MyPlanDetailsPage extends StatefulWidget {
  const MyPlanDetailsPage({super.key, required this.plan});

  final MyActivePlan plan;

  @override
  State<MyPlanDetailsPage> createState() => _MyPlanDetailsPageState();
}

class _MyPlanDetailsPageState extends State<MyPlanDetailsPage> {
  final MyPlanRepository _repo = MyPlanRepository();
  RealtimeChannel? _planAssignmentsChannel;

  bool _loading = true;
  String? _error;
  MyActivePlan? _plan;
  List<HomeTodayPlanSlot> _slots = const [];

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
    _slots = homePlanSlotsForUi(widget.plan);
    if (BuildConfig.realtimeEnabled) {
      _subscribePlanAssignments();
    }
    _refresh();
  }

  void _subscribePlanAssignments() {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    _planAssignmentsChannel = Supabase.instance.client
        .channel('my-plan-details-assignments-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'plan_assignments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (_) => _refresh(),
        )
        .subscribe();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _repo.fetchMyActivePlan();
      if (!mounted) return;
      setState(() {
        _plan = p ?? _plan;
        _slots = homePlanSlotsForUi(p ?? _plan);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    final lang = context.locale.languageCode;
    final plan = _plan;
    final slots = _slots;

    return Scaffold(
      appBar: AppBar(
        title: Text('my_plan_title'.tr()),
      ),
      body: RoyalTabScaffold(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 22),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentGold,
                    ),
                  ),
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
            else if (plan == null)
              RoyalGlassPanel(
                padding: const EdgeInsets.all(14),
                child: Text(
                  '—',
                  style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                ),
              )
            else
              RoyalGlassPanel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ((plan.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        plan.description!.trim(),
                        style: const TextStyle(
                          color: AppColors.creamDim,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _meta(Icons.calendar_month, '${plan.durationWeeks} ${'weeks'.tr()}'),
                        _meta(Icons.fitness_center, plan.level),
                        if ((plan.status).trim().isNotEmpty) _meta(Icons.verified, plan.status),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Text(
              'home_todays_plan'.tr(),
              style: const TextStyle(
                color: AppColors.textCream,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              itemCount: slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final slot = slots[index];
                final title = slot.displayTitle(lang);
                final subtitle = slot.displayDescription(lang);
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
                            planTitle: plan?.title,
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
                            color: AppColors.goldDim,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Icon(
                            slot.done ? Icons.check_circle : Icons.schedule,
                            color: slot.done
                                ? const Color(0xFF66BB6A)
                                : AppColors.accentGold,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textCream,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (slot.timeLabel.trim().isNotEmpty ||
                                  subtitle.trim().isNotEmpty)
                                Text(
                                  [
                                    if (slot.timeLabel.trim().isNotEmpty)
                                      slot.timeLabel.trim(),
                                    if (subtitle.trim().isNotEmpty)
                                      subtitle.trim(),
                                  ].join(' • '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.creamDim,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            size: 18, color: AppColors.creamDim),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  static Widget _meta(IconData icon, String label) {
    final text = label.trim().isEmpty ? '—' : label.trim();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.creamDim),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
        ),
      ],
    );
  }
}

