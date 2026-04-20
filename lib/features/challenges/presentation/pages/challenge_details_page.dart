import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/royal_feedback.dart';
import '../../../progress/data/progress_repository.dart';
import '../../data/challenges_repository.dart';
import '../../domain/challenge_progress.dart';

class ChallengeDetailsPage extends StatefulWidget {
  const ChallengeDetailsPage({
    super.key,
    required this.template,
    required this.active,
  });

  final ChallengeTemplate template;
  final ChallengeProgress? active;

  @override
  State<ChallengeDetailsPage> createState() => _ChallengeDetailsPageState();
}

class _ChallengeDetailsPageState extends State<ChallengeDetailsPage> {
  final ChallengesRepository _repo = ChallengesRepository();
  final ProgressRepository _progress = ProgressRepository();

  bool _loading = true;
  String? _error;
  ChallengeDetails? _details;

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
      final id = widget.template.id.trim();
      final d = await _repo.fetchChallengeDetails(id);
      if (!mounted) return;
      setState(() {
        _details = d;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final message = raw.contains('INVALID_CHALLENGE_ID')
          ? 'challenge_details_invalid_id'.tr()
          : raw.contains('CHALLENGE_NOT_FOUND')
              ? 'challenge_details_not_found'.tr()
              : 'challenge_details_load_error'.tr();
      setState(() {
        _error = message;
        _loading = false;
      });
    }
  }

  bool get _isActive => widget.active?.slug == widget.template.slug;

  Future<void> _confirmLeave() async {
    final ok = await showDialog<bool>(
      context: context,
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
      await _progress.abandonActiveChallenge();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('challenge_left'.tr())),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _start() async {
    await RoyalFeedback.tap(context);
    try {
      await _progress.startChallenge(widget.template.slug);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('challenge_started'.tr())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final title = widget.template.displayTitle(lang);
    final desc = widget.template.displayDescription(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: RoyalTabScaffold(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RoyalGlassPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.textCream, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(desc, style: const TextStyle(color: AppColors.creamDim, fontSize: 12)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _pill(Icons.schedule, '${widget.template.daysCount} ${'challenges_days'.tr()}'),
                        _pill(Icons.fitness_center, _levelLabel(widget.template.level)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!_isActive)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _start,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: AppColors.emeraldDark,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('challenge_start'.tr()),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.accentGold, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'challenge_status_active'.tr(),
                                  style: const TextStyle(color: AppColors.textCream, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _confirmLeave,
                            icon: const Icon(Icons.logout, size: 18, color: Color(0xFFFF8A80)),
                            label: Text('challenge_leave'.tr(), style: const TextStyle(color: Color(0xFFFF8A80))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0x66FF8A80)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.accentGold)))
              else if (_error != null)
                RoyalGlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.35),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: Text('retry'.tr()),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.emeraldDark,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...[
                  Text('challenge_days_title'.tr(), style: const TextStyle(color: AppColors.textCream, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...((_details?.days ?? const <ChallengeDayItem>[]).map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RoyalGlassPanel(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.goldDim,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Text('${d.dayNumber}', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (lang == 'ar' ? d.titleAr : d.title).trim().isEmpty ? '${'Day'.tr()} ${d.dayNumber}' : (lang == 'ar' ? d.titleAr : d.title),
                                      style: const TextStyle(color: AppColors.textCream, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 4,
                                      children: [
                                        _meta(Icons.timer, '${d.targetMinutes}m'),
                                        _meta(Icons.fitness_center, '${d.targetExercises}'),
                                        _meta(Icons.local_fire_department, '${d.targetCalories}'),
                                      ],
                                    ),
                                    if (((lang == 'ar' ? d.notesAr : d.notes) ?? '').trim().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        (lang == 'ar' ? d.notesAr : d.notes) ?? '',
                                        style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentGold),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textCream, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.creamDim),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.creamDim, fontSize: 11)),
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
}

