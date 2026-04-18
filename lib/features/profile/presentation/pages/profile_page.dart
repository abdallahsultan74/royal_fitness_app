import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/bmi_utils.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/profile_repository.dart';
import '../../domain/user_profile.dart';

/// View and edit health profile + account security (password).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileRepo = ProfileRepository();
  final _authRepo = AuthRepository();
  final _name = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();
  bool _saving = false;
  String? _filledForUid;

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    _target.dispose();
    super.dispose();
  }

  void _fillFrom(UserProfile p) {
    _name.text = p.name;
    _height.text = p.heightCm?.toStringAsFixed(0) ?? '';
    _weight.text = p.currentWeightKg?.toStringAsFixed(1) ?? '';
    _target.text = p.targetWeightKg?.toStringAsFixed(1) ?? '';
  }

  Future<void> _save(UserProfile current) async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _snack('profile_name_required'.tr());
      return;
    }
    final h = double.tryParse(_height.text.replaceAll(',', '.'));
    final w = double.tryParse(_weight.text.replaceAll(',', '.'));
    final t = double.tryParse(_target.text.replaceAll(',', '.'));
    final computed = BmiUtils.compute(heightCm: h, weightKg: w);
    setState(() => _saving = true);
    try {
      await _profileRepo.upsertProfile(
        name: name,
        heightCm: h,
        currentWeightKg: w,
        targetWeightKg: t,
        bmi: computed?.bmi,
        bmiStatus: computed?.status,
      );
      if (!mounted) return;
      _snack('profile_saved'.tr());
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _changePasswordDialog() async {
    final newPass = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.emeraldDark,
        title: Text(
          'profile_change_password_title'.tr(),
          style: const TextStyle(color: AppColors.textCream),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPass,
              obscureText: true,
              style: const TextStyle(color: AppColors.textCream),
              decoration: InputDecoration(
                hintText: 'reset_password_new'.tr(),
                hintStyle: const TextStyle(color: AppColors.creamDim),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirm,
              obscureText: true,
              style: const TextStyle(color: AppColors.textCream),
              decoration: InputDecoration(
                hintText: 'reset_password_confirm'.tr(),
                hintStyle: const TextStyle(color: AppColors.creamDim),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common_cancel'.tr(), style: const TextStyle(color: AppColors.creamDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('profile_change_password_confirm'.tr(),
                style: const TextStyle(color: AppColors.accentGold)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (newPass.text.length < 6) {
      _snack('reset_password_too_short'.tr());
      return;
    }
    if (newPass.text != confirm.text) {
      _snack('reset_password_mismatch'.tr());
      return;
    }
    try {
      await _authRepo.updatePassword(newPass.text);
      if (!mounted) return;
      _snack('profile_password_updated'.tr());
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile>(
      stream: _profileRepo.watchProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final p = profile;
        if (p != null && _filledForUid != p.uid) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _fillFrom(p);
            setState(() => _filledForUid = p.uid);
          });
        }
        return RoyalTabScaffold(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.accentGold, size: 20),
                    onPressed: () => Navigator.of(context).pop<void>(),
                  ),
                  Expanded(
                    child: Text(
                      'profile_title'.tr(),
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
                'profile_subtitle'.tr(),
                style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
              ),
              const SizedBox(height: 20),
              if (p == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.accentGold),
                  ),
                )
              else ...[
                Text('profile_section_personal'.tr(),
                    style: const TextStyle(
                        color: AppColors.creamDim, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 8),
                _field(label: 'signup_name_placeholder'.tr(), controller: _name),
                const SizedBox(height: 12),
                Text(
                  p.email,
                  style: const TextStyle(color: AppColors.creamDim, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _field(label: 'signup_height_placeholder'.tr(), controller: _height, keyboard: TextInputType.number),
                const SizedBox(height: 12),
                _field(label: 'signup_weight_placeholder'.tr(), controller: _weight, keyboard: TextInputType.number),
                const SizedBox(height: 12),
                _field(
                    label: 'signup_target_weight_placeholder'.tr(),
                    controller: _target,
                    keyboard: TextInputType.number),
                if (p.bmi != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${'progress_stat_bmi'.tr()}: ${p.bmi!.toStringAsFixed(1)} ${_bmiLabel(p.bmiStatus)}',
                      style: const TextStyle(color: AppColors.accentGold, fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : () => _save(p),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.emeraldDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_saving ? 'profile_saving'.tr() : 'profile_save'.tr()),
                  ),
                ),
                const SizedBox(height: 28),
                Text('profile_section_security'.tr(),
                    style: const TextStyle(
                        color: AppColors.creamDim, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'profile_change_password_title'.tr(),
                    style: const TextStyle(color: AppColors.textCream, fontSize: 15),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.accentGold),
                  onTap: _changePasswordDialog,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _bmiLabel(String? status) {
    switch (status) {
      case 'underweight':
        return 'progress_bmi_status_underweight'.tr();
      case 'normal':
        return 'progress_bmi_status_normal'.tr();
      case 'overweight':
        return 'progress_bmi_status_overweight'.tr();
      case 'obese':
        return 'progress_bmi_status_obese'.tr();
      default:
        return '';
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: AppColors.textCream),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.creamDim),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGold),
        ),
      ),
    );
  }
}
