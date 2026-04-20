import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Royal splash — Figma-inspired radial backdrop, Montserrat typography, subtle motion.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const int _totalMs = 3000;

  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _lineScale;
  late final Animation<double> _lineOpacity;
  late final Animation<double> _langOpacity;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    const easeOut = Curves.easeOut;
    const titleEase = Cubic(0.22, 1, 0.36, 1);

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.22, curve: easeOut),
    );
    _logoScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.22, curve: easeOut)),
    );

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.267, 0.6, curve: titleEase),
      ),
    );
    _titleSlide = Tween<double>(begin: 15, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.267, 0.6, curve: titleEase),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.73, curve: Curves.easeOut),
      ),
    );

    _lineScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.77, curve: Curves.easeOut),
      ),
    );
    _lineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.77, curve: Curves.easeOut),
      ),
    );

    _langOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.95, curve: Curves.easeOut),
      ),
    );

    _footerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _montserrat({
    required Color color,
    double fontSize = 14,
    double letterSpacing = 0,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
    );
  }

  void _setLang(BuildContext context, Locale locale) {
    if (context.locale == locale) return;
    context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final titleRaw = 'app_title'.tr();
    final titleDisplay =
        context.locale.languageCode == 'en' ? titleRaw.toUpperCase() : titleRaw;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.15),
                radius: 1.15,
                colors: [
                  Color(0xFF013A27),
                  Color(0xFF012217),
                  Color(0xFF010F0B),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -36),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.fromRGBO(212, 175, 55, 0.06),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(top: 8, end: 20),
                        child: Opacity(
                          opacity: _langOpacity.value.clamp(0.0, 1.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => _setLang(context, const Locale('en')),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'lang_en'.tr(),
                                  style: _montserrat(
                                    color: context.locale.languageCode == 'en'
                                        ? AppColors.accentGold
                                        : AppColors.accentGold.withValues(alpha: 0.4),
                                    fontSize: 13,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Text(
                                '|',
                                style: _montserrat(
                                  color: AppColors.accentGold.withValues(alpha: 0.3),
                                  fontSize: 12,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _setLang(context, const Locale('ar')),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'splash_lang_ar'.tr(),
                                  style: _montserrat(
                                    color: context.locale.languageCode == 'ar'
                                        ? AppColors.accentGold
                                        : AppColors.accentGold.withValues(alpha: 0.4),
                                    fontSize: 13,
                                    letterSpacing: 1,
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Opacity(
                                opacity: _logoOpacity.value.clamp(0.0, 1.0),
                                child: Transform.scale(
                                  scale: _logoScale.value,
                                  child: Image.asset(
                                    'assets/branding/splash_logo.png',
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, _titleSlide.value),
                                child: Opacity(
                                  opacity: _titleOpacity.value.clamp(0.0, 1.0),
                                  child: Text(
                                    titleDisplay,
                                    textAlign: TextAlign.center,
                                    style: _montserrat(
                                      color: AppColors.textCream,
                                      fontSize: context.locale.languageCode == 'ar' ? 26 : 22,
                                      letterSpacing: context.locale.languageCode == 'en' ? 6 : 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Opacity(
                                opacity: _taglineOpacity.value.clamp(0.0, 1.0),
                                child: Text(
                                  context.locale.languageCode == 'en'
                                      ? 'splash_tagline'.tr().toUpperCase()
                                      : 'splash_tagline'.tr(),
                                  textAlign: TextAlign.center,
                                  style: _montserrat(
                                    color: AppColors.accentGold.withValues(alpha: 0.5),
                                    fontSize: 11,
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Opacity(
                                opacity: _lineOpacity.value.clamp(0.0, 1.0),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.diagonal3Values(
                                    _lineScale.value.clamp(0.001, 1.0),
                                    1.0,
                                    1.0,
                                  ),
                                  child: Container(
                                    width: 60,
                                    height: 1,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          AppColors.accentGold,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 24 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Opacity(
                        opacity: _footerOpacity.value.clamp(0.0, 1.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/branding/app_icon.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.locale.languageCode == 'en'
                                  ? 'splash_app_icon_label'.tr().toUpperCase()
                                  : 'splash_app_icon_label'.tr(),
                              style: _montserrat(
                                color: AppColors.accentGold.withValues(alpha: 0.35),
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
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
