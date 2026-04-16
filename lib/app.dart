import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/shell/presentation/main_shell.dart';
import 'features/workout/presentation/bloc/workout_bloc.dart';

class RoyalFitnessApp extends StatelessWidget {
  const RoyalFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorkoutBloc>(
      create: (_) => getIt<WorkoutBloc>(),
      child: MaterialApp(
        title: 'Royal Fitness',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: AppTheme.themeFor(context.locale),
        home: const _InitialGate(),
      ),
    );
  }
}

/// Shows [OnboardingPage] on first launch, then [LoginPage].
class _InitialGate extends StatefulWidget {
  const _InitialGate();

  @override
  State<_InitialGate> createState() => _InitialGateState();
}

class _InitialGateState extends State<_InitialGate> {
  bool? _onboardingDone;
  bool _supabaseReady = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_completed') ?? false;
    try {
      _supabaseReady = Supabase.instance.client.auth.currentSession != null ||
          SupabaseConfigGuard.clientAvailable();
    } catch (_) {
      _supabaseReady = false;
    }
    if (!mounted) return;
    setState(() => _onboardingDone = done);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) {
      return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
            ),
          ),
        );
    }
    if (_onboardingDone == false) {
      return const OnboardingPage();
    }
    if (!_supabaseReady) {
      return const LoginPage();
    }
    final authRepository = AuthRepository();
    return StreamBuilder(
      stream: authRepository.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          );
        }
        return snapshot.data == null ? const LoginPage() : const MainShell();
      },
    );
  }
}

class SupabaseConfigGuard {
  static bool clientAvailable() {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }
}
