import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/entitlements/coach_content_entitlements.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../challenges/domain/challenge_progress.dart';
import '../../../plans/data/home_plan_json_slots.dart';
import '../../../plans/data/my_plan_repository.dart';
import '../../../profile/domain/user_profile.dart';
import '../../../progress/data/progress_repository.dart';
import '../../../shell/presentation/main_shell.dart';
import '../pages/plan_slot_detail_page.dart';

/// Resolves today's plan rows: admin [json_plan] first, else active challenge day, else static fallback.
class HomeTodaysPlanSection extends StatefulWidget {
  const HomeTodaysPlanSection({
    super.key,
    required this.activeChallenge,
    this.profile,
  });

  final ChallengeProgress? activeChallenge;
  final UserProfile? profile;

  @override
  State<HomeTodaysPlanSection> createState() => _HomeTodaysPlanSectionState();
}

class _HomeTodaysPlanSectionState extends State<HomeTodaysPlanSection> {
  final ProgressRepository _progressRepo = ProgressRepository();
  late Future<_ResolvedPlan> _future;
  RealtimeChannel? _planAssignmentsChannel;

  String _profileEntitlementKey(UserProfile? p) {
    if (p == null) return '';
    return '${p.plan}|${p.planExpiresAt?.toIso8601String() ?? ''}|${jsonEncode(p.featureFlags)}';
  }

  @override
  void initState() {
    super.initState();
    _future = _resolve();
    _subscribePlanAssignments();
  }

  void _subscribePlanAssignments() {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    _planAssignmentsChannel = Supabase.instance.client
        .channel('plan-assignments-$uid')
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
                _future = _resolve();
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
  void didUpdateWidget(covariant HomeTodaysPlanSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final challengeChanged = oldWidget.activeChallenge?.userChallengeId !=
            widget.activeChallenge?.userChallengeId ||
        oldWidget.activeChallenge?.currentDay != widget.activeChallenge?.currentDay;
    final profileChanged =
        _profileEntitlementKey(oldWidget.profile) != _profileEntitlementKey(widget.profile);
    if (challengeChanged || profileChanged) {
      setState(() {
        _future = _resolve();
      });
    }
  }

  Future<_ResolvedPlan> _resolve() async {
    final profile = widget.profile;
    final loadAdminPlan = hasActiveCoachContentAccess(profile) &&
        coachFeatureEnabled(profile, 'admin_plans', defaultWhenAllowed: true);
    final MyActivePlan? plan =
        loadAdminPlan ? await MyPlanRepository().fetchMyActivePlan() : null;
    final fromJson = parseHomePlanSlotsFromJson(plan?.jsonPlan ?? const <String, dynamic>{});
    if (fromJson.isNotEmpty) {
      return _ResolvedPlan(plan: plan, slots: fromJson);
    }
    final active = widget.activeChallenge;
    if (active != null &&
        coachFeatureEnabled(profile, 'challenges', defaultWhenAllowed: true)) {
      final fromChallenge = await _progressRepo.fetchTodayChallengePlanSlots(active);
      if (fromChallenge.isNotEmpty) {
        return _ResolvedPlan(plan: plan, slots: fromChallenge);
      }
    }
    return _ResolvedPlan(plan: plan, slots: defaultFallbackHomePlanSlots());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ResolvedPlan>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold),
              ),
            ),
          );
        }
        final data = snapshot.data!;
        final plan = data.plan;
        final slots = data.slots;
        return Column(
          children: [
            for (var i = 0; i < slots.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _planRow(
                context,
                title: slots[i].displayTitle(context.locale.languageCode),
                time: slots[i].timeLabel,
                done: slots[i].done,
                onTap: () {
                  final shellCtx = context;
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => PlanSlotDetailPage(
                        slot: slots[i],
                        planTitle: plan?.title,
                        onOpenWorkoutsTab: () {
                          Navigator.of(shellCtx).pop();
                          MainShellScope.goToTab(shellCtx, 1);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ResolvedPlan {
  const _ResolvedPlan({required this.plan, required this.slots});

  final MyActivePlan? plan;
  final List<HomeTodayPlanSlot> slots;
}

Widget _planRow(
  BuildContext context, {
  required String title,
  required String time,
  required bool done,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: RoyalGlassPanel(
        borderRadius: 16,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done
                    ? const Color.fromRGBO(102, 187, 106, 0.12)
                    : AppColors.goldDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: done
                      ? const Color.fromRGBO(102, 187, 106, 0.25)
                      : AppColors.goldBorder,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, color: Color(0xFF66BB6A), size: 22)
                  : const Icon(Icons.timer, color: AppColors.accentGold, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: done ? AppColors.creamDim : AppColors.textCream,
                      fontSize: 14,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.creamDim,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.goldBorder, size: 20),
          ],
        ),
      ),
    ),
  );
}
