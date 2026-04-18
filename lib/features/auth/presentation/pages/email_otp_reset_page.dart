import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/common_widgets/royal_geometric_background.dart';
import '../../data/auth_repository.dart';
import '../widgets/gold_gradient_button.dart';
import '../widgets/royal_glass_text_field.dart';
import '../../../shell/presentation/main_shell.dart';

class EmailOtpResetPage extends StatefulWidget {
  const EmailOtpResetPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<EmailOtpResetPage> createState() => _EmailOtpResetPageState();
}

class _EmailOtpResetPageState extends State<EmailOtpResetPage> {
  final _auth = AuthRepository();
  late final TextEditingController _email;
  final _otp = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.email.trim());
  }

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _resend() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _auth.sendEmailOtp(_email.text);
      _snack('${'otp_reset_sent'.tr()}\n${'otp_reset_check_spam'.tr()}');
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyAndSetPassword() async {
    if (_loading) return;
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
      await _auth.verifyEmailOtp(email: _email.text, token: _otp.text);
      await _auth.updatePassword(p);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
        (_) => false,
      );
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
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
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'otp_reset_title'.tr(),
                        style: const TextStyle(
                          color: AppColors.textCream,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'otp_reset_subtitle'.tr(),
                        style: const TextStyle(
                          color: AppColors.creamDim,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      RoyalGlassTextField(
                        icon: Icons.mail_outline,
                        hintText: 'login_email_placeholder'.tr(),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      RoyalGlassTextField(
                        icon: Icons.lock_clock_outlined,
                        hintText: 'otp_reset_code_hint'.tr(),
                        controller: _otp,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 24),
                      GoldGradientButton(
                        label: 'otp_reset_verify'.tr(),
                        onPressed: _loading ? null : _verifyAndSetPassword,
                        disabled: _loading,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loading ? null : _resend,
                        child: Text(
                          'otp_reset_resend'.tr(),
                          style: const TextStyle(color: AppColors.accentGold),
                        ),
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

