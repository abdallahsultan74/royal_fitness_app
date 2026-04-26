import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/profile/data/profile_repository.dart';
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
  final ProfileRepository _profileRepository = ProfileRepository();

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
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          );
        }
        final state = snapshot.data;
        final session = state?.session;
        final event = state?.event;
        if (session != null && event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordPage();
        }
        if (session == null) {
          return const LoginPage();
        }
        return FutureBuilder<String?>(
          future: _profileRepository.fetchProfileRole(uid: session.user.id),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ),
              );
            }
            final role = roleSnap.data;
            final isStaff = role == 'admin' || role == 'coach';
            if (isStaff) return const _StaffBlockedGate();
            return const MainShell();
          },
        );
      },
    );
  }
}

class _StaffBlockedGate extends StatefulWidget {
  const _StaffBlockedGate();

  @override
  State<_StaffBlockedGate> createState() => _StaffBlockedGateState();
}

class _StaffBlockedGateState extends State<_StaffBlockedGate> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _kickOut();
  }

  Future<void> _kickOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _done = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final msg = 'auth_staff_not_allowed'.tr();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_done) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }
    return const LoginPage();
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
