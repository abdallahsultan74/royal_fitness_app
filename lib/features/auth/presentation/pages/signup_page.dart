import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common_widgets/royal_geometric_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_repository.dart';
import '../../../shell/presentation/main_shell.dart';
import '../widgets/gold_gradient_button.dart';
import '../widgets/royal_glass_text_field.dart';
import '../widgets/royal_gold_shimmer.dart';

/// Sign up screen with the same royal style as login.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _whatsapp = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _targetWeight = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _loading = false;
  DateTime? _selectedDob;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _whatsapp.dispose();
    _dob.dispose();
    _height.dispose();
    _weight.dispose();
    _targetWeight.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _selectedDob = DateTime(picked.year, picked.month, picked.day);
      _dob.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _createAccount(BuildContext context) async {
    if (_loading) return;
    final name = _name.text.trim();
    final email = _email.text.trim();
    final whatsappPhone = _whatsapp.text.trim();
    final heightCm = double.tryParse(_height.text.trim());
    final weightKg = double.tryParse(_weight.text.trim());
    final targetWeightKg = double.tryParse(_targetWeight.text.trim());
    final password = _password.text;
    final confirmPassword = _confirmPassword.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _height.text.trim().isEmpty ||
        _weight.text.trim().isEmpty) {
      _showError('من فضلك أدخل كل البيانات');
      return;
    }
    if (heightCm == null || heightCm <= 0 || heightCm > 260) {
      _showError('أدخل طولاً صحيحاً بالسنتيمتر');
      return;
    }
    if (weightKg == null || weightKg <= 0 || weightKg > 400) {
      _showError('أدخل وزناً صحيحاً بالكيلو');
      return;
    }
    if (_targetWeight.text.trim().isNotEmpty &&
        (targetWeightKg == null || targetWeightKg <= 0 || targetWeightKg > 400)) {
      _showError('أدخل وزن الهدف بشكل صحيح أو اتركه فارغاً');
      return;
    }
    if (password.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (password != confirmPassword) {
      _showError('كلمتا المرور غير متطابقتين');
      return;
    }

    setState(() => _loading = true);
    try {
      final hasSession = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        language: context.locale.languageCode,
        heightCm: heightCm,
        currentWeightKg: weightKg,
        dateOfBirth: _selectedDob,
        targetWeightKg: targetWeightKg,
        whatsappPhone: whatsappPhone.isEmpty ? null : whatsappPhone,
      );

      if (!context.mounted) return;
      if (hasSession) {
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => const MainShell(),
          ),
        );
      } else {
        _showError('تم إنشاء الحساب. راجع بريدك لتأكيد الحساب ثم سجّل الدخول.');
        Navigator.of(context).pop();
      }
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

  String _mapAuthError(AuthException e) {
    switch (e.code) {
      case 'user_already_exists':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'weak_password':
        return 'كلمة المرور ضعيفة';
      case 'request_timeout':
        return 'لا يوجد اتصال بالإنترنت';
      case 'email_address_not_authorized':
        return 'هذا البريد غير مصرح له بالتسجيل';
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
                final maxW = constraints.maxWidth < 448 ? constraints.maxWidth : 448.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.glassBorder),
                                      color: const Color.fromRGBO(0, 0, 0, 0.15),
                                    ),
                                    child: const Icon(
                                      Icons.chevron_left,
                                      color: AppColors.textCream,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                const _SignUpLogo(),
                                const SizedBox(height: 28),
                                Text(
                                  'signup_title'.tr(),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: AppColors.textCream,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'signup_subtitle'.tr(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.creamDim,
                                        fontSize: 13,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                RoyalGlassTextField(
                                  icon: Icons.person_outline,
                                  hintText: 'signup_name_placeholder'.tr(),
                                  controller: _name,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                RoyalGlassTextField(
                                  icon: Icons.mail_outline,
                                  hintText: 'signup_email_placeholder'.tr(),
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'signup_whatsapp_hint'.tr(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.creamDim,
                                        fontSize: 12,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                RoyalGlassTextField(
                                  icon: Icons.phone_android,
                                  hintText: 'signup_whatsapp_placeholder'.tr(),
                                  controller: _whatsapp,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: _pickDob,
                                  child: AbsorbPointer(
                                    child: RoyalGlassTextField(
                                      icon: Icons.cake_outlined,
                                      hintText: 'Date of birth (YYYY-MM-DD)',
                                      controller: _dob,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                RoyalGlassTextField(
                                  icon: Icons.height,
                                  hintText: 'signup_height_placeholder'.tr(),
                                  controller: _height,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                RoyalGlassTextField(
                                  icon: Icons.monitor_weight_outlined,
                                  hintText: 'signup_weight_placeholder'.tr(),
                                  controller: _weight,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                RoyalGlassTextField(
                                  icon: Icons.flag_outlined,
                                  hintText: 'signup_target_weight_placeholder'.tr(),
                                  controller: _targetWeight,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                RoyalGlassTextField(
                                  icon: Icons.lock_outline,
                                  hintText: 'signup_password_placeholder'.tr(),
                                  controller: _password,
                                  obscureText: true,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                RoyalGlassTextField(
                                  icon: Icons.verified_user_outlined,
                                  hintText: 'signup_confirm_password_placeholder'.tr(),
                                  controller: _confirmPassword,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 24),
                                GoldGradientButton(
                                  label: 'signup_create_account'.tr(),
                                  onPressed: _loading ? null : () => _createAccount(context),
                                  disabled: _loading,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'signup_have_account_prefix'.tr(),
                                      style: const TextStyle(
                                        color: AppColors.creamDim,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsetsDirectional.only(start: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'signup_sign_in'.tr(),
                                        style: const TextStyle(
                                          color: AppColors.accentGold,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
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

class _SignUpLogo extends StatelessWidget {
  const _SignUpLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGold, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(212, 175, 55, 0.2),
                  blurRadius: 40,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(
                    child: RoyalGoldShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  ),
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 34,
                    color: AppColors.accentGold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
