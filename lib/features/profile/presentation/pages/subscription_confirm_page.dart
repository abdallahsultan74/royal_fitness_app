import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/data/notifications_repository.dart';

enum SubscriptionRequestKind { activate, renew }

class CoachRecipient {
  const CoachRecipient({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}

class SubscriptionConfirmPage extends StatefulWidget {
  const SubscriptionConfirmPage({
    super.key,
    required this.kind,
    this.planKey = 'pro',
    this.durationDays = 30,
  });

  final SubscriptionRequestKind kind;
  final String planKey;
  final int durationDays;

  @override
  State<SubscriptionConfirmPage> createState() => _SubscriptionConfirmPageState();
}

class _SubscriptionConfirmPageState extends State<SubscriptionConfirmPage> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  int? _priceCents;
  String _currency = 'EGP';
  String _coachName = '—';
  List<CoachRecipient> _coaches = const [];
  String? _selectedCoachId;

  SupabaseClient get _client => Supabase.instance.client;

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
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw Exception('not_authenticated');

      // 0) List coaches (from RPC that can bypass RLS).
      final staff = await NotificationsRepository().listStaffRecipients();
      final coaches = staff
          .where((r) => (r['role']?.toString() ?? '').toLowerCase() == 'coach')
          .map((r) => CoachRecipient(
                id: r['id']?.toString() ?? '',
                name: (r['name']?.toString() ?? '').trim().isEmpty
                    ? '—'
                    : r['name']?.toString() ?? '—',
                email: r['email']?.toString() ?? '',
              ))
          .where((c) => c.id.isNotEmpty)
          .toList(growable: false);
      _coaches = coaches;

      // 1) Price from subscription_plan_prices (active).
      final priceResp = await _client
          .from('subscription_plan_prices')
          .select('price_cents,currency')
          .eq('active', true)
          .eq('plan_key', widget.planKey)
          .eq('duration_days', widget.durationDays)
          .order('updated_at', ascending: false)
          .limit(1);
      if (priceResp.isNotEmpty) {
        final m = Map<String, dynamic>.from(priceResp.first as Map);
        _priceCents = (m['price_cents'] as num?)?.toInt();
        _currency = m['currency']?.toString() ?? _currency;
      }

      // 2) Coach from latest plan_assignments for this user (assigned_by -> profiles.name).
      final assignments = await _client
          .from('plan_assignments')
          .select('assigned_by,created_at')
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(1);
      if (assignments.isNotEmpty) {
        final a = Map<String, dynamic>.from(assignments.first as Map);
        final coachId = a['assigned_by']?.toString();
        if (coachId != null && coachId.trim().isNotEmpty) {
          final coach = await _client
              .from('profiles')
              .select('name')
              .eq('id', coachId)
              .maybeSingle();
          final n = coach?['name']?.toString();
          if (n != null && n.trim().isNotEmpty) _coachName = n.trim();
          if (_coaches.any((c) => c.id == coachId)) {
            _selectedCoachId = coachId;
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _kindKey() {
    return widget.kind == SubscriptionRequestKind.activate ? 'activate' : 'renew';
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final user = _client.auth.currentUser;
    if (user == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final kind = _kindKey();
      final pending = await _client
          .from('subscription_requests')
          .select('id')
          .eq('user_id', user.id)
          .eq('request_kind', kind)
          .eq('status', 'pending')
          .limit(1);
      if ((pending as List).isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('subscription_pending_exists'.tr())),
        );
        return;
      }

      await _client.from('subscription_requests').insert(<String, dynamic>{
        'user_id': user.id,
        'requested_plan': widget.planKey,
        'request_kind': kind,
        'duration_days': widget.durationDays,
        if (_selectedCoachId != null) 'preferred_coach_id': _selectedCoachId,
        'note': 'Requested from mobile (confirm screen)',
        'status': 'pending',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.kind == SubscriptionRequestKind.activate
                ? 'subscription_activation_sent'.tr()
                : 'subscription_renewal_sent'.tr(),
          ),
        ),
      );
      Navigator.of(context).pop<void>();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceText = _priceCents == null
        ? '—'
        : '${(_priceCents! / 100).toStringAsFixed(0)} $_currency';

    final title = widget.kind == SubscriptionRequestKind.activate
        ? 'subscription_confirm_activate_title'.tr()
        : 'subscription_confirm_renew_title'.tr();

    return RoyalTabScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.accentGold, size: 20),
                  onPressed: () => Navigator.of(context).pop<void>(),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textCream,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'subscription_confirm_subtitle'.tr(),
              style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(
                child: CircularProgressIndicator(color: AppColors.accentGold),
              ),
              const SizedBox(height: 24),
            ] else ...[
              _cardRow(
                icon: Icons.payments_outlined,
                label: 'subscription_price_label'.tr(),
                value: priceText,
              ),
              const SizedBox(height: 10),
              _coachRow(context),
              const SizedBox(height: 10),
              _cardRow(
                icon: Icons.calendar_today_outlined,
                label: 'subscription_duration_label'.tr(),
                value: 'subscription_duration_days'.tr(args: ['${widget.durationDays}']),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.emeraldDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _submitting
                        ? 'subscription_confirm_sending'.tr()
                        : 'subscription_confirm_cta'.tr(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _selectedCoachLabel(BuildContext context) {
    final id = _selectedCoachId;
    if (id == null) return _coachName;
    final c = _coaches.where((e) => e.id == id).cast<CoachRecipient?>().firstWhere(
          (e) => e != null,
          orElse: () => null,
        );
    if (c == null) return _coachName;
    return c.name;
  }

  Widget _coachRow(BuildContext context) {
    final canPick = _coaches.isNotEmpty;
    final value = _selectedCoachLabel(context);
    return _cardRow(
      icon: Icons.person_outline,
      label: 'subscription_coach_label'.tr(),
      value: value,
      onTap: canPick ? _openCoachPicker : null,
      trailing: canPick
          ? const Icon(Icons.expand_more, color: AppColors.creamDim, size: 18)
          : null,
    );
  }

  Future<void> _openCoachPicker() async {
    final chosen = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppColors.emeraldDark,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        List<CoachRecipient> filtered = _coaches;

        void applyQuery(String v) {
          final needle = v.trim().toLowerCase();
          if (needle.isEmpty) {
            filtered = _coaches;
          } else {
            filtered = _coaches.where((c) {
              final n = c.name.toLowerCase();
              final e = c.email.toLowerCase();
              return n.contains(needle) || e.contains(needle);
            }).toList(growable: false);
          }
        }

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: viewInsets),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'subscription_choose_coach_title'.tr(),
                        style: const TextStyle(
                          color: AppColors.textCream,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        onChanged: (v) => setModalState(() => applyQuery(v)),
                        style: const TextStyle(color: AppColors.textCream),
                        decoration: InputDecoration(
                          hintText: 'subscription_search_coach_hint'.tr(),
                          hintStyle: const TextStyle(color: AppColors.creamDim),
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.creamDim),
                          filled: true,
                          fillColor: const Color.fromRGBO(0, 0, 0, 0.15),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.glassBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.accentGold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 420),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              ListTile(
                                onTap: () => Navigator.of(ctx).pop<String?>(null),
                                title: Text(
                                  'subscription_choose_coach_any'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.textCream,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                trailing: _selectedCoachId == null
                                    ? const Icon(Icons.check,
                                        color: AppColors.accentGold)
                                    : null,
                              ),
                              const Divider(color: AppColors.glassBorder),
                              if (filtered.isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'subscription_no_coaches_found'.tr(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: AppColors.creamDim),
                                  ),
                                )
                              else
                                ...filtered.map((c) {
                                  final selected = _selectedCoachId == c.id;
                                  return ListTile(
                                    onTap: () =>
                                        Navigator.of(ctx).pop<String?>(c.id),
                                    title: Text(
                                      c.name,
                                      style: const TextStyle(
                                        color: AppColors.textCream,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: c.email.trim().isEmpty
                                        ? null
                                        : Text(
                                            c.email,
                                            style: const TextStyle(
                                                color: AppColors.creamDim),
                                          ),
                                    trailing: selected
                                        ? const Icon(Icons.check,
                                            color: AppColors.accentGold)
                                        : null,
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    setState(() => _selectedCoachId = chosen);
  }

  Widget _cardRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final child = Container(
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
                Text(label,
                    style:
                        const TextStyle(color: AppColors.creamDim, fontSize: 11)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textCream,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: child,
    );
  }
}

