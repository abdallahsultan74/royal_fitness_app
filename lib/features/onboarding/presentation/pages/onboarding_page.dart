import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/common_widgets/royal_geometric_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';

/// First-launch onboarding (Figma `Onboarding`).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;
  int? _goalIndex;

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
      ),
    );
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
                colors: [
                  AppColors.primaryEmerald,
                  AppColors.emeraldDark,
                ],
              ),
            ),
          ),
          const Positioned.fill(child: RoyalGeometricBackground()),
          if (_step == 0) _buildStep0(context) else _buildStep1(context),
        ],
      ),
    );
  }

  Widget _buildStep0(BuildContext context) {
    final lang = context.locale.languageCode;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentGold, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(212, 175, 55, 0.25),
                        blurRadius: 60,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(212, 175, 55, 0.08),
                        blurRadius: 120,
                      ),
                    ],
                    gradient: const RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      radius: 0.9,
                      colors: [
                        Color.fromRGBO(212, 175, 55, 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Positioned.fill(
                        child: RoyalGoldShimmer(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                      ),
                      const Icon(
                        Icons.fitness_center,
                        size: 56,
                        color: AppColors.accentGold,
                      ),
                      const Positioned(
                        top: -8,
                        child: Icon(
                          Icons.workspace_premium,
                          size: 28,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'onboarding_logo_royal'.tr(),
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 30,
                    letterSpacing: 6,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -4),
                  child: Text(
                    'onboarding_logo_fitness'.tr(),
                    style: const TextStyle(
                      color: AppColors.textCream,
                      fontSize: 30,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 1,
                      color: AppColors.goldBorder,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'onboarding_tagline'.tr(),
                        style: const TextStyle(
                          color: AppColors.creamDim,
                          fontSize: 12,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 1,
                      color: AppColors.goldBorder,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.goldBorder),
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                      ),
                      child: Row(
                        children: [
                          _langChoice(context, 'en', 'English', lang == 'en'),
                          _langChoice(context, 'ar', 'العربية', lang == 'ar'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _step = 1),
                child: Ink(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.accentGold, AppColors.goldLight],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(212, 175, 55, 0.35),
                        blurRadius: 32,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned.fill(
                        child: RoyalGoldShimmer(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'onboarding_get_started'.tr(),
                            style: const TextStyle(
                              color: AppColors.emeraldDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.emeraldDark,
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
      ),
    );
  }

  Widget _langChoice(
    BuildContext context,
    String code,
    String label,
    bool selected,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.setLocale(Locale(code)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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

  Widget _buildStep1(BuildContext context) {
    const goals = <Map<String, String>>[
      {
        'title': 'onboarding_goal_lose',
        'desc': 'onboarding_goal_lose_desc',
        'icon': '🔥',
      },
      {
        'title': 'onboarding_goal_muscle',
        'desc': 'onboarding_goal_muscle_desc',
        'icon': '💪',
      },
      {
        'title': 'onboarding_goal_fit',
        'desc': 'onboarding_goal_fit_desc',
        'icon': '⚡',
      },
      {
        'title': 'onboarding_goal_flex',
        'desc': 'onboarding_goal_flex_desc',
        'icon': '🧘',
      },
    ];

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.goldBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(212, 175, 55, 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'onboarding_goal_title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textCream,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
            child: Text(
              'onboarding_goal_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.creamDim,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final g = goals[i];
                final selected = _goalIndex == i;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _goalIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  Color.fromRGBO(212, 175, 55, 0.15),
                                  Color.fromRGBO(212, 175, 55, 0.05),
                                ],
                              )
                            : const LinearGradient(
                                colors: [
                                  Color.fromRGBO(1, 50, 32, 0.5),
                                  Color.fromRGBO(13, 17, 23, 0.5),
                                ],
                              ),
                        border: Border.all(
                          color: selected
                              ? AppColors.accentGold
                              : AppColors.glassBorder,
                        ),
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                  color: Color.fromRGBO(212, 175, 55, 0.15),
                                  blurRadius: 24,
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          if (selected)
                            const Positioned.fill(
                              child: RoyalGoldShimmer(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.goldDim
                                      : const Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          0.05,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.goldBorder
                                        : const Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            0.05,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  g['icon']!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g['title']!.tr(),
                                      style: TextStyle(
                                        color: selected
                                            ? AppColors.accentGold
                                            : AppColors.textCream,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      g['desc']!.tr(),
                                      style: const TextStyle(
                                        color: AppColors.creamDim,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.accentGold
                                        : AppColors.goldBorder,
                                    width: 2,
                                  ),
                                  color: selected
                                      ? AppColors.accentGold
                                      : Colors.transparent,
                                ),
                                child: selected
                                    ? const Center(
                                        child: SizedBox(
                                          width: 8,
                                          height: 8,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: AppColors.emeraldDark,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _goalIndex == null ? null : _complete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _goalIndex != null
                        ? const LinearGradient(
                            colors: [
                              AppColors.accentGold,
                              AppColors.goldLight,
                            ],
                          )
                        : null,
                    color: _goalIndex == null
                        ? const Color.fromRGBO(212, 175, 55, 0.15)
                        : null,
                    boxShadow: _goalIndex != null
                        ? const [
                            BoxShadow(
                              color: Color.fromRGBO(212, 175, 55, 0.35),
                              blurRadius: 32,
                              offset: Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_goalIndex != null)
                        const Positioned.fill(
                          child: RoyalGoldShimmer(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'onboarding_continue'.tr(),
                            style: TextStyle(
                              color: _goalIndex != null
                                  ? AppColors.emeraldDark
                                  : AppColors.creamDim.withValues(alpha: 0.3),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: _goalIndex != null
                                ? AppColors.emeraldDark
                                : AppColors.creamDim.withValues(alpha: 0.3),
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
      ),
    );
  }
}
