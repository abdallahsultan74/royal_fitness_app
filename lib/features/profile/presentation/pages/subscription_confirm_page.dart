import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/data/notifications_repository.dart';

enum SubscriptionRequestKind { activate, renew, cancel }

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

  List<_SubscriptionPackage> _packages = const [];
  _SubscriptionVariant? _selectedVariant;

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

      // 1) Packages + variants (new flow; still backward-compatible).
      final packageRows = await _client.rpc('api_list_subscription_packages');
      final rows = (packageRows as List?)?.cast<dynamic>() ?? const [];
      final byPkg = <String, _SubscriptionPackage>{};
      for (final raw in rows) {
        final m = Map<String, dynamic>.from(raw as Map);
        final pkgId = (m['package_id'] ?? '').toString();
        if (pkgId.trim().isEmpty) continue;
        final pkgKey = (m['package_key'] ?? '').toString();
        final pkg = byPkg[pkgId] ??
            _SubscriptionPackage(
              id: pkgId,
              key: pkgKey,
              name: (m['name'] ?? pkgKey).toString(),
              nameAr: (m['name_ar'] ?? '').toString(),
              description: (m['description'] ?? '').toString(),
              descriptionAr: (m['description_ar'] ?? '').toString(),
              active: (m['package_active'] as bool?) ?? true,
              variants: const [],
            );
        final vId = (m['variant_id'] ?? '').toString();
        final variants = [...pkg.variants];
        if (vId.trim().isNotEmpty) {
          variants.add(
            _SubscriptionVariant(
              id: vId,
              packageId: pkgId,
              durationDays: (m['duration_days'] as num?)?.toInt() ?? 30,
              priceCents: (m['price_cents'] as num?)?.toInt() ?? 0,
              currency: (m['currency'] ?? 'EGP').toString(),
              active: (m['variant_active'] as bool?) ?? true,
            ),
          );
        }
        byPkg[pkgId] = pkg.copyWith(variants: variants);
      }
      final packages = byPkg.values
          .map((p) => p.copyWith(
                variants: [...p.variants]..sort((a, b) => a.durationDays.compareTo(b.durationDays)),
              ))
          .toList(growable: false)
        ..sort((a, b) => a.key.compareTo(b.key));
      _packages = packages;

      _selectedVariant ??= _pickDefaultVariant(
        packages: packages,
        preferKey: widget.planKey,
        preferDurationDays: widget.durationDays,
      );
      _applyVariantToPrice();

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

  _SubscriptionVariant? _pickDefaultVariant({
    required List<_SubscriptionPackage> packages,
    required String preferKey,
    required int preferDurationDays,
  }) {
    if (packages.isEmpty) return null;
    final key = preferKey.toLowerCase().trim();
    final preferred = packages.where((p) => p.key.toLowerCase().trim() == key).toList(growable: false);
    final pool = preferred.isNotEmpty ? preferred : packages;
    for (final p in pool) {
      final match = p.variants.where((v) => v.durationDays == preferDurationDays).toList(growable: false);
      if (match.isNotEmpty) return match.first;
    }
    for (final p in pool) {
      if (p.variants.isNotEmpty) return p.variants.first;
    }
    return null;
  }

  void _applyVariantToPrice() {
    final v = _selectedVariant;
    if (v == null) {
      _priceCents = null;
      _currency = 'EGP';
      return;
    }
    _priceCents = v.priceCents;
    _currency = v.currency;
  }

  String _kindKey() {
    if (widget.kind == SubscriptionRequestKind.renew) return 'renew';
    if (widget.kind == SubscriptionRequestKind.cancel) return 'cancel';
    return 'activate';
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
      if (widget.kind != SubscriptionRequestKind.cancel && _selectedVariant == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('subscription_choose_package_required'.tr())),
        );
        return;
      }
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

      final v = _selectedVariant;
      final pkg = v == null
          ? null
          : _packages.where((p) => p.id == v.packageId).cast<_SubscriptionPackage?>().firstWhere(
                (e) => e != null,
                orElse: () => null,
              );

      await _client.from('subscription_requests').insert(<String, dynamic>{
        'user_id': user.id,
        // Backward compatibility: keep requested_plan/duration_days filled.
        'requested_plan': (widget.kind == SubscriptionRequestKind.cancel
                ? (widget.planKey)
                : (pkg?.key ?? widget.planKey))
            .toLowerCase(),
        'request_kind': kind,
        'duration_days': widget.kind == SubscriptionRequestKind.cancel
            ? (widget.durationDays)
            : (v?.durationDays ?? widget.durationDays),
        if (widget.kind != SubscriptionRequestKind.cancel && pkg != null) 'package_id': pkg.id,
        if (widget.kind != SubscriptionRequestKind.cancel && v != null) 'variant_id': v.id,
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
                : (widget.kind == SubscriptionRequestKind.renew
                    ? 'subscription_renewal_sent'.tr()
                    : 'subscription_cancel_sent'.tr()),
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
        : (widget.kind == SubscriptionRequestKind.renew
            ? 'subscription_confirm_renew_title'.tr()
            : 'subscription_confirm_cancel_title'.tr());

    final selectedPackageName = () {
      final v = _selectedVariant;
      if (v == null) return '—';
      final p = _packages.where((e) => e.id == v.packageId).cast<_SubscriptionPackage?>().firstWhere(
            (e) => e != null,
            orElse: () => null,
          );
      if (p == null) return '—';
      final isAr = context.locale.languageCode.toLowerCase().startsWith('ar');
      final n = isAr ? (p.nameAr.trim().isEmpty ? p.name : p.nameAr) : p.name;
      return n.trim().isEmpty ? p.key : n;
    }();

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
              if (widget.kind == SubscriptionRequestKind.cancel) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                    color: const Color.fromRGBO(255, 70, 70, 0.06),
                  ),
                  child: Text(
                    'subscription_cancel_warning'.tr(),
                    style: const TextStyle(
                      color: AppColors.textCream,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
              _cardRow(
                icon: Icons.workspace_premium_outlined,
                label: 'subscription_package_label'.tr(),
                value: selectedPackageName,
                onTap: (widget.kind == SubscriptionRequestKind.cancel || _packages.isEmpty)
                    ? null
                    : _openPackagePicker,
                trailing: _packages.isEmpty
                    ? null
                    : const Icon(Icons.expand_more, color: AppColors.creamDim, size: 18),
              ),
              const SizedBox(height: 10),
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
                value: 'subscription_duration_days'.tr(
                  args: ['${_selectedVariant?.durationDays ?? widget.durationDays}'],
                ),
              ),
              ],
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
                        : (widget.kind == SubscriptionRequestKind.cancel
                            ? 'subscription_confirm_cancel_cta'.tr()
                            : 'subscription_confirm_cta'.tr()),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openPackagePicker() async {
    final chosen = await showModalBottomSheet<_SubscriptionVariant?>(
      context: context,
      backgroundColor: AppColors.emeraldDark,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final isAr = context.locale.languageCode.toLowerCase().startsWith('ar');
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'subscription_choose_package_title'.tr(),
                  style: const TextStyle(
                    color: AppColors.textCream,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 520),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _packages.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.glassBorder),
                      itemBuilder: (ctx, i) {
                        final p = _packages[i];
                        final title = isAr ? (p.nameAr.trim().isEmpty ? p.name : p.nameAr) : p.name;
                        return ExpansionTile(
                          collapsedIconColor: AppColors.creamDim,
                          iconColor: AppColors.creamDim,
                          textColor: AppColors.textCream,
                          collapsedTextColor: AppColors.textCream,
                          title: Text(
                            title.trim().isEmpty ? p.key : title,
                            style: const TextStyle(
                              color: AppColors.textCream,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: p.description.trim().isEmpty && p.descriptionAr.trim().isEmpty
                              ? null
                              : Text(
                                  isAr
                                      ? (p.descriptionAr.trim().isEmpty ? p.description : p.descriptionAr)
                                      : p.description,
                                  style: const TextStyle(color: AppColors.creamDim),
                                ),
                          children: p.variants.map((v) {
                            final selected = _selectedVariant?.id == v.id;
                            final price = '${(v.priceCents / 100).toStringAsFixed(0)} ${v.currency}';
                            final dur = 'subscription_duration_days'.tr(args: ['${v.durationDays}']);
                            return ListTile(
                              onTap: () => Navigator.of(ctx).pop<_SubscriptionVariant?>(v),
                              title: Text(
                                dur,
                                style: const TextStyle(
                                  color: AppColors.textCream,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                price,
                                style: const TextStyle(color: AppColors.creamDim),
                              ),
                              trailing: selected
                                  ? const Icon(Icons.check, color: AppColors.accentGold)
                                  : null,
                            );
                          }).toList(growable: false),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (chosen == null) return;
    setState(() {
      _selectedVariant = chosen;
      _applyVariantToPrice();
    });
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

class _SubscriptionPackage {
  const _SubscriptionPackage({
    required this.id,
    required this.key,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.active,
    required this.variants,
  });

  final String id;
  final String key;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final bool active;
  final List<_SubscriptionVariant> variants;

  _SubscriptionPackage copyWith({List<_SubscriptionVariant>? variants}) {
    return _SubscriptionPackage(
      id: id,
      key: key,
      name: name,
      nameAr: nameAr,
      description: description,
      descriptionAr: descriptionAr,
      active: active,
      variants: variants ?? this.variants,
    );
  }
}

class _SubscriptionVariant {
  const _SubscriptionVariant({
    required this.id,
    required this.packageId,
    required this.durationDays,
    required this.priceCents,
    required this.currency,
    required this.active,
  });

  final String id;
  final String packageId;
  final int durationDays;
  final int priceCents;
  final String currency;
  final bool active;
}

