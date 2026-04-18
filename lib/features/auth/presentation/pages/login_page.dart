// UI parity with local Figma Make export: figma/app/components/auth-screens.tsx
// and figma/app/components/royal-theme.tsx
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/backend/supabase_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_repository.dart';
import '../../../shell/presentation/main_shell.dart';
import 'signup_page.dart';
import '../widgets/gold_gradient_button.dart';
import '../../../../core/common_widgets/royal_geometric_background.dart';
import '../widgets/royal_glass_text_field.dart';
import '../widgets/social_login_chip.dart';
import '../widgets/royal_gold_shimmer.dart';

/// Login screen — layout and tokens from Figma Make (`figma/`).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toggleLocale(BuildContext context) {
    final next = context.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    context.setLocale(next);
  }

  void _openHome(BuildContext context) {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => const MainShell(),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_loading) return;
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('يرجى إدخال البريد وكلمة المرور');
      return;
    }

    setState(() => _loading = true);
    try {
      await _authRepository.signIn(
        email: email,
        password: password,
      );
      if (!mounted) return;
      _openHome(context);
    } on AuthException catch (e) {
      _showError(_mapAuthError(e));
    } catch (_) {
      _showError('حدث خطأ غير متوقع، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final ctrl = TextEditingController(text: _email.text.trim());
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.emeraldDark,
          title: Text(
            'forgot_password_title'.tr(),
            style: const TextStyle(color: AppColors.textCream),
          ),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.textCream),
            decoration: InputDecoration(
              hintText: 'login_email_placeholder'.tr(),
              hintStyle: const TextStyle(color: AppColors.creamDim),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'common_cancel'.tr(),
                style: const TextStyle(color: AppColors.creamDim),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'forgot_password_send'.tr(),
                style: const TextStyle(color: AppColors.accentGold),
              ),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    setState(() => _loading = true);
    try {
      await _authRepository.resetPasswordForEmail(
        ctrl.text,
        redirectTo: SupabaseConfig.passwordResetRedirectUrl,
      );
      if (!mounted) return;
      _showInfo('forgot_password_sent'.tr());
    } on AuthException catch (e) {
      _showError(_mapAuthError(e));
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(AuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'invalid_credentials':
        return 'البريد أو كلمة المرور غير صحيحة';
      case 'email_not_confirmed':
        return 'الرجاء تأكيد البريد الإلكتروني أولاً';
      case 'over_request_rate_limit':
        return 'عدد محاولات كبير. حاول لاحقًا';
      case 'request_timeout':
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryEmerald,
                  AppColors.emeraldDark,
                ],
              ),
            ),
          ),
          const Positioned.fill(child: RoyalGeometricBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth < 448
                    ? constraints.maxWidth
                    : 448.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: _LangToggle(onToggle: () => _toggleLocale(context)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxW),
                          child: SingleChildScrollView(
                            padding: EdgeInsetsDirectional.only(
                              start: 24,
                              end: 24,
                              bottom: bottomInset > 0 ? bottomInset : 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Center(child: _RoyalLogoBlock()),
                                const SizedBox(height: 32),
                                Text(
                                  'login_welcome_title'.tr(),
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.textCream,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'login_welcome_subtitle'.tr(),
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
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
                                  icon: Icons.lock_outline,
                                  hintText: 'login_password_placeholder'.tr(),
                                  controller: _password,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: TextButton(
                                    onPressed: _loading
                                        ? null
                                        : _showForgotPasswordDialog,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'login_forgot_password'.tr(),
                                      style: const TextStyle(
                                        color: AppColors.accentGold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                GoldGradientButton(
                                  label: 'login_sign_in'.tr(),
                                  onPressed: _loading ? null : _signIn,
                                  disabled: _loading,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'login_or'.tr(),
                                        style: const TextStyle(
                                          color: AppColors.creamDim,
                                          fontSize: 11,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    SocialLoginChip(
                                      label: 'login_google'.tr(),
                                      leading: SvgPicture.asset(
                                        'assets/svg/google_g.svg',
                                        width: 18,
                                        height: 18,
                                      ),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 12),
                                    SocialLoginChip(
                                      label: 'login_apple'.tr(),
                                      leading: SvgPicture.asset(
                                        'assets/svg/apple_logo.svg',
                                        width: 18,
                                        height: 18,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'login_no_account_prefix'.tr(),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.creamDim,
                                                fontSize: 13,
                                              ),
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            start: 4,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push<void>(
                                            MaterialPageRoute<void>(
                                              builder: (_) => const SignUpPage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'login_sign_up'.tr(),
                                          style: const TextStyle(
                                            color: AppColors.accentGold,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  const _LangToggle({required this.onToggle});

  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.glassBorder),
            color: const Color.fromRGBO(0, 0, 0, 0.15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'lang_en'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: context.locale.languageCode == 'en'
                      ? AppColors.accentGold
                      : AppColors.creamDim,
                ),
              ),
              Container(
                width: 1,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: AppColors.glassBorder,
              ),
              Text(
                'lang_ar'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: context.locale.languageCode == 'ar'
                      ? AppColors.accentGold
                      : AppColors.creamDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoyalLogoBlock extends StatelessWidget {
  const _RoyalLogoBlock();

  static final BorderRadius _circle = BorderRadius.circular(999);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentGold, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(212, 175, 55, 0.2),
                    blurRadius: 50,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(212, 175, 55, 0.06),
                    blurRadius: 20,
                    spreadRadius: -8,
                    offset: Offset.zero,
                  ),
                ],
                gradient: const RadialGradient(
                  center: Alignment(-0.4, -0.4),
                  radius: 0.9,
                  colors: [
                    Color.fromRGBO(212, 175, 55, 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: RoyalGoldShimmer(borderRadius: _circle),
                    ),
                    Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: AppColors.accentGold,
                      shadows: const [
                        Shadow(
                          color: Color.fromRGBO(212, 175, 55, 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -12,
              child: Icon(
                Icons.workspace_premium,
                size: 22,
                color: AppColors.accentGold,
                shadows: const [
                  Shadow(
                    color: Color.fromRGBO(212, 175, 55, 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'login_logo_royal'.tr(),
          style: const TextStyle(
            color: AppColors.accentGold,
            fontSize: 22,
            letterSpacing: 5,
            fontWeight: FontWeight.w700,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -2),
          child: Text(
            'login_logo_fitness'.tr(),
            style: const TextStyle(
              color: AppColors.textCream,
              fontSize: 22,
              letterSpacing: 5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
