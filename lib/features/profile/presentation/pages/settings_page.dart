import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/entitlements/coach_content_entitlements.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/royal_feedback.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';
import '../../../notifications/presentation/pages/user_notifications_page.dart';
import '../../data/profile_repository.dart';
import '../../domain/user_profile.dart';
import 'health_reports_page.dart';
import 'profile_page.dart';
import 'subscription_confirm_page.dart';

/// Settings tab (Figma `SettingsScreen`).
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _notifications = false;
  bool _voiceCoach = true;

  String? _packageName;
  String? _packageNameForId;

  Future<void> _loadPackageName(String? packageId, String langCode) async {
    final id = (packageId ?? '').trim();
    if (id.isEmpty) {
      if (mounted) {
        setState(() {
          _packageName = null;
          _packageNameForId = null;
        });
      }
      return;
    }
    if (_packageNameForId == id && _packageName != null) {
      return;
    }
    try {
      final row = await Supabase.instance.client
          .from('subscription_packages')
          .select('name,name_ar,key')
          .eq('id', id)
          .maybeSingle();
      final isAr = langCode.toLowerCase().startsWith('ar');
      final name = row == null
          ? null
          : (isAr ? (row['name_ar']?.toString() ?? '') : (row['name']?.toString() ?? ''))
              .trim();
      final fallbackKey = row?['key']?.toString().trim();
      if (!mounted) return;
      setState(() {
        _packageNameForId = id;
        _packageName = (name != null && name.isNotEmpty) ? name : (fallbackKey?.isNotEmpty == true ? fallbackKey : null);
      });
    } catch (_) {
      // Ignore and fall back to profile.plan.
    }
  }

  Stream<Set<String>> _watchMyPendingKinds() {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return const Stream<Set<String>>.empty();
    return client
        .from('subscription_requests')
        .stream(primaryKey: <String>['id'])
        .eq('user_id', uid)
        .map((rows) {
      final pending = <String>{};
      for (final raw in rows) {
        final m = Map<String, dynamic>.from(raw);
        final status = (m['status'] ?? '').toString().toLowerCase();
        if (status != 'pending') continue;
        final k = (m['request_kind'] ?? '').toString().toLowerCase();
        if (k.isNotEmpty) pending.add(k);
      }
      return pending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return StreamBuilder<UserProfile>(
      stream: _profileRepository.watchProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        _loadPackageName(profile?.subscriptionPackageId, lang);
        final displayName = profile?.name ?? 'settings_royal_member'.tr();
        final planKey = (profile?.plan ?? '').trim();
        final displayPlan = (_packageName ?? planKey).isNotEmpty ? (_packageName ?? planKey) : 'settings_premium_plan'.tr();
        final hasActiveSub = hasActiveCoachContentAccess(profile);
        return RoyalTabScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Text(
              'settings_title'.tr(),
              style: const TextStyle(
                color: AppColors.textCream,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
                child: RoyalGlassPanel(
                  variant: RoyalGlassVariant.gold,
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: RoyalGoldShimmer(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                      ),
                      Row(
                        children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.accentGold,
                            width: 2,
                          ),
                          gradient: const RadialGradient(
                            center: Alignment(-0.4, -0.4),
                            radius: 1.2,
                            colors: [
                              Color.fromRGBO(212, 175, 55, 0.15),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(212, 175, 55, 0.15),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 28,
                          color: AppColors.accentGold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: AppColors.textCream,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              displayPlan,
                              style: const TextStyle(
                                color: AppColors.creamDim,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '28',
                                  style: const TextStyle(
                                    color: AppColors.accentGold,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'settings_stat_workouts'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.creamDim,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '8',
                                  style: const TextStyle(
                                    color: AppColors.accentGold,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'settings_stat_streak'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.creamDim,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.goldBorder,
                        size: 16,
                      ),
                    ],
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.glassBorder),
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                ),
                child: Row(
                  children: [
                    _langCell(
                      context,
                      code: 'en',
                      label: 'English',
                      selected: lang == 'en',
                    ),
                    _langCell(
                      context,
                      code: 'ar',
                      label: 'العربية',
                      selected: lang == 'ar',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('settings_section_account'.tr()),
          _menuTile(
            icon: Icons.person_outline,
            titleKey: 'profile_title',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
          _menuTile(
            icon: Icons.notifications_none,
            titleKey: 'settings_notifications',
            trailing: _goldSwitch(
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            showChevron: false,
          ),
          _menuTile(
            icon: Icons.inbox_outlined,
            titleKey: 'notifications_inbox',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const UserNotificationsPage(),
                ),
              );
            },
          ),
          _menuTile(
            icon: Icons.language,
            titleKey: 'settings_language',
            valueText: lang == 'ar' ? 'العربية' : 'English',
          ),
          _menuTile(
            icon: Icons.volume_up_outlined,
            titleKey: 'settings_voice_coach',
            trailing: _goldSwitch(
              value: _voiceCoach,
              onChanged: (v) => setState(() => _voiceCoach = v),
            ),
            showChevron: false,
          ),
          const SizedBox(height: 8),
          _sectionTitle('settings_section_general'.tr()),
          _menuTile(
            icon: Icons.favorite_outline,
            titleKey: 'settings_health_data',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const HealthReportsPage(),
                ),
              );
            },
          ),
          StreamBuilder<Set<String>>(
            stream: _watchMyPendingKinds(),
            builder: (context, pendingSnap) {
              final pending = pendingSnap.data ?? const <String>{};
              final pendingActivate = pending.contains('activate');
              final pendingRenew = pending.contains('renew');
              final pendingCancel = pending.contains('cancel');

              final tiles = <Widget>[];
              if (!hasActiveSub) {
                tiles.add(
                  _menuTile(
                    icon: Icons.workspace_premium_outlined,
                    titleKey: 'settings_request_plan_activation',
                    valueText: pendingActivate ? 'subscription_confirm_sending'.tr() : displayPlan,
                    onTap: pendingActivate
                        ? null
                        : () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => const SubscriptionConfirmPage(
                                  kind: SubscriptionRequestKind.activate,
                                ),
                              ),
                            );
                          },
                  ),
                );
              } else {
                tiles.add(
                  _menuTile(
                    icon: Icons.autorenew,
                    titleKey: 'settings_request_renewal',
                    valueText: pendingRenew ? 'subscription_confirm_sending'.tr() : displayPlan,
                    onTap: pendingRenew
                        ? null
                        : () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => const SubscriptionConfirmPage(
                                  kind: SubscriptionRequestKind.renew,
                                ),
                              ),
                            );
                          },
                  ),
                );
                tiles.add(
                  _menuTile(
                    icon: Icons.cancel_outlined,
                    titleKey: 'settings_request_cancel',
                    valueText: pendingCancel ? 'subscription_confirm_sending'.tr() : '',
                    onTap: pendingCancel
                        ? null
                        : () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => const SubscriptionConfirmPage(
                                  kind: SubscriptionRequestKind.cancel,
                                ),
                              ),
                            );
                          },
                  ),
                );
              }
              return Column(children: tiles);
            },
          ),
          _menuTile(
            icon: Icons.help_outline,
            titleKey: 'settings_contact',
            onTap: _contactSupport,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  await _authRepository.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginPage(),
                    ),
                    (_) => false,
                  );
                },
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 70, 70, 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 70, 70, 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        size: 18,
                        color: Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'settings_logout'.tr(),
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'settings_version'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.creamDim.withValues(alpha: 0.35),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.creamDim,
          fontSize: 11,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String titleKey,
    String? valueText,
    Widget? trailing,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap == null
              ? (trailing != null && showChevron == false ? null : () {})
              : () async {
                  await RoyalFeedback.tap(context);
                  onTap();
                },
          child: RoyalGlassPanel(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.goldDim,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Icon(icon, size: 17, color: AppColors.accentGold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titleKey.tr(),
                    style: const TextStyle(
                      color: AppColors.textCream,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (valueText != null) ...[
                  Text(
                    valueText,
                    style: const TextStyle(
                      color: AppColors.creamDim,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (trailing != null)
                  trailing
                else if (showChevron)
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.goldBorder,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _goldSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: value
              ? const LinearGradient(
                  colors: [AppColors.accentGold, AppColors.goldLight],
                )
              : null,
          color: value ? null : const Color.fromRGBO(255, 255, 255, 0.1),
          boxShadow: value
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(212, 175, 55, 0.2),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.emeraldDark : AppColors.creamDim,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _langCell(
    BuildContext context, {
    required String code,
    required String label,
    required bool selected,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await context.setLocale(Locale(code));
            try {
              await _profileRepository.upsertProfile(language: code);
            } catch (_) {}
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [AppColors.accentGold, AppColors.goldLight],
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  const Positioned.fill(
                    child: RoyalGoldShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.emeraldDark : AppColors.creamDim,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _contactSupport() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final email = user?.email ?? '';
    final uid = user?.id ?? '';
    final subject = Uri.encodeComponent('Royal Fitness Support');
    final body = Uri.encodeComponent('User: $email\\nUID: $uid\\n\\nMessage:');
    final uri = Uri.parse('mailto:admin@royalfitness.com?subject=$subject&body=$body');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Old direct insert flow removed; replaced by SubscriptionConfirmPage.
}
