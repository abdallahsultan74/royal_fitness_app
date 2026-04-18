import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/auth_repository.dart';
import '../../../../core/common_widgets/royal_geometric_background.dart';
import '../widgets/gold_gradient_button.dart';
import '../widgets/royal_glass_text_field.dart';
import '../../../shell/presentation/main_shell.dart';

/// Shown when Supabase emits [AuthChangeEvent.passwordRecovery] with a session.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = AuthRepository();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final p = _pass.text;
    final c = _confirm.text;
    if (p.length < 6) {
      _snack('reset_password_too_short'.tr());
      return;
    }
    if (p != c) {
      _snack('reset_password_mismatch'.tr());
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.updatePassword(p);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryEmerald, AppColors.emeraldDark],
              ),
            ),
          ),
          const Positioned.fill(child: RoyalGeometricBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'reset_password_title'.tr(),
                        style: const TextStyle(
                          color: AppColors.textCream,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'reset_password_subtitle'.tr(),
                        style: const TextStyle(
                          color: AppColors.creamDim,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      RoyalGlassTextField(
                        icon: Icons.lock_outline,
                        hintText: 'reset_password_new'.tr(),
                        controller: _pass,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      RoyalGlassTextField(
                        icon: Icons.lock_outline,
                        hintText: 'reset_password_confirm'.tr(),
                        controller: _confirm,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 28),
                      GoldGradientButton(
                        label: 'reset_password_save'.tr(),
                        onPressed: _loading ? null : _submit,
                        disabled: _loading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
